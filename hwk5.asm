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
    

    jr $ra

get_card:
    jr $ra

check_move:
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
