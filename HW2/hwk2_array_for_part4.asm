# erase this line and type your first and last name here in a comment
# erase this line and type your Net ID here in a comment (e.g., jmsmith)
# erase this line and type your SBU ID number here in a comment (e.g., 111234567)

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
strlen: # int strlen(string str)
	# a0 = str
	# v0 = # of character in str (int)
	li $v0, 0 # v0 = 0 -> base case
	strlen_counting_loop: # while
		lbu $t0, 0($a0)
		beqz $t0, strlen_counting_loop_end # if null terminator -> end
		addi $v0, $v0, 1 # v0 += 1 increment length count 
		addi $a0, $a0, 1 # a0 += 1 check next char
		j strlen_counting_loop 
	strlen_counting_loop_end:
    jr $ra

index_of: # int index_of(string str, char ch, int start_index)
	# a0 = str
	# a1 = ch
	# a2 = start_index
	# v0 = index of leftmost occurence after start_index
	li $v0, -1 # start at -1
	bltz $a2, index_of_done # if a2 < 0 return -1
	
	# save a0 and ra on the stack to prep call to strlen
	addi $sp, $sp, -8 # 2 registers
	sw $a0, 0($sp) # a0
	sw $ra, 4($sp) # ra
	
	jal strlen # v0 = strlen(str)
	move $t0, $v0 # t0 = v0
	
	lw $a0, 0($sp) # restore a0 and ra
	lw $ra, 4($sp) 
	addi $sp, $sp, 8
	
	li $v0, -1 # v0 = -1 if a2 > t0
	bgt $a2, $t0, index_of_done # if a2 > t0 return -1
	
	add $v0, $v0, $a2 # v0 += a2 = a2 - 1
	add $a0, $a0, $a2 # a0 += a2
	# check the string for char
	index_of_loop_string:
		addi $v0, $v0, 1 # to get to the start index from start_index - 1
		
		lbu $t1, 0($a0) # load char at index v0
		beq $a1, $t1, index_of_done # a1 = t1 return v0
		
		addi $a0, $a0, 1 # a0 += 1 
		bnez $t1, index_of_loop_string # not null terminator -> check next char in str
	li $v0, -1 # char not found return -1
		
	index_of_done:
    jr $ra

to_lowercase: # int to_lowercase(string str)
	# a0 = str
	# v0 = # of letters changed from uppercase to lowercase
	li $v0, 0 # base case v0 = 0
	li $t1, 'A' # t1 = 'A'
	li $t2, 'Z' # t2 = 'Z'
	to_lowercase_string_loop:
		lbu $t0, 0($a0) 
		beqz $t0, to_lowercase_loop_end # if null terminator -> end
		
		addi $a0, $a0, 1 # a0 += 1 next char for next iteration prep
		# check if character is uppercase 
		blt $t0, $t1, to_lowercase_string_loop # if t0 < 'A': not uppercase check next char
		bgt $t0, $t2, to_lowercase_string_loop # if t0 > 'Z': not uppercase check next char

		addi $v0, $v0, 1 # v0 += 1
		addi $t0, $t0, 32 # uppercase convert from upper to lower
		sb $t0, -1($a0) # store in its original spot
		
		j to_lowercase_string_loop
	to_lowercase_loop_end:
    jr $ra

