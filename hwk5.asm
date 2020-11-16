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
    # preamble s0-5, ra (7 registers)
    addi $sp, $sp, -28
    sw $s0, 0($sp) 
    sw $s1, 4($sp) 
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $ra, 24($sp)

    move $s0, $a0 # board
    move $s1, $a1 # deck
    # store a2 on the stack so I can load from it
    addi $sp, $sp, -4 
    sw $a2, 0($sp)
    move $s2, $sp # move(address)

    # check if move is valid
    # byte #3 is 0 or 1
    lbu $t0, 3($s2)
    srl $t1, $t0, 1
    beqz $t1, check_move_valid_deal_num
    li $v0, -1
    j check_move_clean_up # byte #3 != 0/1 -> -1

    check_move_valid_deal_num: 
        andi $t0, $t0, 1 # keep the first bit since that is the only relevant part left
        beqz $t0, check_move_not_deal_move # if $t0 = 0 not deal move
        # if deal move check the sum of the rest of the bytes
        lbu $t1, 0($s2) 
        lbu $t2, 0($s2) 
        add $t1, $t1, $t2
        lbu $t2, 0($s2) 
        add $t1, $t1, $t2 # sum of the 3 bytes (for valid deal move should be 0)
        
        beqz $t1, check_move_deal_move_works # sum is 0
        li $v0, -1 # sum != 0 not valid -> -1
        j check_move_clean_up

        check_move_deal_move_works: # if deck is empty or a column is empty -> -2 else 1
            # check deck is not empty
            lw $t0, 0($s1) # size of deck
            beqz $t0, check_move_illegal_deal_move

            li $t1, 9 # nine column
            move $t2, $s0 # board
            check_move_deal_move_columns:
                lw $t0, 0($t2) # address of card_list
                lw $t0, 0($t0) # size of column
                beqz $t0, check_move_illegal_deal_move 
                addi $t2, $t2, 4 # increment to next column
                addi $t1, $t1, -1 # decrement
                bnez $t1, check_move_deal_move_columns # branch 8 times

            li $v0, 1
            j check_move_clean_up # legal deal move

            check_move_illegal_deal_move:
                li $v0, -2
                j check_move_clean_up

    check_move_not_deal_move: # checks byte #0 and byte #2 is between [0,8] : if not -> -3
        li $v0, -3
        lbu $t0, 0($s2) # byte 0
        bltz $t0, check_move_clean_up # byte 0 < 0
        addi $t0, $t0, -8 # byte 0 - 8
        bgtz $t0, check_move_clean_up # byte 0 > 8

        lbu $t0, 2($s2) # byte 2
        bltz $t0, check_move_clean_up # byte 2 < 0
        addi $t0, $t0, -8 # byte 2 - 8
        bgtz $t0, check_move_clean_up # byte 2 > 8

        # checks byte #1 is valid for the byte #0 column in [0, column.size): if not -> -4
        li $v0, -4
        lbu $t0, 1($s2) # byte 1
        bltz $t0, check_move_clean_up # row < 0
        lbu $t1, 0($s2) # byte 0
        li $t2, 4
        mul $t1, $t1, $t2 # board_offset = 4 * byte 0
        add $t1, $t1, $s0 
        lw $t1, 0($t1) # cardlist
        lw $t1, 0($t1) # column size
        bge $t0, $t1, check_move_clean_up # byte 1 >= column.size


        # checks byte #0 != byte #2 : if equal -> -5
        lbu $t0, 0($s2) # byte 0
        lbu $t1, 2($s2) # byte 2
        li $v0, -5
        beq $t0, $t1, check_move_clean_up 

        # check if card at the donor column and row encoded in move is face-down (get_card -> v0 = 1:face-down, 2:face-up, -1:invalid[not_possible]): if facedown -> -6
        lbu $t1, 0($s2) # byte 0
        li $t2, 4
        mul $t1, $t1, $t2 # board_offset = 4 * byte 0
        add $a0, $t1, $s0 
        lw $a0, 0($a0) # address of donor CardList
        lbu $a1, 1($s2) # byte 1
        move $s3, $a0 # column
        move $s4, $a1 # index 
        jal get_card # get_card(donor_column, index:byte#1)

        addi $t0, $v0, -1 # v0-1 -> 0:facedown 1:face-up
        li $v0, -6
        beqz $t0, check_move_clean_up

        # check if donor column is in descending order: if not -> -7
        move $s5, $v1 # the first card value
        check_move_rest_of_column:
            addi $s4, $s4, 1 # increment index
            move $a0, $s3
            move $a1, $s4
            jal get_card # get_card(donor_column, next_index)
            li $v0, -7 
            li $t1, -1 # invalid 
            beq $v1, $t1, check_move_rest_of_column_done
            addi $s5, $s5, -1 # expected next value
            bne $v1, $s5, check_move_clean_up # not next smaller number -> -7
            lbu $t0, 0($t0) # size of column
            blt $s4, $t0, check_move_rest_of_column# index < column.size -> keep checking rest of cards

        check_move_rest_of_column_done:

        # check if byte 2 column is empty : if empty -> 2
        li $v0, 2
        lbu $t0, 2($s2) 
        li $t1, 4
        mul $t0, $t0, $t1 # board offset
        add $t0, $t0, $s0 
        lw $t0, 0($t0) # address of cardlist
        lw $t1, 0($t0) # column size
        beqz $t1, check_move_clean_up # empty -> 2

        # not empty: check if the tail node value is one greater than donor column and row in move: if not -> -8 else 3
        move $a0, $t0 # recipent column
        addi $a1, $t1, -1 # decrement index by one to get tail value
        jal get_card # get_card(recipent, length-1)

        addi $s5, $v1, -1 # expect value at donor column [row]
        move $a0, $s3 # donor column 
        lbu $a1 1($s2) # row
        jal get_card # get_card(donor, row)

        li $v0, 3
        beq $v1, $s5, check_move_clean_up # tail is one greater  -> 3
        li $v0, -8 # else -> -8


    check_move_clean_up:
        # deallocate space used for s2
        addi $sp, $sp, 4

        # postamble s0-5, ra (7 registers)
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $s5, 20($sp)
        lw $ra, 24($sp)
        addi $sp, $sp, 28

    jr $ra

