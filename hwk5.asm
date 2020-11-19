# Wei Wen Zhou
# WEIWEZHOU
# 112928274

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
        lbu $t2, 2($t1) # flip facedown card up
        li $t3, 'd' # facedown
        seq $t4, $t2, $t3 # t4 = 1 if t2 = 'd' else 0 
        li $t3, 0x11
        mul $t4, $t4, $t3 # t4 = 0x11 if t2 == 'd' else 0
        add $t2, $t2, $t4
        sb $t2, 2($t1)

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
        li $t0, 0x00110000
        add $a1, $a1, $t0 # flip card
        jal append_card # append_card(CardList*, number)

        addi $s0, $s0, 4 # increment
        lw $s2, 4($s2) # next card
        addi $s3, $s3, -1 # decrement
        bnez $s3, deal_move_loop

    # update deck size
    lw $t0, 0($s1)
    addi $t0, $t0, -9 # decrement by 9
    sw $t0, 0($s1)
    sw $s2, 4($s1) # point to new head

    # postamble s0-3, ra (5 registers)
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

move_card: # int move_card(CardList* board[], CardList* deck, int moves)
    # preamble s0-3, ra (5 registers) 
    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    jal check_move # check_move(board[], deck, move) if v0 < 0 exit and return v0 -> -1
    move $t0, $v0
    li $v0, -1
    bltz $t0, move_card_clean_up
    # valid move
    addi $t0, $t0, -1 # decrement by 1 for valid moves: 0 = deal move, 1: empty recipent, 2:non-empty recipent 
    bnez $t0, move_card_not_deal_move

    move $a0, $s0
    move $a1, $s1
    jal deal_move # deal_move 

    li $s3, 9 # 9 columns to call clear full straight on
    move_card_deal_move_clear:
        addi $s3, $s3, -1
        move $a0, $s0
        move $a1, $s3
        jal clear_full_straight
        bnez $s3,  move_card_deal_move_clear
    li $v0, 1
    j move_card_clean_up

    move_card_not_deal_move: 
        andi $t0, $s2, 0xFF # byte 0
        li $t4, 4
        mul $t0, $t0, $t4 # donor column offset
        add $t0, $t0, $s0 # donor column address
        lw $t0, 0($t0) # donor cardList address
        lw $t1, 0($t0) # donor column size
        srl $t2, $s2, 8 # byte 1
        andi $t2, $t2, 0xFF # donor row
        sub $t8, $t1, $t2 # number of cards to move 
        sub $t2, $t1, $t8 # new length
        
        sw $t2, 0($t0) # store new length

        move_card_new_tail:
            beqz $t2, move_card_new_tail_found
            lw $t0, 4($t0) # next node
            addi $t2, $t2, -1 # decrement
            bnez $t2, move_card_new_tail

        move_card_new_tail_found:
            lw $t9, 4($t0) # the node to move to recipent
            sw $0, 4($t0) # zero out the donor
            lbu $t1, 2($t0) # flip facedown card up
            li $t2, 'd' # facedown
            bne $t1, $t2, move_card_not_facedown
            addi $t1, $t1, 0x11
            sb $t1, 2($t0)

            move_card_not_facedown:

            srl $t0, $s2, 16
            andi $t0, $t0, 0xFF # mask byte #2
            li $t4, 4
            mul $t0, $t0, $t4 # recipent column offset
            add $t0, $t0, $s0 # recipent column address
            lw $t0, 0($t0) # recipent cardList address
            lw $t1, 0($t0) # donor column size
            add $t2, $t1, $t8 # new donor size
            sw $t2, 0($t0) 

            # find 
            move_card_new_tail_donor:
                beqz $t1, move_card_new_tail_donor_found
                lw $t0, 4($t0) # next node
                addi $t1, $t1, -1 # decrement
                bnez $t1, move_card_new_tail_donor

            move_card_new_tail_donor_found:
                sw $t9, 4($t0)

        # move_card_not_deal_move_clear:
        move $a0, $s0
        srl $a1, $s2, 16 
        andi $a1, $a1, 0xFF # mask byte#2
        jal clear_full_straight

    li $v0, 1 # success


    move_card_clean_up:
        # postamble s0-3, ra (5 registers)
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $ra, 16($sp)
        addi $sp, $sp, 20
    jr $ra