generate_ciphertext_alphabet: # int generate_ciphertext_alphabet (string ciphertext_alphabet, string keyphrase)
	# a0 = ciphertext_alphabet
	# a1 = keyphrase
	
	# add null terminator
	sb $0, 62($a0) # add null terminator to end of ciphertext
	
	# allocate 63 bytes on the stack for the a-zA-Z0-9\0 (26+26+10)
	addi $sp, $sp, -63 # 63 bytes
	sb $0, 62($sp) # null terminator
	
	
	# add a-z
	li $t0, 'a'
	li $t1, 'z'
	move $t2, $sp # t2 = base address of the a-zA-Z0-9\0
	add_a_z_to_array:
		sb $t0, 0($t2) # store char
		addi $t0, $t0, 1
		addi $t2, $t2, 1
		ble $t0, $t1, add_a_z_to_array # t0 <= z -> add more letters
	# add A-Z
	li $t0, 'A'
	li $t1, 'Z'
	add_A_Z_to_array:
		sb $t0, 0($t2) # store char
		addi $t0, $t0, 1
		addi $t2, $t2, 1
		ble $t0, $t1, add_A_Z_to_array # t0 <= z -> add more letters
	# add 0-9
	li $t0, '0'
	li $t1, '9'
	add_0_9_to_array:
		sb $t0, 0($t2) # store char
		addi $t0, $t0, 1
		addi $t2, $t2, 1
		ble $t0, $t1, add_0_9_to_array # t0 <= z -> add more digits
	
	
	move $t0, $a1 # address to the front of the keyphrase
	move $t6, $a0 # address to the front of the ciphertext
	li $t7, 63 # use to end gen_cipher_check_char
	gen_ciphertext_alphabet_from_keyphrase:
		lbu $t1, 0($t0) 
		addi $t0, $t0, 1 # increment keyphrase
		beq $t1, $0, add_the_rest_of_letters # t1 == \0 -> keep checking keyphrase
		# check char is added
		move $t2, $sp # address to the front of the list of characters
		li $t3, 0 # counter
		gen_cipher_check_char:
			lbu $t4, 0($t2) 
			beq $t1, $t4, add_char_to_ciphertext # letter from keyphrase is not in the alphabet yet
			addi $t2, $t2, 1 # increment
			addi $t3, $t3, 1 # increment
			blt $t3, $t7, gen_cipher_check_char # t3 (counter) < 63 -> keep checking list of letters
			j gen_ciphertext_alphabet_from_keyphrase # letter is already in ciphertext -> keep checking keyphrase
			
		add_char_to_ciphertext:
			add $t2, $sp, $t3 # the index of the list of characters to change to 0
			sb $0, 0($t2)
			
			sb $t1, 0($t6) # add to ciphertext
			addi $t6, $t6, 1 # increment ciphertext
			j gen_ciphertext_alphabet_from_keyphrase
		
	# loop through list of characters and add the remaining characters
	add_the_rest_of_letters:
		move $t2, $sp # address to the front of the list of characters
		li $t0, 0 # counter
	add_the_rest_of_letters_loop:
		lbu $t1, 0($t2) 
		
		addi $t2, $t2, 1 # increment list of letters
		addi $t0, $t0, 1 # increment
		beq $t0, $t7, gen_ciphertext_done # t0 (counter) == 63
		beq $t1, $0, add_the_rest_of_letters_loop # t1 == 0 -> don't add check next
	
		# t1 != 0 and t0 < 63
		sb $t1, 0($t6) # add to ciphertext
		addi $t6, $t6, 1 # increment ciphertext
		j add_the_rest_of_letters_loop
	gen_ciphertext_done:
	# deallocate 63 bytes on the stack for the a-zA-z0-9\0
	addi $sp, $sp, 63
	
    jr $ra

count_lowercase_letters: # int count_lowercase_lettesr( int[] counts, string message)
	# arg0 = int[] counts (4 * 26 bytes)
	# arg1 = message (ascii codes between 32 and 126, inclusive)
	# v0 -> total # of lowercase letters
	li $v0, 0 # start
	# initialize arg0 to all 0s
	addi $t0, $a0, 104 # t0 = a0 (address int[]) 26*4 = 104
	
	initialize_counts_loop:
		addi $t0, $t0, -4 # next 4 bytes
		sw $0, 0($t0) # initialize to 0
		bne $t0, $a0, initialize_counts_loop # when t0 is back at the 0th index stop	
	
	count_lowercase_letters_loop:
		lbu $t0, 0($a1) # current char in lowercase
		beqz $t0, count_lowercase_letters_loop_done # null terminator -> done
		
		addi $a1, $a1, 1 # increment to next char
		
		li $t1, 'a' 
		blt $t0, $t1, count_lowercase_letters_loop # t0 < 'a' -> not lowercase check next
		li $t1 'z'
		bgt $t0, $t1, count_lowercase_letters_loop # t0 > 'z' -> not lowercase check next
		
		addi $v0, $v0, 1 # is lowercase increment v0 
		li $t1 'a' 
		sub $t0, $t0, $t1 # the position in the alphabet 'a' = 0, 'b' = 1,..., 'z' = 25
		li $t1 4
		mul $t0, $t0, $t1 # t0 = t0 * 4 to get the address
		add $t1, $a0, $t0 # t1 = a0 + t0 (base + offset)
		lw $t0, 0($t1) # load value at t1
		addi $t0, $t0, 1 # increment count by 1
		sw $t0, 0($t1) # store the count the again
		
		j count_lowercase_letters_loop
	count_lowercase_letters_loop_done:	
    jr $ra

