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

place_next_apple: # int, int place_next_apple(Gamestate* state, byte[] apples, int apple_length
	# a0 = state struct -> s0
	# a1 = apples byte[] -> s1
	# a2 = apple_length * 2 = length of apples array -> s2
	# s3 = row of current apple
	# s4 = col of current apple
	addi $sp, $sp, -24 # allocate 24 bytes (6 registers)
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $s0, $a0 # state struct
	move $s1, $a1 # apples
	move $s2, $a2 # apple_length
	
	find_apple_to_place_loop:
		lbu $s3, 0($s1) # row
		lbu $s4, 1($s1) # col
		
		move $a0, $s0
		move $a1, $s3
		move $a2, $s4
		jal get_slot # get_slot(state:s0, row:s3, col:s4)
		
		bltz $v0, find_apple_to_place_loop_next # v0 < 0 -> error -> check next apple
		li $t0, '.'
		bne $v0, $t0, find_apple_to_place_loop_next # v0 != "." -> not an valid spot to place apple -> check next apple
		# v0 = "." call set_slot
		move $a0, $s0
		move $a1, $s3
		move $a2, $s4
		li $a3, 'a'
		jal set_slot # set_slot(state:s0, row:s3, col:s4, 'a')
		
		move $v0, $s3 # v0 = s3
		move $v1, $s4 # v1 = s4
		
		li $t0, -1
		sb $t0, 0($s1)
		sb $t0, 1($s1)
		j place_next_apple_done 
		
		find_apple_to_place_loop_next:
			addi $s1, $s1, 2  # increment apples 	
			addi $s2, $s2, -1 # decrement apples count
			bnez $s2, find_apple_to_place_loop # more apples to check
	
	place_next_apple_done:
	# deallocate and recover register values
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	
    jr $ra

