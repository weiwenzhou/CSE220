# Wei Wen Zhou
# WEIWEZHOU
# 112928274

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
addr_arg4: .word 0
addr_arg5: .word 0
addr_arg6: .word 0
addr_arg7: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Output messages
big_bobtail_str: .asciiz "BIG_BOBTAIL\n"
full_house_str: .asciiz "FULL_HOUSE\n"
five_and_dime_str: .asciiz "FIVE_AND_DIME\n"
skeet_str: .asciiz "SKEET\n"
blaze_str: .asciiz "BLAZE\n"
high_card_str: .asciiz "HIGH_CARD\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Put your additional .data declarations here, if any.


# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beqz $a0, zero_args
    li $t0, 1
    beq $a0, $t0, one_arg
    li $t0, 2
    beq $a0, $t0, two_args
    li $t0, 3
    beq $a0, $t0, three_args
    li $t0, 4
    beq $a0, $t0, four_args
    li $t0, 5
    beq $a0, $t0, five_args
    li $t0, 6
    beq $a0, $t0, six_args
seven_args:
    lw $t0, 24($a1)
    sw $t0, addr_arg6
six_args:
    lw $t0, 20($a1)
    sw $t0, addr_arg5
five_args:
    lw $t0, 16($a1)
    sw $t0, addr_arg4
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here

zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory

start_coding_here:
    # Start the assignment by writing your code here
    
	# PART 1: Validating Input
    lw $t0, addr_arg0 # load the address of first argument into t0
    lbu $s0, 0($t0) # s0 = first character of the first argument
    lbu $s1 1($t0) # s1 = second character of the first argument
    
    bnez $s1, invalid_operation 
    # branch if second character of first argument is not \0 (s1 != 0)
    
    li $s1, '1'
    beq $s0, $s1, part2_to_binary # if arg0(s0) = 1 (s1)
    
    li $s1, '2'
    beq $s0, $s1, part2_to_binary # if arg0(s0) = 2 (s1)
    
    li $s1, 'S'
    beq $s0, $s1, part2_to_binary # if arg0(s0) = S (s1)
    
    li $s1, 'F'
    beq $s0, $s1, part3_print_decimal # if arg0(s0) = F (s1)
    
    li $s1, 'R'
    beq $s0, $s1, part4_to_rtype # if arg0(s0) = R (s1)
    
    li $s1, 'P'
    beq $s0, $s1, part5_poker_hand # if arg0(s0) = P (s1)
    
    invalid_operation:
    	# first value is invalid
   		la $a0, invalid_operation_error
    	li $v0, 4 # print string
    	syscall
    	j exit
    
	# PART 2: Process a 4 digit hex in S/M, 1, or 2 to 2s complement
	part2_to_binary:
		lw $s0, num_args
		li $s1, 3
   		bne $s0, $s1, invalid_args # if num_args(s0) != 3 (s1)
   		
   		# validate hex digits prep for later
   		lw $t1, addr_arg1 # address of arg1(hex digits) in t1
   		li $s3, 0 # s3 = 0
   		li $s4, 4 # s4 = 4
   		li $s7, 0 # s7 = 0 
   		
   		# validate num_bits and put the integer value of arg2 into s0
   		lw $t0, addr_arg2 # address of arg2 in t0
   		lbu $s0, 0($t0) # first character of arg2(t0) in s0
   		lbu $s1, 1($t0) # second charcter in arg2(t0) s1
   		
  		# s2 for comparisons
   		li $s2, '1' # s2 = '1' 
  		beq $s0, $s2, validate_num_bits_case1 # first character(s0) = 1 then branch case1
  		
  		li $s2, '2' # s2 = '2' 
  		beq $s0, $s2, validate_num_bits_case2 # first character(s0) = 2 then branch case2
  		
  		li $s2, '3' # s2 = '3' 
  		beq $s0, $s2, validate_num_bits_case3 # first character(s0) = 3 then branch case3
  		
  		j invalid_args # s0 != 1,2, or 3 branch to invalid_args
  		
   		# if s0 = 1 then s1 >= 6 and s1 <= 9
   		validate_num_bits_case1:
   			li $s2, '6' # s2 = '6' 
  			blt $s1, $s2, invalid_args # second character(s1) < 6 branch invalid_args
  			
  			li $s2, '9' # s2 = '9' 
  			bgt $s1, $s2, invalid_args # second character(s1) > 9 branch invalid_args
   			
   			li $s0, '0' # s0 = '0' (to convert digits to their integer value)
   			sub $s1, $s1, $s0 # s1 = s1-s0 (integer value)
   			addi $s0, $s1, 10 # s0 = s1 + 10
   			
   			j validate_hex_digits # arg2 is valid
   			
   		# if s0 = 2 then s1 >= 0 and s1 <= 9
   		validate_num_bits_case2:
   			li $s2, '0' # s2 = '0' 
  			blt $s1, $s2, invalid_args # second character(s1) < 0 branch invalid_args
  			
  			li $s2, '9' # s2 = '9' 
  			bgt $s1, $s2, invalid_args # second character(s1) > 9 branch invalid_args
   			
   			li $s0, '0' # s0 = '0' (to convert digits to their integer value)
   			sub $s1, $s1, $s0 # s1 = s1-s0 (integer value)
   			addi $s0, $s1, 20 # s0 = s1 + 20
   			
   			j validate_hex_digits # arg2 is valid
   		
   		# if s0 = 3 then s1 >= 0 and s1 <= 2
   		validate_num_bits_case3:
   			li $s2, '0' # s2 = '0' 
  			blt $s1, $s2, invalid_args # second character(s1) < 0 branch invalid_args
  			
  			li $s2, '2' # s2 = '2' 
  			bgt $s1, $s2, invalid_args # second character(s1) > 2 branch invalid_args
   			
   			li $s0, '0' # s0 = '0' (to convert digits to their integer value)
   			sub $s1, $s1, $s0 # s1 = s1-s0 (integer value)
   			addi $s0, $s1, 30 # s0 = s1 + 30
   			
   			j validate_hex_digits # arg2 is valid
   			
   			
   		# prep from earlier: address of arg1 into t1 , s3 = 0, s4 = 4 for loop conditional 
   		# validates hex digits and put the integer value into s7
   		validate_hex_digits: # do while loop 
   			
   			lbu $s1, 0($t1) # the s3-th(0...3) character in arg1(t1) in s1
   			# hex_digit check if between 0 and 9 or between A and F, inclusive
   			
   			li $s5, '0' # s5 = 30 (use to convert 0-9 to their respective integer value)
   			# 0 <= s1 <= 9
   			li $s2, '0'
   			blt $s1, $s2, invalid_args # s1 < 0 branch invalid_args
   			
   			li $s2, '9'
   			ble $s1, $s2, validate_next_hex # s1 <= 9 branch next character
   		
   			li $s5, 'A' # s5 = 30 (use to convert A-F to their respective integer value)
   			addi $s5, $s5, -10 # A = 10, B = 11, ... F = 15
   			
   			# A <= s1 <= F
   			li $s2, 'A'
   			blt $s1, $s2, invalid_args # s1 < 0 branch invalid_args
   			
   			li $s2, 'F'
   			ble $s1, $s2, validate_next_hex # s1 <= F branch next character
   		
   			j invalid_args # invalid hex digit
   			
   			 
   			validate_next_hex:
   				sll $s7, $s7, 4 # shift 4 bits left to make room for the hex value
   				sub $s6, $s1, $s5 # s6 (integer value) = s1 (ascii value) - s6(base ascii value [0/A])
				# put value in s6 into proper spot in s7   	
				add $s7, $s7, $s6 # s7 = s7 + s6
				
				addi $t1, $t1, 1 # increment address
   				addi $s3, $s3, 1 # s3 = s3+1
   				blt $s3, $s4, validate_hex_digits # s3 < s4(4) loop
   		
		# process the argument values
		# t0 = address of arg2, t1 = address of arg1, t2 = address of arg0
		# s0 = number of bits, s1 = the value of the 4 hexdecimal digits, s2 = type (1,2,S)
		move $s1, $s7
		lw $t2, addr_arg0
		lbu $s2, 0($t2) # s2 = 1,2, or S
		
		
		li $s3, 1 # s3 = 1 (check whether the bit at the first spot is 0 or 1)
		li $v0, 1 # prep to print integers
		
		# check if number is positive or negative (using the 16-th bit)
		srl $s4, $s1, 15 # shift right 15 to look at the 16th bit
		beqz $s4, print_bits # if s4(16th bit) = 0 the number is positive same for all representations
		
		# negative numbers
		li $s4, 'S' # s4 = 'S'
		bne $s2, $s4, convert_from_2 # not signed 
		convert_from_S:
			andi $s1, $s1, 0x7FFF # mask the first 15 bits (excluding sign bit(16th bit))
			nor $s1, $s1, $0 # invert all the bits of s1	
			
		convert_from_2:
			sll $s1, $s1, 16 # left shift 16 to move the 16 bits up to front
			sra $s1, $s1, 16 # right arithmetic shift to sign extend for the extra 16 bits in register
			
			li $s4, '2' # s4 = '2'
			beq $s2, $s4, print_bits # now print the appropriate number of bits converting from 2's
		
		convert_from_1:
			addi $s1, $s1, 1 # s1 = s1 + 1 (increment by 1)
	
		print_bits:
			li $a0, 0 # a0 = 0 (reset)
			addi $s0, $s0, -1 # s0 = s0-1 (decrement)
			srlv $a0, $s1, $s0 # a3 = s1 shifted right s0 bits
			and $a0, $a0, $s3 # a0 = a0 AND s3
			syscall 
			
			bnez $s0, print_bits # if s0 != 0 then keep printing
		   		   		
		li $a0, '\n' # print newline
		li $v0, 11 
		syscall
		
   		j exit # exit the program
	
	# PART 3: Print Decimal Fixed-point # as a Binary Fixed-point #
	part3_print_decimal:
		lw $s0, num_args
		li $s1, 2
   		bne $s0, $s1, invalid_args # if num_args(s0) != 2 (s1)
   		
   		# t0 = address of arg1, s0 = stored the x-th character of arg2
   		lw $t0, addr_arg1
   		# get integer value and store in s1
   		li $s1, 0 # s1 = 0
   		li $s2, '0' # to use to convert character digits to decimal value
   		li $s3, 10 # to left shift the decimal value
   		
   		li $s4, 3 # counter for the decimal_digits_to_value loop (3 for the first 3 digits)
   		li $s5, 1 # 1 for first set and 0 for second set of numbers
   		
   		decimal_digits_to_value: # s1 stores the decimal value
  	 		lbu $s0, 0($t0) # the first character of arg2 
  	 		sub $s0, $s0, $s2 # s0 = s0 - s2 (integer value of digit)
  	 		
   			mul $s1, $s1, $s3 # s1 = s1 * 10(s3) # left shift for decimal
  		 	add $s1, $s1, $s0 # s1 = s1 + s0 (the next digit)
   		
   			addi $s4, $s4, -1 # s4 = s4 - 1
   			addi $t0, $t0, 1 # increment to check the next character of arg2
   			
   			bnez $s4, decimal_digits_to_value # continue to check the digits
   		
   		addi $s5, $s5, -1 # s5 = s5 - 1
   		li $s4, 5 # set the counter for the second set of numbers: 5 digits)
   		addi $t0, $t0, 1 # increment to ignore the '.' and set address to the tenth place 
   		
   		bnez $s5, convert_decimal_to_binary # s5 = -1 (done converting digits) s1 = decimal part, s7 = integer part
   		move $s7, $s1 # s1 -> s7 (integer value)
   		li $s1, 0 # s1 = 0
   		
   		convert_floating_point_digits:
   			beqz $s5, decimal_digits_to_value # check second set of numbers
   		
   		convert_decimal_to_binary:
   			move $s2, $s1
   			move $s1, $s7
   			# s1 = integer part, s2 = floating part
   			
   			li $v0, 1 # prep for printing integers
   			# print integer part: start at the 10th bit (2^9 = 512, 2^10(11th bit) = 1024
   			li $s3, 10 # shift 9 right to get 10th bit
   			
   			check_for_first_digit_to_print:
   				addi, $s3, $s3, -1 # decrement one to get the s3-th bit
   				srlv $a0, $s1, $s3 # right shift by 9...0 
   				andi $a0, $a0, 1 # mask the first bit
   				
   				beqz $s3, print_integer_in_binary # for when integer part = '000'
   				beqz $a0, check_for_first_digit_to_print # keep checking next char if bit = 0
   				
   			print_integer_in_binary:
   				syscall # print the first 1 from the previous label
   				
   				addi, $s3, $s3, -1 # decrement one to get the next bit
   				srlv $a0, $s1, $s3 # right shift by 9...0 
   				andi $a0, $a0, 1 # mask the first bit
   				
   				bgez $s3, print_integer_in_binary # s3 >= 0 more bits to print
   				
   			# print the dot
   			li $a0, '.' 
   			li $v0, 11 # print char
   			syscall
   			
   			# print the floating part
   			li $v0, 1 # prep for printing integer
   			li $s3, 50000 # for subtraction 1/2..1/32
   			li $s4, 5 # counter for loop
   			   			
   			print_floating_in_binary:
   				li $a0, 0 # reset a0 to 0
   				sub $s5, $s2, $s3 # s5 = s3 - s2
   				   				
   				bltz $s5, print_current_binary_bit # if s5 <= 0 print 0
   				move $s2, $s5 # s2 = s5
   				li $a0, 1 # print 1
   				print_current_binary_bit:
   					syscall # print 0 or 1
   				
   				addi $s4, $s4, -1 # decrement s4 for loop
   				srl $s3, $s3, 1 # shift right 1 = divide by 2
   				bnez $s4, print_floating_in_binary # keep printing
   			
   		j exit # exit the program
   		
	# PART 4: Encode Six Numerical Fields as an R-Type MIPS Instruction
	part4_to_rtype:
		lw $s0, num_args
		li $s1, 7
   		bne $s0, $s1, invalid_args # if num_args(s0) != 7 (s1)
   		   		
   		
		# validate arg2,3,4, and 5 to be from 0-31 and store them in s2,s3,s4, and s5
		li $s7, 10 # s7 = 10 (prep for left shift decimal values)
		li $s0, 31 # s0 = 31 to check for upper bound
		# arg2
		lw $t0, addr_arg2 # t0 = address of arg2
		
		lbu $s2, 0($t0) #  first character of arg2
		lbu $s1, 1($t0) # second character of arg2
		
		addi $s2, $s2, -48 # s2 = s2 - '0'(48) (integer value)
		mul $s2, $s2, $s7  # s2 = s2*10(s7) (left shift)
		addi $s1, $s1, -48 # s1 = s1 - '0' (48) (integer value)
		add $s2, $s2, $s1  # s2 = s2 + s1 (integer value of arg2)
		
		bltz $s2, invalid_args # arg2 < 0 (invalid)
		bgt $s2, $s0, invalid_args # arg2 > 31 (invalid)
		
		# arg3
		lw $t0, addr_arg3 # t0 = address of arg3
		
		lbu $s3, 0($t0) #  first character of arg3
		lbu $s1, 1($t0) # second character of arg3
		
		addi $s3, $s3, -48 # s3 = s3 - '0'(48) (integer value)
		mul $s3, $s3, $s7  # s3 = s3*10(s7) (left shift)
		addi $s1, $s1, -48 # s1 = s1 - '0' (48) (integer value)
		add $s3, $s3, $s1  # s3 = s3 + s1 (integer value of arg3)
		
		bltz $s3, invalid_args # arg3 < 0 (invalid)
		bgt $s3, $s0, invalid_args # arg3 > 31 (invalid)
		
		# arg4
		lw $t0, addr_arg4 # t0 = address of arg4
		
		lbu $s4, 0($t0) #  first character of arg4
		lbu $s1, 1($t0) # second character of arg4
		
		addi $s4, $s4, -48 # s4 = s4 - '0'(48) (integer value)
		mul $s4, $s4, $s7  # s4 = s4*10(s7) (left shift)
		addi $s1, $s1, -48 # s1 = s1 - '0' (48) (integer value)
		add $s4, $s4, $s1  # s4 = s4 + s1 (integer value of arg4)
		
		bltz $s4, invalid_args # arg4 < 0 (invalid)
		bgt $s4, $s0, invalid_args # arg4 > 31 (invalid)
		
		# arg5 
		lw $t0, addr_arg5 # t0 = address of arg5
		
		lbu $s5, 0($t0) #  first character of arg5
		lbu $s1, 1($t0) # second character of arg5
		
		addi $s5, $s5, -48 # s5 = s5 - '0'(48) (integer value)
		mul $s5, $s5, $s7  # s5 = s5*10(s7) (left shift)
		addi $s1, $s1, -48 # s1 = s1 - '0' (48) (integer value)
		add $s5, $s5, $s1  # s5 = s5 + s1 (integer value of arg5)
		
		bltz $s5, invalid_args # arg5 < 0 (invalid)
		bgt $s5, $s0, invalid_args # arg5 > 31 (invalid)
		
		# arg6 upper bound is 63
		li $s0, 63 # upper bound is 63
		lw $t0, addr_arg6 # t0 = address of arg6
		
		lbu $s6, 0($t0) #  first character of arg6
		lbu $s1, 1($t0) # second character of arg6
		
		addi $s6, $s6, -48 # s6 = s6 - '0'(48) (integer value)
		mul $s6, $s6, $s7  # s6 = s6*10(s7) (left shift)
		addi $s1, $s1, -48 # s1 = s1 - '0' (48) (integer value)
		add $s6, $s6, $s1  # s6 = s6 + s1 (integer value of arg6)
		
		bltz $s6, invalid_args # arg6 < 0 (invalid)
		bgt $s6, $s0, invalid_args # arg6 > 31 (invalid)
		
		# combine the argument inputs and store in $s1
		li $s1, 0 # arg1: opcode ('00')
		add $s1, $s1, $s2 # arg2: rs
		
		sll $s1, $s1, 5 # shift left 5 bits to make space for arg3
		add $s1, $s1, $s3 # arg3: rt
		
		sll $s1, $s1, 5 # shift left 5 bits to make space for arg4
		add $s1, $s1, $s4 # arg4: rd
		
		sll $s1, $s1, 5 # shift left 5 bits to make space for arg5
		add $s1, $s1, $s5 # arg5: shamt
		
		sll $s1, $s1, 6 # shift left 5 bits to make space for arg6
		add $s1, $s1, $s6 # arg6: funct	
		
		move $a0, $s1 # a0 = s1
		li $v0, 34 # print hexadecimal
		syscall
		
		li $a0, '\n' # print newline
		li $v0, 11 
		syscall
		
   		j exit # exit the program
	
	# PART 5: Identify Non-standard, Five-card Poker Hands
	part5_poker_hand:
		lw $s0, num_args
		li $s1, 2
   		bne $s0, $s1, invalid_args # if num_args(s0) != 2 (s1)

		lw $t0, addr_arg1 # address of arg1
				
		lbu $s1, 0($t0) # first card of arg1
		lbu $s2, 1($t0) # second card of arg1
		lbu $s3, 2($t0) # third card of arg1
		lbu $s4, 3($t0) # fourth card of arg1
		lbu $s5, 4($t0) # fifth card of arg1
		
		
		
		li $s7, 1 # 1 to sort with respect to suit, 0 to sort by rank
		
		sort_poker_hand: # bubble sort (s6 for swapping)
			li $s0, 0 # use to keep track of # of swaps
			
			ble $s1, $s2, check_second_third # s1 <= s2 then don't swap
			move $s6, $s1 # s6 = s1 (temp)
			move $s1, $s2 # s1 = s2
			move $s2, $s6 # s2 = s6
			addi $s0, $s0, 1 # increment swaps
			
			check_second_third:
				ble $s2, $s3, check_third_fourth # s2 <= s3 then don't swap
				move $s6, $s2 # s6 = s2 (temp)
				move $s2, $s3 # s2 = s3
				move $s3, $s6 # s3 = s6
				addi $s0, $s0, 1 # increment swaps
				
			check_third_fourth:
				ble $s3, $s4, check_fourth_fifth # s3 <= s4 then don't swap
				move $s6, $s3 # s6 = s3 (temp)
				move $s3, $s4 # s3 = s4 
				move $s4, $s6 # s4 = s6
				addi $s0, $s0, 1 # increment swaps
				
			check_fourth_fifth:
				ble $s4, $s5, done_swapping # s4 <= s5 then don't swap
				move $s6, $s4 # s6 = s4 (temp)
				move $s4, $s5 # s4 = s5
				move $s5, $s6 # s5 = s6
				addi $s0, $s0, 1 # increment swaps
			
			done_swapping:
				bnez $s0, sort_poker_hand # number of swaps is not zero keep sorting
				
		beqz $s7, check_full_house # if s7 = 0 that means not big_bobtail
		
		# big_bobtail sort with respect to suit
		# 2 cases: s1,2,3,4 are consecutive or s2,3,4,5 are consecutive
		# s7 = 1
		sub $s6, $s2, $s1 # s6 = s2 - s1 
		bne $s6, $s7, big_bobtail_case2 # s6 != 1 then case 2
		
		sub $s6, $s3, $s2 # s6 = s3 - s2
		bne $s6, $s7, not_big_bobtail # s6 != 1 then not big_bobtail
		
		sub $s6, $s4, $s3 # s6 = s4 - s3 
		bne $s6, $s7, not_big_bobtail # s6 != 1 then not big_bobtail
		
		j print_big_bobtail # s1,2,3,4 are consecutive -> print big bobtail
		
		big_bobtail_case2: # s2,s3,4,5 are consecutive
			sub $s6, $s3, $s2 # s6 = s3 - s2 
			bne $s6, $s7, not_big_bobtail # s6 != 1 then not big_bobtail
			
			sub $s6, $s4, $s3 # s6 = s4 - s3
			bne $s6, $s7, not_big_bobtail # s6 != 1 then not big_bobtail
			
			sub $s6, $s5, $s4 # s6 = s5 - s4 
			beq $s6, $s7, print_big_bobtail # s2,3,4,5 are consecutive -> print big bobtail
		
		not_big_bobtail:
			andi $s1, $s1, 0xF # keep only the card rank
			andi $s2, $s2, 0xF # keep only the card rank
			andi $s3, $s3, 0xF # keep only the card rank
			andi $s4, $s4, 0xF # keep only the card rank
			andi $s5, $s5, 0xF # keep only the card rank
			
			li $s7, 0 # not big_bobtail, sort hand again by rank
			j sort_poker_hand
			
		check_full_house: # full_house: 2 cases
			# case 1: s1,s2,s3 are a triple and s4,s5 are a pair
			sub $s6, $s3, $s1 # s6 = s3 - s1 (0 if triple)
			bnez $s6, full_house_case2 # s6 != 0 (check case 2)
		
			sub $s6, $s5, $s4 # s6 = s5 - s4 (0 if pair)
			beqz $s6, print_full_house # is a full house
		
			full_house_case2: # s1,s2 are a pair and s3,s4,s5 are a triple
				sub $s6, $s2, $s1 # s6 = s2 - s1 (0 if a pair)
				bnez $s6, check_five_and_dime # s6 != 0 (not a full house, check five and dime)
				
				sub $s6, $s5, $s3 # s6 = s5 - s3 (0 if triple)
				beqz $s6, print_full_house # is a full house
				
		check_five_and_dime:
			li $s6, 5 # check s1 is 5
			blt $s1, $s6, check_skeet # s1 < 5 (not five and dime, check skeet)
				
			li $s6, 10 # check s5 is 10
			bgt $s5, $s6, check_skeet # s1 > 10 (not five and dime, check skeet)
			
			# check for no pairs (adjacent cards diff is not 0)
			# if pair is found check_blaze and skip skeet because skeet can't have pairs as well
			sub $s6, $s2, $s1 # s6 = s2 - s1 (!0 if not pairs)
			beqz $s6, check_blaze # a pair, check_blaze
			
			sub $s6, $s3, $s2 # s6 = s3 - s2 (!0 if not pairs)
			beqz $s6, check_blaze # a pair, check_blaze
			
			sub $s6, $s4, $s3 # s6 = s4 - s3 (!0 if not pairs)
			beqz $s6, check_blaze # a pair, check_blaze
				
			sub $s6, $s5, $s4 # s6 = s5 - s4 (!0 if not pairs)
			beqz $s6, check_blaze # a pair, check_blaze
			
			j print_five_and_dime # no pairs found print five and dime
				
		check_skeet: # 2,5,9 and 2 from {A, 
		 	li $s6, 9 # s6 = 9
		 	bgt $s5, $s6, check_blaze # s5 > s6 (not 9 high, check_blaze)
			 	
		 	# check for no pairs (adjacent cards diff is not 0)
			sub $s6, $s2, $s1 # s6 = s2 - s1 (!0 if not pairs)
			beqz $s6, check_blaze # a pair, check_blaze
			
			sub $s6, $s3, $s2 # s6 = s3 - s2 (!0 if not pairs)
			beqz $s6, check_blaze # a pair, check_blaze
			
			sub $s6, $s4, $s3 # s6 = s4 - s3 (!0 if not pairs)
			beqz $s6, check_blaze # a pair, check_blaze
			
			sub $s6, $s5, $s4 # s6 = s5 - s4 (!0 if not pairs)
			beqz $s6, check_blaze # a pair, check_blaze
			 	
		 	# check for 2: 2 cases
		 	# case 1, s1 = 2 
		 	li $s6, 2 # s6 = 2: 2 is the first card
		 	bne $s1, $s6, skeet_case2 # s1 != 2, check second case
		 	# check for 5, s2,3,4 could have 5
		 	li $s6, 5 # s5 
		 	beq $s2, $s6, print_skeet # s2 = 5 print skeet
		 	beq $s3, $s6, print_skeet # s3 = 5 print skeet			 	
		 	beq $s4, $s6, print_skeet # s4 = 5 print skeet
		 	
		 	j check_blaze # not skeet 
		 	skeet_case2: # case 2, s1 = A, s2 = 2
			 	li $s6, 2 # s6 = 2: 2 is the second card
				bne $s2, $s6, check_blaze # s1 and s2 != 2, check blaze
		 		# check for 5, s3,4 could have 5
			 	li $s6, 5 # s5 
			 	beq $s3, $s6, print_skeet # s3 = 5 print skeet			 	
		 		beq $s4, $s6, print_skeet # s4 = 5 print skeet
			 			
		check_blaze: # all cards are J, Q, and K that means J must be lowest(11)
			li $s6, 11 # s6 = 11 (J)
			beq $s1, $s6, print_blaze # s1 = s6 (J) (its a blaze)
	
		# None of the above
		la $a0, high_card_str
		
		print_poker_hand:
			li $v0, 4 # print string
			syscall
			j exit
		
		print_big_bobtail:
			la $a0, big_bobtail_str
			j print_poker_hand
		
		print_full_house:
			la $a0, full_house_str
			j print_poker_hand
	
		print_five_and_dime:
			la $a0, five_and_dime_str
			j print_poker_hand
	
		print_skeet:
			la $a0, skeet_str
			j print_poker_hand
		
		print_blaze:
			la $a0, blaze_str
			j print_poker_hand
		
		j exit # exit the program

invalid_args: # when the number of arguments is invalid for the given operation
	la $a0, invalid_args_error
    li $v0, 4 # print string
    syscall

exit:
    li $v0, 10
    syscall