sort_alphabet_by_count: # void sort_alphabet_by_count(string sorted_alphabet, int[] counts)
	# arg0 = sorted alphabet (27 bytes)
	# arg1 = counts (int[]: 26 * 4 bytes)
	# sort in descending order
	# initialize alphabet string
	li $t0, 'a' # first letter end at z
	li $t1, 'z' # last letter 
	move $t2, $a0 # copy of arg0 address
	initialize_alphabet_string:
		sb $t0, 0($t2) 
		addi $t0, $t0, 1 # next letter
		addi $t2, $t2, 1 # next byte
		
		ble $t0, $t1, initialize_alphabet_string  # t0 <= 'z' 
	li $t0, '\0' 
	sb $t0, 0($t2) # end string with null terminator 
	
	
	li $t0, 25 # last index to do comparisons with next
	bubble_sort_loop:
		li $t1, 0 # current position
		li $t2, 0 # number of swaps
		
		check_equality_sort_loop:
			# compare to adjacent values 
			li $t5, 4
			mul $t5, $t5, $t1 # get the proper offset for counts 4*pos
			add $t5, $a1, $t5 # address for first count 
			lw $t3, 0($t5) # t3 = first count
			lw $t4, 4($t5) # t4 = second count
			
			bge $t3, $t4, bubble_sort_check_next # t3 >= t4 -> check next
			# if t3 < t4 swap them
			sw $t3, 4($t5) 
			sw $t4, 0($t5)
			# also swap the letters
			add $t5, $a0, $t1 # t5 = a0 + t1 (base + offset)
			lbu $t3, 0($t5) # t3 = first letter
			lbu $t4, 1($t5) # t4 = second letter
			sb $t3, 1($t5) # swap the 2 letters
			sb $t4, 0($t5)
			addi $t2, $t2, 1 # increment swap counter
			
			bubble_sort_check_next:
				addi $t1, $t1, 1 # increment
				blt $t1, $t0, check_equality_sort_loop # t1 <= 25 keep checking
		
		bnez $t2, bubble_sort_loop # t2 != 0 (swaps occur: not sorted) keep sorting
		
    jr $ra

generate_plaintext_alphabet: # void generate_plaintext_alphabet(string plaintext_alphabet, string sorted_alphabet)
	# arg0 = plaintext_alphabet (27 bytes)
	# arg1 = sorted_alphabet (26 bytes + \0)
	# push to the stack to prep for indexof function call
	addi $sp, $sp, -24 # 6 registers
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $s0, $a0 # s0 = a0 address of plaintext_alphabet
	move $s1, $a1 # s1 = a1 address of sorted_alphabet
	li $s2, 'a' # first letter end at z
	li $s3, 'z' # last letter
	gen_plaintext_alphabet_loop:
		li $s4, 1 # num of bytes to write letter to 
	
		move $a0, $s1 # a0 = s1 (address of sorted_alphabet)
		move $a1, $s2 # letter to search for
		li $a2, 0 # index 0
		jal index_of # index_of(sorted_alphabet, letter, 0) -> v0
		
		li $t0, 8 
		bge $v0, $t0, write_to_bytes_s4_times # v0 >= 8 -> write to plaintext_alphabet once
		# else write s4 = s4 + t0 - v0 times
		add $s4, $s4, $t0
		sub $s4, $s4, $v0
		
		write_to_bytes_s4_times:
			sb $s2, 0($s0) 
			addi $s0, $s0, 1 # increment plaintext_alphabet
			addi $s4, $s4, -1 # decrement s4
			
			bnez $s4, write_to_bytes_s4_times # s4 != keep writing the same letter
		
		addi $s2, $s2, 1 # next letter
		ble $s2, $s3, gen_plaintext_alphabet_loop  # s2 <= 'z' 
	li $t0, '\0' 
	sb $t0, 0($s0) # end string with null terminator
	
	# pop from the stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24 # 6 registers
	
    jr $ra