load_game: # int, int load_game(string filename, CardList* board[], CardList* deck, int[] moves)
    # preamble s0-5, ra (7 registers)
    addi $sp, $sp, -28
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $ra, 24($sp)

    move $s0, $a0 # filename
    move $s1, $a1 # board
    move $s2, $a2 # deck
    move $s3, $a3 # moves array
    li $s4, 0 # 0
    li $s5, 0 # start at index 0

    # open file
    move $a0, $s0 # filename
    li $a1, 0 # read-only
    li $a2, 0 # mode is ignored
    li $v0, 13 
    syscall # open file 

    move $s0, $v0 # -> s0 = v0:file descriptor (no longer need filename)
    li $v0, -1
    li $v1, -1
    bltz $s0, load_game_clean_up # s0 < 0 -> error return -1, -1

    # allocate 4 bytes on the stack for reading file
    addi $sp, $sp, -4

    # load game deck
    move $a0, $s2 
    jal init_list # init_list(deck:s2)

    # set up board
    lw $a0, 0($s1) # address of cardlist 0
    jal init_list 
    lw $a0, 4($s1) # address of cardlist 1
    jal init_list 
    lw $a0, 8($s1) # address of cardlist 2
    jal init_list 
    lw $a0, 12($s1) # address of cardlist 3
    jal init_list 
    lw $a0, 16($s1) # address of cardlist 4
    jal init_list 
    lw $a0, 20($s1) # address of cardlist 5
    jal init_list 
    lw $a0, 24($s1) # address of cardlist 6
    jal init_list 
    lw $a0, 28($s1) # address of cardlist 7
    jal init_list 
    lw $a0, 32($s1) # address of cardlist 8
    jal init_list 

    load_game_load_deck:
        move $a0, $s0 # file_desc
		move $a1, $sp # buffer
		li $a2, 1 # read 1 character
		li $v0, 14 # syscall for read
		syscall

        beqz $v0, load_game_close_file # end of file shouldn't occur but just checking
		bltz $v0, load_game_close_file_error # error while reading shouldn't occur but just checking

        lbu $t0, 0($sp) # char read
        li $t1, '\r'
        beq $t0, $t1, load_game_load_deck # if char == '\r' ignored
        li $t1, '\n'
        beq $t0, $t1, load_game_load_moves # if char == '\n' -> done loading deck

        # else t0 is the byte #0 of the card to add -> read another character to get byte #2
        move $a0, $s0 # file_desc
		move $a1, $sp # buffer
		li $a2, 1 # read 1 character
		li $v0, 14 # syscall for read
		syscall

        beqz $v0, load_game_close_file # end of file shouldn't occur but just checking
		bltz $v0, load_game_close_file_error # error while reading shouldn't occur but just checking

        lbu $t1, 0($sp) # can't be '\r' or '\n'

        move $a0, $s2
        sll $a1, $t1, 16 # to byte #2 location
        add $a1, $t0, $a1 # combine byte#2 and 0
        addi $a1, $a1, 0x5300 # byte #1 is always spade = 0x53
        jal append_card # append_card(deck, num)

        j load_game_load_deck


    load_game_load_moves:
        move $a0, $s0 # file_desc
		move $a1, $sp # buffer
		li $a2, 1 # read 1 character
		li $v0, 14 # syscall for read
		syscall

        beqz $v0, load_game_close_file # end of file shouldn't occur but just checking
		bltz $v0, load_game_close_file_error # error while reading shouldn't occur but just checking

        lbu $t0, 0($sp) # char read
        li $t1, ' '
        beq $t0, $t1, load_game_load_moves # if char == ' ' -> check next 
        li $t1, '\r'
        beq $t0, $t1, load_game_load_moves # if char == '\r' ignored
        li $t1, '\n'
        beq $t0, $t1, load_game_load_board # if char == '\n' -> done loading deck

        # new move -> grab the next 3 characters to complete the move instruction
        move $a0, $s0 # file_desc
		move $a1, $sp # buffer
		li $a2, 3 # read 3 character
		li $v0, 14 # syscall for read
		syscall

        beqz $v0, load_game_close_file # end of file shouldn't occur but just checking
		bltz $v0, load_game_close_file_error # error while reading shouldn't occur but just checking

        li $t1, '0' # using to convert char to integer value
        
        lbu $t2, 2($sp) # byte 3
        sub $t2, $t2, $t1 
        sll, $t2, $t2, 8 # shift left 1 byte
        lbu $t3, 1($sp) # byte 2
        sub $t3, $t3, $t1
        add $t2, $t2, $t3
        sll, $t2, $t2, 8 # shift left 1 byte
        lbu $t3, 0($sp) # byte 1
        sub $t3, $t3, $t1
        add $t2, $t2, $t3
        sll, $t2, $t2, 8 # shift left 1 byte
        sub $t0, $t0, $t1 # integer value (byte 0)
        add $t2, $t2, $t0 
        
        sw $t2, 0($s3) # store in moves array
        addi $s3, $s3, 4 # increment
        addi $s4, $s4, 1 # counter for v1:increment

        j load_game_load_moves

    load_game_load_board:
        move $a0, $s0 # file_desc
        move $a1, $sp # buffer
        li $a2, 1 # read 1 character
        li $v0, 14 # syscall for read
        syscall

        beqz $v0, load_game_done # end of file shouldn't occur
        bltz $v0, load_game_close_file_error # error while reading shouldn't occur but just checking

        lbu $t0, 0($sp) # char read
        li $t1, '\r'
        beq $t0, $t1, load_game_load_board # if char == '\r' ignored
        li $t1, '\n'
        beq $t0, $t1, load_game_load_board_reset # if char == '\n' -> done loading deck

        # check next char
        move $a0, $s0 # file_desc
        move $a1, $sp # buffer
        li $a2, 1 # read 1 character
        li $v0, 14 # syscall for read
        syscall

        add $a0, $s1, $s5 # column address
        lw $a0, 0($a0) # cardList address
        addi $s5, $s5, 4 # increment to next column

        li $t2, ' '
        beq $t0, $t2, load_game_load_board # if char == ' ' -> check next (if t0 is ' ' then t1 is also ' ')

        lbu $t1, 0($sp) # char read
        sll $a1, $t1, 16 # to byte #2 location
        add $a1, $t0, $a1 # combine byte#2 and 0
        addi $a1, $a1, 0x5300 # byte #1 is always spade = 0x53
        jal append_card # append_card(deck, num)

        j load_game_load_board


        load_game_load_board_reset:
            li $s5, 0
            j load_game_load_board

    load_game_done:
        li $t8, 1
        move $t9, $s4
        j load_game_close_file

    load_game_close_file_error:
        li $t8, -1
        li $t9, -1

    load_game_close_file:
        move $a0, $s0 # file_desc
		li $v0, 16 # syscall for close file
        syscall

        # deallocate 4 bytes on the stack for reading file
        addi $sp, $sp, 4

        # correct the v0 and v1
        move $v0, $t8
        move $v1, $t9

    load_game_clean_up:
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

