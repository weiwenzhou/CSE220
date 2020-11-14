# erase this line and type your first and last name here in a comment
# erase this line and type your Net ID here in a comment (e.g., jmsmith)
# erase this line and type your SBU ID number here in a comment (e.g., 111234567)

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

init_list: # void init_list(CardList* card_list)
    # $a0 : address to cardlist struct
    # set size and head to 0
    sw $0, 0($a0)
    sw $0, 4($a0)

    jr $ra

append_card: # int append_card(CardList* card_list, int card_num)
    # $a0 : address to cardlist struct
    # -> v0: size of the card_list after appending new card

    # find the end of the list
    lw $t0, 0($a0) # size of list
    move $t1, $a0 # current tail node

    append_card_find_tail:
        beqz $t0, append_card_found_tail
        lw $t1, 4($t1)
        addi $t0, $t0, -1
        j append_card_find_tail

    append_card_found_tail:
        # end node 
        move $t9, $a0 # keep a copy of card_list
        li $a0, 8
        li $v0, 9
        syscall # srbk to allocate 8 bytes in the heap -> v0 = address

        sw $a1, 0($v0) # add new node value
        sw $0, 4($v0) # 0 out the end
        sw $v0, 4($t1) # have previous tail node point to new node 

    # increment card_list size and return it 
    lw $v0, 0($t9)
    addi $v0, $v0, 1 # increment
    sw $v0, 0($t9)

    jr $ra

create_deck: # void create_deck()
    # -> v0: address of card_list for the deck
    # allocate memory on the stack for s0, s1, s2, $ra (4 registers)
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)

    # create card_list
    li $a0, 8
    li $v0, 9
    syscall # srbk to allocate 8 bytes in the heap -> v0 = address

    move $s2, $v0
    move $a0, $s2
    jal init_list # init_list(card_list:s2)

    # loop 8
    li $s0, 8
    create_deck_eight_set:
        li $s1, 10
        addi $s0, $s0, -1 # decremen
        # loop 10
        create_deck_ten_ranks:

            addi $s1, $s1, -1 # decrement

            move $a0, $s2
            li $a1, 0x00645339
            sub $a1, $a1, $s1
            jal append_card # append_card(card_list:s2, num:0x00645339 - s2)

            bnez $s1, create_deck_ten_ranks

        bnez $s0, create_deck_eight_set 

    # return card_list:s2
    move $v0, $s2

    # deallocate memory on the stack for s0, s1, s2, $ra (4 registers)
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16

    jr $ra

deal_starting_cards: # void deal_starting_cards(CardList* board[], CardList* deck)
    # a0: an array of size 9 of CardList* structs 
    # a1: a deck of size 80 cards
    # allocate memory on the stack for s0-4, $ra (6 registers)
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $ra, 20($sp)

    move $s0, $a0
    move $s1, $a1
    lw $s2, 4($s1) # first node
    li $s3, 35 # 35 facedown cards
    li $s4, 0 # index    

    deal_starting_card_facedown:
        add $a0, $s0, $s4
        lw $a0, 0($a0)
        lw $a1, 0($s2)
        jal append_card # append_card(CardList*:s0+s4, int:0($s2)) 

        lw $s2, 4($s2) # increment s2
        addi $s4, $s4, 4 # increment s4
        li $t0, 36
        seq $t1, $s4, $t0 # if s4 = 36
        mul $t1, $t1, $t0 # -> then s4 - 36
        sub $s4, $s4, $t1
        addi $s3, $s3, -1
        bnez $s3, deal_starting_card_facedown

    li $s3, 9
    deal_starting_card_faceup:
        add $a0, $s0, $s4
        lw $a0, 0($a0)
        lw $a1, 0($s2) # flip face up
        li $t0, 0x00110000
        add $a1, $a1, $t0
        jal append_card # append_card(CardList*:s0+s4, int:0($s2)) 

        lw $s2, 4($s2) # increment s2
        addi $s4, $s4, 4 # increment s4
        li $t0, 36
        seq $t1, $s4, $t0 # if s4 = 36
        mul $t1, $t1, $t0 # -> then s4 - 36
        sub $s4, $s4, $t1 
        addi $s3, $s3, -1
        bnez $s3, deal_starting_card_faceup

    # update cardList
    lw $t0, 0($s1)
    addi $t0, $t0, -44
    sw $t0, 0($s1)
    sw $s2, 4($s1) 

    # deallocate memory on the stack for s0-4, $ra (6 registers)
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24

    jr $ra

get_card: # int, int get_card(CardList* card_list, int index)
    # a0: linked list
    # a1: int
    # -> v0: -1 if invalid, 1 if facedown, 2 if faceup
    # -> v1: -1 if invalid otherwise card_value at index

    li $v0, -1
    li $v1, -1
    bltz $a1, get_card_done # index < 0
    lw $t0, 0($a0) # length
    bge $a1, $t0, get_card_done # index >= length

    lw $t0, 4($a0) # head
    get_card_search:
        beqz $a1, get_card_found
        lw $t0, 4($t0) # next node
        addi $a1, $a1, -1 # decrement
        j get_card_search

    get_card_found:
        lw $v1, 0($t0) # number
        srl $v0, $v1, 16 
        andi $v0, $v0, 15 # mask last 4 bits 0xXXXEXXXX
        addi $v0, $v0, -3

    get_card_done:

    jr $ra

check_move: # int check_move(CardList* board[], CardList* deck, int moves)
    # check if move is valid


    # byte #3 is 0 or 1
    lbu $t0, 3($a2)
    srl $t1, $t0, 1
    beqz $t1, check_move_valid_deal_num
    li $v0, -1
    jr $ra # not valid

    check_move_valid_deal_num:
        andi $t0, $t0, 1 # keep the first bit since that is the only relevant part left
        seq $t1, $t0, $0 # $t1 = 1 if t0 == 0 otherwise 0
        lbu $t2, 0($a2) 
        lbu $t3, 0($a2) 
        add $t2, $t2, $t3
        lbu $t3, 0($a2) 
        add $t2, $t2, $t3 # sum of the 3 bytes (for valid deal move should be 0)
        mul $t2, $t2, $t0 
        add $t2, $t2, $t1 # if 1 then 1*0+0 else 0*(don't care)+1
        
        bnez $t2, check_move_not_deal_move # if t2 == 0 then deal move else not a deal move

    check_move_not_deal_move:
    
    jr $ra

clear_full_straight:
    jr $ra

deal_move:
    jr $ra

move_card:
    jr $ra

load_game:
    jr $ra

simulate_game:
    jr $ra

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
