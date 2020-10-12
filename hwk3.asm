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

get_slot:
    jr $ra

set_slot:
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