encrypt_letter: # int encrypt_letter (char plaintext_letters, int letter_index, string plaintext_alphabet, string ciphertext_alphabet)
	# arg0 = plaintext_letter
	# arg1 = letter_index (non-negative)
	# arg2 = plaintext_alphabet
	# arg3 = ciphertext_alphabet
	# v0 -> encrypted letter or -1 if plaintext is not lowercase
	# push s0,s1,s2,s3, and ra to the stack 
	addi $sp, $sp, -20 # 5 registers
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	# check lowercase
	li $v0, -1 
	li $t0, 'a'
	blt $a0, $t0, letter_encryption_done # a0 < 'a' -> -1
	li $t0, 'z'
	bgt $a0, $t0, letter_encryption_done # a0 > 'z' -> -1
	
	# s0, s1, s2, s3 hold values in a0,a1,a2 a3
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# index_of ( plaintext_alphabet(s2), plaintext_letter(s0), 0)
	move $a0, $s2
	move $a1, $s0
	li $a2, 0
	jal index_of # v0 = index of first occurence of s0 
	
	# find the # of occurences of this letter
	li $t0, 0
	add $t1, $s2, $v0 # address of the current letter
	letter_encryption_count_occurences:
		lbu $t2, 0($t1) # next letter 
		bne $s0, $t2, letter_encryption_assignment # next letter is not the same as s0
		
		addi $t1, $t1, 1 # increment address
		addi $t0, $t0, 1 # increment count
		j letter_encryption_count_occurences # check next 
	
	letter_encryption_assignment:
		div $s1, $t0 
		mfhi $t0 # t0 = s1 mod t0
		add $t0, $v0, $t0 # t0 = v0 + t0 
		add $t0, $s3, $t0 # t0 = s2 + t0 (base + offset)
		lbu $v0, 0($t0) 
	
	letter_encryption_done:
	# pop from the stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20 # 5 registers
    jr $ra

encrypt: # int, int encrypt(string ciphertext, string plaintext, string keyphrase, string corpus
	# a0 = ciphertext -> s0
	# a1 = plaintext -> s1
	# a2 = keyphrase -> s2
	# a3 = corpus -> s3
	# s4 = pointer to counts (26 * 4 = 104 bytes)
	# s5 = pointer to lowercase_letters (27 bytes)
	# s6 = pointer to plaintext_alphabet (63 bytes)
	# s7 = pointer to ciphertext_alphabet (63 bytes)
	# push s0-7 and ra to the stack
	addi $sp, $sp, -36 # 9 registers
	sw $s0, 0($sp) 
	sw $s1, 4($sp) 
	sw $s2, 8($sp) 
	sw $s3, 12($sp) 
	sw $s4, 16($sp) 
	sw $s5, 20($sp) 
	sw $s6, 24($sp) 
	sw $s7, 28($sp) 
	sw $ra, 32($sp) 
	
	# save a0-3 to s0-3
	move $s0, $a0 # ciphertext
	move $s1, $a1 # plaintext
	move $s2, $a2 # keyphrase
	move $s3, $a3 # corpus
	
	move $a0, $s1
	jal to_lowercase # to_lowercase(plaintext:s1) -> int: don't need v0
	move $a0, $s3
	jal to_lowercase# to_lowercase(corpus:s3) -> int: don't need v0
	
	# allocate 26 & 4 bytes on the stack for counts: s4 = points to top of the stack after allocation
	addi $sp, $sp, -104 
	move $s4, $sp
	
	move $a0, $s4
	move $a1, $s3
	jal count_lowercase_letters # count_lowercase_letters(counts:s4, corpus:s3) -> int: don't need v0	
	# allocate 27 bytes on the stack for lowercase_letters: s5 = points to the top of the stack after allocation
	addi $sp, $sp, -28 # round up 27 to 28 
	move $s5, $sp
	
	move $a0, $s5
	move $a1, $s4
	jal sort_alphabet_by_count # sort_alphabet_by_count(lowercase_letters:s5, counts:s4) -> void
	# allocate 63 bytes on the stack for plaintext_alphabet: s6 = points to the top of the stack after allocation
	addi $sp, $sp, -64 # round up 63 to 64
	move $s6, $sp
	
	move $a0, $s6
	move $a1, $s5
	jal generate_plaintext_alphabet # generate_plaintext_alphabet(plaintext_alphabet:s6, lowercase_letters:s5) -> void
	# allocate 63 bytes on the stack for ciphertext_alphabet: s7 = points to the top of the stack after allocation
	addi $sp, $sp, -64 # round up 63 to 64
	move $s7, $sp
	
	move $a0, $s7
	move $a1, $s2
	jal generate_ciphertext_alphabet # generate_ciphertext_alphabet(ciphertext_alphabet:s7, keyphrase:s2) -> int: don't need	
	# still need s0 and s1 for parsing( ciphertext, plaintext)
	# still need s6 and s7 for encrypting a lowercase letter
	# s2-5 free to use
	# s2 = num of lowercase letters encrypted
	# s3 = num of characters from plaintext not encrypted (i.e. s2 + s3 = length of plaintext:s1)
	li $s2, 0 # starting point
	li $s3, 0 # starting point
	# s4 = for current letter: plaintext_letter
	# s5 = for current position in plaintext: letter_index
	li $s5, 0 # start at index 0
	# s6 = plaintext_alphabet
	# s7 = ciphertext_alphabet
	encryption_loop:
		add $t0, $s1, $s5 # t0 = s1 + s5 (base address of plaintext + offset)
		lbu $s4, 0($t0) # current letter to encrypt
		
		# if lowercase letter encrypt otherwise copy from plaintext to ciphertext
		li $t1, 'a'
		blt $s4, $t1, add_plaintext_character # s4 < 'a' not lowercase
		li $t1, 'z'
		bgt $s4, $t1, add_plaintext_character # s4 > 'z' not lowercase
		
		move $a0, $s4
		move $a1, $s5
		move $a2, $s6
		move $a3, $s7
		jal encrypt_letter # encrypt(plaintext_letter: s4, letter_index: s5, plaintext_alphabet: s6, ciphertext_alphabet: s7) 
		#-> int : encrypted char(v0)
		add $t0, $s0, $s5 # t0 = s0 + s5 (base address of ciphertext + offset)
		sb $v0, 0($t0)
		addi $s2, $s2, 1 # increment s2 
		j encryption_loop_next_iteration
		
		add_plaintext_character:
			add $t0, $s0, $s5 # t0 = s0 + s5 (base address of ciphertext + offset)
			sb $s4, 0($t0)
			addi $s3, $s3, 1 # increment s3
		
		encryption_loop_next_iteration:
			addi $s5, $s5, 1 # increment index 
			beqz $s4, encryption_completed_cleanup # null terminator -> done
			j encryption_loop
	
	encryption_completed_cleanup:
		addi $s3, $s3, -1 # decrement s3 (not encrypted) by 1 to account for the null terminator
		move $v0, $s2
		move $v1, $s3
	# deallocate 63 bytes on the stack for ciphertext_alphabet
	addi $sp, $sp, 64 # round up 63 to 64
	# deallocate 63 bytes on the stack for plaintext_alphabet
	addi $sp, $sp, 64 # round up 63 to 64
	# deallocate 27 bytes on the stack for lowercase_letters
	addi $sp, $sp, 28 # round up 27 to 28 
	# deallocate 26 * 4 bytes on the stack for counts
	addi $sp, $sp, 104
	# pop s0-7 and ra off the stack
	lw $s0, 0($sp) 
	lw $s1, 4($sp) 
	lw $s2, 8($sp) 
	lw $s3, 12($sp) 
	lw $s4, 16($sp) 
	lw $s5, 20($sp) 
	lw $s6, 24($sp) 
	lw $s7, 28($sp) 
	lw $ra, 32($sp)
	addi $sp, $sp, 36 # 9 registers
	
    jr $ra