find_next_body_part: # int, int find_next_body_part(Gamestate* state, byte row, byte col, char target_part)
	# a0 = state struct -> s0
	# a1 = row (8-bit 2's complement) -> s1
	# a2 = col (8-bit 2's complement) -> s2
	# a3 = target part -> s3
	addi $sp, $sp, -20 # allocate 20 bytes for 5 registers
	sw $s0, 0($sp) # state
	sw $s1, 4($sp) # row
	sw $s2, 8($sp) # col
	sw $s3, 12($sp) # char
	sw $ra, 16($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	# check up
	addi $s1, $s1, -1 # row-1 to check up
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot # get_slot(state:s0, row-1:s1, col:s2)
	beq $v0, $s3, found_next_body # v0 = char:v3 -> found 
	# check down
	addi $s1, $s1, 2 # row-1+2 to check down
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot # get_slot(state:s0, row+1:s1, col:s2)
	beq $v0, $s3, found_next_body # v0 = char:v3 -> found 
	# check left
	addi $s1, $s1, -1 # row-1+2-1 to reset
	addi $s2, $s2, -1 # col-1 to check left
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot # get_slot(state:s0, row:s1, col-1:s2)
	beq $v0, $s3, found_next_body # v0 = char:v3 -> found 
	# check right
	addi $s2, $s2, 2 # col-1+2 to check right
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_slot # get_slot(state:s0, row:s1, col+1:s2)
	beq $v0, $s3, found_next_body # v0 = char:v3 -> found 
	# not found
	li $s1, -1
	li $s2, -1
	found_next_body:
		move $v0, $s1 # row
		move $v1, $s2 # col
	# deallocate and recover register values
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	
    jr $ra

slide_body: # int slide_body(Gamestate* stae, byte head_row_delta, byte head_col_delta, byte[] apples,int apples_length)
	# a0 = state struct -> s0
	# a1 = head_row_delta -> s1
	# a2 = head_col_delta -> s2
	# a3 = apples -> s3
	# stack = apples_length -> s4
	lw $t0, 0($sp)
	addi $sp, $sp, -28 # allocate 24 bytes (6 registers)
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	
	move $s0, $a0 # state
	move $s1, $a1 # row_delta
	move $s2, $a2 # col_delta
	move $s3, $a3 # apples
	move $s4, $t0 # apple_length
	li $s5, -1 # default
	
	move $a0, $s0
	lbu $a1, 2($s0)
	add $a1, $a1, $s1 
	lbu $a2, 3($s0)
	add $a2, $a2, $s2
	jal get_slot # get_slot(state:s0, head_row:2(s0)+head_row_delta:s1, head_col:3(s0)+head_col_delta:s2)
	
	li $t0, '.'
	beq $v0, $t0, slide_body_increment # v0 = '.' -> slide body
	li $t0, 'a'
	bne $v0, $t0, slide_body_done # v0 is not an apple and not '.'
	# an apple so call place_next_apple
	move $a0, $s0
	move $a1, $s3
	move $a2, $s4
	jal place_next_apple # place_next_apple(state:s0, apples:s3, apple_length:s4)
	addi $s5, $s5, 1 # increment s5 by 1
	
	slide_body_increment:
		addi $s5, $s5, 1 # increment s5 by 1
		# no longer need to keep apples and apples_length (s3, s4)
		# replace head and update struct.head_row and .head_col
		move $a0, $s0
		lbu $s3, 2($s0) # s3 = old head_row
		add $a1, $s3, $s1
		sb $a1, 2($s0) # update state.head_row 
		lbu $s4, 3($s0) # s4 = old head_col
		add $a2, $s4, $s2 
		sb $a2, 3($s0) # update state.head_col
		li $a3, '1'
		jal set_slot # set_slot(state:s0, head_row:2(s0)+head_row_delta:s1, head_col:3(s0)+head_col_delta:s2, '1')
		
		# s2 = next letter
		li $s2, '2'
		
		move_rest_of_body:
			# find next letter:s2 at current location(s3,s4)		
			move $a0, $s0
			move $a1, $s3
			move $a2, $s4
			move $a3, $s2
			jal find_next_body_part # find_next_body_part(state:s0, row:s3, col:s4, char:s2): v0, v1 -> -1,-1 ignore else update s3,s4
			
			bltz $v0, slide_body_cleanup # if v0 = -1 then make (s3, s4) = '.'
			# else make (s3, s4) = s2 and set s3 and s4 to v0, v1
			move $a0, $s0
			move $a1, $s3
			move $a2, $s4
			move $a3, $s2
			# replace s3,s4 with v0,v1
			move $s3, $v0
			move $s4, $v1
			jal set_slot # set_slot(state:s0, row:s3, col:s4, char:s2): v0 = char (don't care)
	
			addi $s2, $s2, 1 # increment s2 
			li $t0, ':'
			bne $s2, $t0, move_rest_of_body # if s2 != ":" then try next else increment by 7 convert : to "A"
			addi $s2, $s2, 7 
			j move_rest_of_body # only get here if s2 = ":"
			
			slide_body_cleanup:
				move $a0, $s0
				move $a1, $s3
				move $a2, $s4
				li $a3, '.'
				jal set_slot # set_slot(state:s0, row:s3, col:s4, '.'): v0 = char (don't care)
	
	slide_body_done:
		move $v0, $s5 # s5 -> v0
	# deallocate and recover register values
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
    jr $ra

add_tail_segment: # int add_tail_segment(Gamestate* state, char direction, byte tail_row, byte tail_col)
	# a0 = state struct -> s0
	# a1 = char direction -> s3, s4 (row:t1, col:t2)
	# a2 = tail_row -> s1
	# a3 = tail_col -> s2
	
	# check if a1 is valid
	li $t0, 'U' # (-1, 0)
	li $t1, -1
	li $t2, 0
	beq $a1, $t0, valid_direction
	li $t0, 'D' # ( 1, 0)
	li $t1, 1
	beq $a1, $t0, valid_direction
	li $t0, 'L' # ( 0,-1)
	li $t1, 0
	li $t2, -1
	beq $a1, $t0, valid_direction
	li $t0, 'R' # ( 0, 1)
	li $t2, 1
	beq $a1, $t0, valid_direction
	
	li $v0, -1 
	jr $ra # invalid direction
	
	valid_direction:
	
	addi $sp, $sp, -24 # allocate 24 bytes (6 registers)
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $s0, $a0 # state
	move $s1, $a2 # tail_row
	move $s2, $a3 # tail_col
	move $s3, $t1 # row_delta
	move $s4, $t2 # col_delta
	
	move $a0, $s0
	add $a1, $s1, $s3 # a1 = s1 + s3
	add $a2, $s2, $s4 # a2 = s2 + s4
	jal get_slot # get_slot(state:s0, tail_row:s1+off_row:s3, tail_col:s2+off_col:s4)
	
	move $t0, $v0
	li $v0, -1
	li $t1, '.'
	bne $t0, $t1, add_tail_done # v0:t0 != "." -> can't add terminate
	
	# v0:t0 = "." check (s1,s2) for next char to add to tail
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2 
	jal get_slot # get_slot(state:s0, row:s1, col:s2)
	
	addi $v0, $v0, 1 # increment v0 char 
	li $t0, ':'
	bne $v0, $t0, insert_tail # if s2 != ":" then insert the current char:v0 increment by 7 convert : to "A"
	addi $v0, $v0, 7 # only get here if v0 = ":"
	
	insert_tail:
		move $a0, $s0
		add $a1, $s1, $s3 # a1 = s1 + s3
		add $a2, $s2, $s4 # a2 = s2 + s4
		move $a3, $v0
		jal set_slot # set_slot(state:s0, tail_row:s1+off_row:s3, tail_col:s2+off_col:s4, char:v0)
		
		# increment state.length
		lbu $v0, 4($s0) 
		addi $v0, $v0, 1 # increment
		sb $v0, 4($sp) 
	
	add_tail_done:
	# deallocate and recover register values
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
    jr $ra

increase_snake_length: # int increase_snake_length(Gamestate* state, char direction)
	# a0 = state struct -> s0
	# a1 = direction -> s1
	# s2, s3 = current tail_row, tail_col
	# s4 = tracker
	# check if a1 is valid
	li $t0, 'U' 
	beq $a1, $t0, increase_snake_valid_direction
	li $t0, 'D' 
	beq $a1, $t0, increase_snake_valid_direction
	li $t0, 'L' 
	beq $a1, $t0, increase_snake_valid_direction
	li $t0, 'R' 
	beq $a1, $t0, increase_snake_valid_direction
	li $v0, -1 
	jr $ra # invalid direction
	increase_snake_valid_direction:
	
	addi $sp, $sp, -24 # allocate 24 bytes (6 registers)
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $s0, $a0 # state
	move $s1, $a1 # direction
	lbu $s2, 2($s0) # head_row
	lbu $s3, 3($s0) # head_col 
	li $s4, '2' # char to find
	
	increase_snake_find_tail: # if char:s4 not found -> found tail 
		move $a0, $a0
		move $a1, $s2
		move $a2, $s3
		move $a3, $s4
		jal find_next_body_part # find_next_body_part(state:s0, row:s2, col:s3, char:s4): v0,v1 (next x, y)
		
		bltz $v0, increase_snake_found_tail # if v0, v1 = -1,-1
		# else not found v0, v1 -> s2, s3 and keep searching
		move $s2, $v0
		move $s3, $v1 
		addi $s4, $s4, 1 # increment s4
		li $t0, ':'
		bne $s4, $t0, increase_snake_find_tail # if s4 != ":" then check s4
		addi $s4, $s4, 7 # only get here if s2 = ":" else increment by 7 convert : to "A"
		j increase_snake_find_tail
		
	increase_snake_found_tail:
		li $s4, 4 # check 4 direction max
		li $t0, 'U'
		beq $s1, $t0, increase_snake_D_direction
		li $t0, 'L'
		beq $s1, $t0, increase_snake_R_direction
		li $t0, 'R'
		beq $s1, $t0, increase_snake_L_direction
		# s1 = 'D' -> increase_snake_U_direction
		increase_snake_U_direction:
			move $a0, $s0
			li $a1, 'U'
			move $a2, $s2
			move $a3, $s3
			jal add_tail_segment # add_tail_segment(state:s0, 'U', tail_row:s2, tail_col:s3): v0 > 0 done
			bgtz $v0, increase_snake_done # v0 != -1 -> done
			addi $s4, $s4, -1 # decrement
		
		increase_snake_L_direction:
			move $a0, $s0
			li $a1, 'L'
			move $a2, $s2
			move $a3, $s3
			jal add_tail_segment # add_tail_segment(state:s0, 'L', tail_row:s2, tail_col:s3): v0 > 0 done
			bgtz $v0, increase_snake_done # v0 != -1 -> done
			addi $s4, $s4, -1 # decrement
			
		increase_snake_D_direction:
			move $a0, $s0
			li $a1, 'D'
			move $a2, $s2
			move $a3, $s3
			jal add_tail_segment # add_tail_segment(state:s0, 'D', tail_row:s2, tail_col:s3): v0 > 0 done
			bgtz $v0, increase_snake_done # v0 != -1 -> done
			addi $s4, $s4, -1 # decrement
			
		increase_snake_R_direction: #midway
			move $a0, $s0
			li $a1, 'R'
			move $a2, $s2
			move $a3, $s3
			jal add_tail_segment # add_tail_segment(state:s0, 'R', tail_row:s2, tail_col:s3): v0 > 0 done
			bgtz $v0, increase_snake_done # v0 != -1 -> done
			addi $s4, $s4, -1 # decrement
			beqz $s4, increase_snake_done
			
		increase_snake_U_direction_wrap:
			move $a0, $s0
			li $a1, 'U'
			move $a2, $s2
			move $a3, $s3
			jal add_tail_segment # add_tail_segment(state:s0, 'U', tail_row:s2, tail_col:s3): v0 > 0 done
			bgtz $v0, increase_snake_done # v0 != -1 -> done
			addi $s4, $s4, -1 # decrement
			beqz $s4, increase_snake_done
			
		increase_snake_L_direction_wrap:
			move $a0, $s0
			li $a1, 'L'
			move $a2, $s2
			move $a3, $s3
			jal add_tail_segment # add_tail_segment(state:s0, 'L', tail_row:s2, tail_col:s3): v0 > 0 done
			bgtz $v0, increase_snake_done # v0 != -1 -> done
			addi $s4, $s4, -1 # decrement
			beqz $s4, increase_snake_done
			
		increase_snake_D_direction_wrap:
			move $a0, $s0
			li $a1, 'D'
			move $a2, $s2
			move $a3, $s3
			jal add_tail_segment # add_tail_segment(state:s0, 'D', tail_row:s2, tail_col:s3): v0 > 0 done
			bgtz $v0, increase_snake_done # v0 != -1 -> done
			addi $s4, $s4, -1 # decrement
			beqz $s4, increase_snake_done
			
	increase_snake_done:
	
	# deallocate and recover register values
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
    jr $ra

move_snake: # int, int move_snake(Gamestate* state, char direction, byte[] apples, int apple_length)
	# a0 = state struct -> s0
	# a1 = direction -> s1
	# a2 = apples [] -> s2
	# a3 = apple_length -> s3
	# s4, s5 = direction in row_delta, col_delta
	
	# check if a1 is valid
	li $t0, 'U' # (-1, 0)
	li $t1, -1
	li $t2, 0
	beq $a1, $t0, move_snake_valid_direction
	li $t0, 'D' # ( 1, 0)
	li $t1, 1
	beq $a1, $t0, move_snake_valid_direction
	li $t0, 'L' # ( 0,-1)
	li $t1, 0
	li $t2, -1
	beq $a1, $t0, move_snake_valid_direction
	li $t0, 'R' # ( 0, 1)
	li $t2, 1
	beq $a1, $t0, move_snake_valid_direction
	
	li $v0, 0
	li $v1, -1
	jr $ra # invalid direction
	
	move_snake_valid_direction: 
	addi $sp, $sp, -28 # allocate 28 bytes (7 registers)
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	
	move $s0, $a0 # state
	move $s1, $a1 # direction
	move $s2, $a2 # apples[]
	move $s3, $a3 # apple_length
	move $s4, $t1 # row_delta
	move $s5, $t2 # col_delta
	
	
	# deallocate and recover register values
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	
    jr $ra

simulate_game:
    jr $ra

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
