# Wei Wen Zhou
# WEIWEZHOU
# 112928274

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text
load_game: # int, int load_game(GameStates* state, string filename)
	# a0 = state struct -> t0
	# a1 = filename -> t1
	# => v0: -1 if input error, 1 if 'a' found, else 0
	# => v1: -1 if input error: # of wall's found
	move $t0, $a0
	move $t1, $a1
	# allocate 4 bytes on the stack for buffer
	addi $sp, $sp, -4
	
	# open file 
	move $a0, $t1
	li $a1, 0 # read-only 
	li $a2, 0 # mode is ignored
	li $v0, 13 # syscall for open file
	syscall 
	move $t2, $v0 # v0: file descriptor -> t2
	bltz $t2, close_load_file_on_error # if t2:file_desc < 0 -> error return -1, -1
	# read file
	# zero out unsigned bytes in struct
	sb $0, 0($t0) # num_rows
	sb $0, 1($t0) # num_cols
	sb $0, 2($t0) # head_row
	sb $0, 3($t0) # head_col
	sb $0, 4($t0) # length
	
	li $t8, 0 # set v0 = 0
	li $t9, 0 # set v1 = 0
	
	li $t6, 2 # rows to read to get # of rows and columns
	li $t7, '\n' # newline 
	
	li $t3, 0 # 0 for initial # of rows
	load_num_in_row:
		move $a0, $t2 # file_desc
		move $a1, $sp # buffer
		li $a2, 1 # read 1 character
		li $v0, 14 # syscall for read
		syscall
	
		bltz $v0, close_load_file_on_error # error while reading shouldn't occur but just checking
		
		lbu $t4, 0($sp) # char read
		beq $t4, $t7, next_row # if t4 is \n store in t0:struc 
		# if t4 between 0 and 9, inclusive multiply t3 by 10 and add t4 - '0'
		li $t5, '9'
		bgt $t4, $t5, load_num_in_row # t4 > '9' not a num 
		li $t5, '0' 
		blt $t4, $t5, load_num_in_row # t4 < '0' not a num \r is caught here and ignored
		
		sub $t4, $t4, $t5 # is a num -> convert to binary
		li $t5, 10 # multiply by 10
		mul $t3, $t3, $t5 # t3 = 10*t3
		add $t3, $t3, $t4 # t3 = t3 + t4
		j load_num_in_row
		
		next_row:
			sb $t3, 0($t0) # store in t0:struc
		
	# read second row : reset t3 and increment t0 and decrement t6
	li $t3, 0
	addi $t0, $t0, 1
	addi $t6, $t6, -1
	bnez $t6, load_num_in_row # if not 0 keep getting numbers in row
	
	# read the rest
	li $t1, 3 # offset for t0:struct
	li $t5, 'a' # for searching for apple
	li $t6, '#' # for searching for wall
	load_game_board:
		move $a0, $t2 # file_desc
		move $a1, $sp # buffer
		li $a2, 1 # read 1 character
		li $v0, 14 # syscall for read
		syscall
	
		beqz $v0, close_load_file # end of file 
		bltz $v0, close_load_file_on_error # error while reading shouldn't occur but just checking
	
		lbu $t3, 0($sp) # char read
		li $t4, '\r'
		beq $t3, $t4, load_game_board # if t3 is \r ignore 
		beq $t3, $t7, load_game_board # if t3 is \n ignore
		
		add $t4, $t0, $t1 # t4 = t0 (sort of base) + t1 (offset)
		sb $t3, 0($t4) # store t3:char in t0:gameboard
		addi $t1, $t1, 1 # increment t0
		
		li $t4, '.'  # decrease # of comparisons
		beq $t3, $t4, load_game_board # t3 = '.'
		seq $t4, $t3, $t6 # 1 if t3 = '#' else 0
		add $t9, $t9, $t4 # t9 += t1
		bnez $t4, load_game_board
		seq $t4, $t3, $t5 # 1 if t3 = 'a' else 0
		add $t8, $t8, $t4 # t8 += t1
		bnez $t4, load_game_board
		
		li $t4, '1'
		blt $t3, $t4, load_game_board # t3 < '1' -> not part of snake
		li $t4, '9', 
		ble $t3, $t4, increment_snake_length # '1' <= t3 <= '9' -> part of snake
		li $t4, 'A'
		blt $t3, $t4, load_game_board # t3 < 'A' -> not part of snake
		li $t4, 'Z', 
		ble $t3, $t4, increment_snake_length # 'A' <= t3 <= 'Z' -> part of snake
		
		j load_game_board
		
		increment_snake_length:
			lbu $t4, 2($t0) # increment length
			addi $t4, $t4, 1
			sb $t4, 2($t0)
			
			li $t4, '1' 
			bne $t3, $t4, load_game_board # t3 != '1'
		add_head_to_struct:
			addi $t1, $t1, -3 # subtract initial offset
			lbu $t4, -1($t0) # get num_cols
			div $t1, $t4 # t1/t4 -> LO = QUOTIENT(head_row) HO = REMAINDER(head_col)
			mflo $t4 # head_row
			sb $t4, 0($t0)
			mfhi $t4 # head_col
			addi $t4, $t4, -1 # decrement by one because 0 is at the end of previous row
			sb $t4, 1($t0)
			addi $t1, $t1, 3 # add back initial offset
			
			j load_game_board
			
	close_load_file_on_error:
		li $t8, -1 # v0
		li $t9, -1 # v1
	close_load_file:
		# close file
		move $a0, $t2 # file_desc
		li $v0, 16 # syscall for close file
	
	move $v0, $t8 # t8: hold v0 return 
	move $v1, $t9 #	t9: hold v1 return
	# deallocate 4 bytes on the stack for buffer
	addi $sp, $sp, 4
	jr $ra