decrypt:# int, int decrypt(string plaintext, string ciphertext, string keyphrase, string corpus)
	# a0 = plaintext -> s0
	# a1 = ciphertext -> s1
	# a2 = keyphrase -> s2
	# a3 = corpus -> s3
	# s4 = pointer to counts (26 * 4 = 104 bytes)
	# s5 = pointer to lowercase_letters (27 bytes)
	# s6 = pointer to plaintext_alphabet (63 bytes)
	# s7 = pointer to ciphertext_alphabet (63 bytes)
	# push s0-7 and ra to the stack
	addi $sp, $sp, -36 # 9 registers
	sw $s0, 0($sp) 
	sw $s1, 4($sp) 
	sw $s2, 8($sp) 
	sw $s3, 12($sp) 
	sw $s4, 16($sp) 
	sw $s5, 20($sp) 
	sw $s6, 24($sp) 
	sw $s7, 28($sp) 
	sw $ra, 32($sp) 
	
	# save a0-3 to s0-3
	move $s0, $a0 # plaintext
	move $s1, $a1 # ciphertext
	move $s2, $a2 # keyphrase
	move $s3, $a3 # corpus
	
	move $a0, $s3
	jal to_lowercase# to_lowercase(corpus:s3) -> int: don't need v0
	
	# allocate 26 & 4 bytes on the stack for counts: s4 = points to top of the stack after allocation
	addi $sp, $sp, -104 
	move $s4, $sp
	
	move $a0, $s4
	move $a1, $s3
	jal count_lowercase_letters # count_lowercase_letters(counts:s4, corpus:s3) -> int: don't need v0
	
	
	# allocate 27 bytes on the stack for lowercase_letters: s5 = points to the top of the stack after allocation
	addi $sp, $sp, -28 # round up 27 to 28 
	move $s5, $sp
	
	move $a0, $s5
	move $a1, $s4
	jal sort_alphabet_by_count # sort_alphabet_by_count(lowercase_letters:s5, counts:s4) -> void
	
	# allocate 63 bytes on the stack for plaintext_alphabet: s6 = points to the top of the stack after allocation
	addi $sp, $sp, -64 # round up 63 to 64
	move $s6, $sp
	
	move $a0, $s6
	move $a1, $s5
	jal generate_plaintext_alphabet # generate_plaintext_alphabet(plaintext_alphabet:s6, lowercase_letters:s5) -> void
	
	# allocate 63 bytes on the stack for ciphertext_alphabet: s7 = points to the top of the stack after allocation
	addi $sp, $sp, -64 # round up 63 to 64
	move $s7, $sp
	
	move $a0, $s7
	move $a1, $s2
	jal generate_ciphertext_alphabet # generate_ciphertext_alphabet(ciphertext_alphabet:s7, keyphrase:s2) -> int: don't need
	
	
	# still need s0 and s1 for parsing( plaintext, ciphertext)
	# still need s6 and s7 for encrypting a lowercase letter
	# s2-5 free to use
	# s2 = num of lowercase letters encrypted
	# s3 = num of characters from plaintext not encrypted (i.e. s2 + s3 = length of ciphertext:s1)
	li $s2, 0 # starting point
	li $s3, 0 # starting point
	# s4 = for current letter: ciphtertext_letter
	# s5 = for current position in ciphertext: letter_index
	li $s5, 0 # start at index 0
	# s6 = plaintext_alphabet
	# s7 = ciphertext_alphabet
	decryption_loop:	
		add $t0, $s1, $s5 # t0 = s1 + s5 (base address of ciphertext + offset)
		lbu $s4, 0($t0) # current letter to decrypt
		
		move $a0, $s7
		move $a1, $s4
		li $a2, 0
		jal index_of # index_of(ciphertext_alphabet, current char, 0) -> int : index of the decrypted letter in plaintext(v0)
		
		bltz $v0, add_ciphertext_character # < 0 (-1) not in the ciphertext alphabet add s4 to plaintext
		
		# find plaintext letter at index of
		add $t0, $s0, $s5 # t0 = s0 + s5 (base address of plaintext + offset)
		add $t1, $s6, $v0 # t1 = s6 + v0 (base address of plaintext_alphabet + offset)
		lbu $t1, 0($t1) # get char at t1
		sb $t1, 0($t0) 
		addi $s2, $s2, 1 # increment s2 
		j decryption_loop_next_iteration
		
		add_ciphertext_character:
			add $t0, $s0, $s5 # t0 = s0 + s5 (base address of plaintext + offset)
			sb $s4, 0($t0)
			addi $s3, $s3, 1 # increment s3
		
		decryption_loop_next_iteration:
			addi $s5, $s5, 1 # increment index 
			beqz $s4, decryption_completed_cleanup # null terminator -> done
			j decryption_loop
	
	decryption_completed_cleanup:
		addi $s2, $s2, -1 # decrement to account for null terminator
		move $v0, $s2
		move $v1, $s3
		
	# deallocate 63 bytes on the stack for ciphertext_alphabet
	addi $sp, $sp, 64 # round up 63 to 64
	# deallocate 63 bytes on the stack for plaintext_alphabet
	addi $sp, $sp, 64 # round up 63 to 64
	# deallocate 27 bytes on the stack for lowercase_letters
	addi $sp, $sp, 28 # round up 27 to 28 
	# deallocate 26 * 4 bytes on the stack for counts
	addi $sp, $sp, 104
	# pop s0-7 and ra off the stack
	lw $s0, 0($sp) 
	lw $s1, 4($sp) 
	lw $s2, 8($sp) 
	lw $s3, 12($sp) 
	lw $s4, 16($sp) 
	lw $s5, 20($sp) 
	lw $s6, 24($sp) 
	lw $s7, 28($sp) 
	lw $ra, 32($sp)
	addi $sp, $sp, 36 # 9 registers

    jr $ra

############################## Do not .include any files! #############################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