simulate_game: # int, int simulate_game(string filename, CardList* board[], CardList* deck, int[] moves)
    # preamble s0-4, ra (6 registers)
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $ra, 20($sp)

    move $s0, $a1
    move $s1, $a2
    move $s2, $a3
    li $s4, 0

    jal load_game # load_game on the provided arguments
    bltz $v0, simulate_game_clean_up # if -1[,-1] then return -1, -1

    move $s3, $v1 # num of moves

    simulate_game_move_loop:
        move $a0, $s0
        move $a1, $s1
        lw $a2, 0($s2)
        jal move_card # move_card(board:s0, deck,:s1, move:0(s2))
        sgt $t0, $v0, $0 # t0 = 1 if v0 > 0 (1) else v0 <= 0 (-1) -> 0
        add $s4, $s4, $t0 # increment if v0 == 1
        addi $s2, $s2, 4 # increment
        addi $s3, $s3, -1 # decrement
        bnez $s3, simulate_game_move_loop

    move $v0, $s4 # num of moves executed
    li $v1, -2 # if sum of size of CardLists is not 0

    lw $t0, 0($s1) # size of deck
    bnez $t0, simulate_game_clean_up
    
    li $t0, 9
    simulate_game_check_empty_board:
        lw $t1, 0($s0) # address of CardList
        lw $t1, 0($t1) # size of CardList
        bnez $t1, simulate_game_clean_up 
        addi $s0, $s0, 4 # increment board
        addi $t0, $t0, -1 # decrement
        bnez $t0, simulate_game_check_empty_board

    li $v1, 1 # all 0s -> win (1)

    simulate_game_clean_up:
        # postamble s0-4, ra (6 registers)
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $ra, 20($sp)
        addi $sp, $sp, 24
    jr $ra

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