get_slot: # int get_slot(Gamestate* state, byte row, byte col) 
	# a0 = state struct
	# a1 = byte row (2's complement)
	# a2 = byte col (2's complement)
	li $v0, -1 # error
	# check if a1:row is in the bounds [0, state.num_rows:0(a0) - 1] 
	andi $t0, $a1, 0x80 # check if a1 is negative
	bnez $t0, get_slot_done # the 8-bit is not 0 -> negative number
	lbu $t0, 0($a0) # state.num_rows
	bge $a1, $t0, get_slot_done # out of bounds -> error
	
	# check if a2:col is in the bounds [0, state.num_cols:1(a0) - 1] 
	andi $t0, $a2, 0x80 # check if a2 is negative
	bnez $t0, get_slot_done # the 8-bit is not 0 -> negative number
	lbu $t0, 1($a0) # state.num_cols
	bge $a2, $t0, get_slot_done # out of bounds -> error
	
	# valid row and col : t0 = state.num_cols
	mul $t0, $t0, $a1 # t0 = t0 * a1 (row)
	add $t0, $t0, $a2 # t0 = t0 + a2 (col)
	addi $t0, $t0, 5 # offset for the first 5 bytes in state
	add $t0, $t0, $a0 # base + offset
	lbu $v0, 0($t0)
	
	get_slot_done:
    jr $ra

set_slot:
    # int set_slot(Gamestate* state, byte row, byte col, char ch) 
	# a0 = state struct
	# a1 = byte row (2's complement)
	# a2 = byte col (2's complement)
	# a3 = ch (do not need to validate)
	li $v0, -1 # error
	# check if a1:row is in the bounds [0, state.num_rows:0(a0) - 1] 
	andi $t0, $a1, 0x80 # check if a1 is negative
	bnez $t0, set_slot_done # the 8-bit is not 0 -> negative number
	lbu $t0, 0($a0) # state.num_rows
	bge $a1, $t0, set_slot_done # out of bounds -> error
	
	# check if a2:col is in the bounds [0, state.num_cols:1(a0) - 1] 
	andi $t0, $a2, 0x80 # check if a2 is negative
	bnez $t0, get_slot_done # the 8-bit is not 0 -> negative number
	lbu $t0, 1($a0) # state.num_cols
	bge $a2, $t0, get_slot_done # out of bounds -> error
	
	# insert ch:a3 in state:a0.grid[row:a1][col:a2] : t0 = state.num_cols
	mul $t0, $t0, $a1 # t0 = t0 * a1 (row)
	add $t0, $t0, $a2 # t0 = t0 + a2 (col)
	addi $t0, $t0, 5 # offset for the first 5 bytes in state
	add $t0, $t0, $a0 # base + offset
	sb $a3, 0($t0) # store ch
	move $v0, $a3
	
	set_slot_done:
    jr $ra

place_next_apple:
    jr $ra

find_next_body_part:
    jr $ra

slide_body:
    jr $ra

add_tail_segment:
    jr $ra

increase_snake_length:
    jr $ra

move_snake:
    jr $ra

simulate_game:
    jr $ra

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