clear_full_straight: # int clear_full_straight(CardList* board[], int col_num)
    # preamble s0-1, ra (3 registers)
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)
    
    li $v0, -1 # col_num is invalid -> -1
    bltz $a1, clear_full_straight_clean_up # col_num < 0
    addi $t0, $a1, -8 # t0 = a1-8
    bgtz $t0, clear_full_straight_clean_up # a1 > 8    

    li $t0, 4
    mul $t0, $a1, $t0 # offset
    add $s0, $a0, $t0 # address of CardList
    lw $s0, 0($s0) # cardlist

    lw $t0, 0($s0) # size of column 
    li $v0, -2 
    li $t1, 10
    blt $t0, $t1, clear_full_straight_clean_up # board size < 10 -> -2

    # size is >= 10 
    # check cards starting at the bottom and up 
    li $s1, 0
    clear_full_straight_check_straight:
        move $a0, $s0
        lw $a1, 0($s0)
        addi $s1, $s1, 1 
        sub $a1, $a1, $s1 # s1-offset from the bottom 1,2,...,9,10
        jal get_card # get_card(column, index) -> if v0 = 1:facedown or  v1 - s1 + 1 != 0 -> -3

        move $t1, $v0
        li $v0, -3
        li $t0, 1
        beq $t1, $t0, clear_full_straight_clean_up # facedown

        andi $v1, $v1, 0xF # bits 0-3
        sub $v1, $v1, $s1
        addi $v1, $v1, 1
        bnez $v1, clear_full_straight_clean_up # v1-s1+1 != 0 -> -3

        li $t0, 9
        ble	$s1, $t0, clear_full_straight_check_straight # $s1 <= 9 
        
    # take size - 10 and that's the new size of the column
    lw $t0, 0($s0)
    addi $t0, $t0, -10 
    sw $t0, 0($s0)
    # take size and find new tail
    seq $v0, $t0, $0 # convert size to v0: 1 if t0-10 == 0 else 0 
    addi $v0, $v0, 1 # increment
    move $t1, $s0 # current tail node

    clear_full_find_tail:
        beqz $t0, clear_full_found_tail
        lw $t1, 4($t1)
        addi $t0, $t0, -1
        j clear_full_find_tail

    clear_full_found_tail:
        sw $0, 4($t1) # zero out the next node reference

    clear_full_straight_clean_up:
        # postamble s0-1, ra (3 registers)
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $ra, 8($sp)
        addi $sp, $sp, 12

    jr $ra

deal_move: # void deal_move(CardList* board[], CardList* deck)
    # preamble s0-3, ra (5 registers) 
    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)

    move $s0, $a0
    move $s1, $a1
    lw $s2, 4($s1) # top card of the deck
    li $s3, 9 # nine cards to deal

    deal_move_loop:
        lw $a0, 0($s0)
        lw $a1, 0($s2) # value
        jal append_card # append_card(CardList*, number)

        addi $s0, $s0, 4 # increment
        lw $s2, 4($s2) # next card
        addi $s3, $s3, -1 # decrement
        bnez $s3, deal_move_loop

    # update deck size
    lw $t0, 0($s0)
    addi $t0, $t0, -9 # decrement by 9
    sw $t0, 0($s0)
    sw $t2, 4($s2) # point to new head

    # postamble s0-3, ra (5 registers)
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
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
