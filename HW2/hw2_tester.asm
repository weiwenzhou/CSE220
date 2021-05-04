# Main program starts here
.text
.globl main
main:
	lw $t0, op # load the address of op into t0

    beqz $t0, call_strlen # 0
    addi $t0, $t0, -1

    beqz $t0, call_index_of # 1
    addi $t0, $t0, -1

    beqz $t0, call_to_lowercase # 2
    addi $t0, $t0, -1

    beqz $t0, call_generate_ciphertext_alphabet # 3
    addi $t0, $t0, -1

    beqz $t0, call_count_lowercase_letters # 4
    addi $t0, $t0, -1

    beqz $t0, call_sort_alphabet_by_count # 5
    addi $t0, $t0, -1

    beqz $t0, call_generate_plaintext_alphabet # 6
    addi $t0, $t0, -1

    beqz $t0, call_encrypt_letter # 7
    addi $t0, $t0, -1

    beqz $t0, call_encrypt # 8
    addi $t0, $t0, -1

    beqz $t0, call_decrypt # 9
    addi $t0, $t0, -1

call_strlen:
	la $a0, arg0
	jal strlen

	j print_int_in_v0

call_index_of:
	la $a0, arg0
	lbu $a1, arg1
	lw $a2, arg2
	jal index_of

	j print_int_in_v0

call_to_lowercase:
	la $a0, arg0
	jal to_lowercase

	move $a0, $v0 # a0 = v0
	li $v0, 1 # print int
	syscall

	li $a0, '\n'
	li $v0, 11 # print newline
	syscall

	la $a0, arg0
	li $v0, 4 # print string
	syscall

	li $a0, '\n'
	li $v0, 11 # print newline
	syscall

	j exit

call_generate_ciphertext_alphabet:
	la $a0, arg0
	la $a1, arg1
	jal generate_ciphertext_alphabet

	# You must write your own code here to check the correctness of the function implementation.
	move $s0, $v0
	
	la $a0, arg0
	li $v0, 4
	syscall

	li $a0, '\n'
	li $v0, 11 # print newline
	syscall

	move $a0, $s0 # a0 = v0
	li $v0, 1 # print int
	syscall 	
	

	j exit

call_count_lowercase_letters:
	la $a0, arg0
	la $a1, arg1
	jal count_lowercase_letters

	j print_int_in_v0
	# note that this current case does not print the counts in arg0

	j exit

call_sort_alphabet_by_count:
	la $a0, arg0
	la $a1, arg1
	jal sort_alphabet_by_count

	# You must write your own code here to check the correctness of the function implementation.
	la $a0, arg0
	li $v0, 4
	syscall

	j exit

call_generate_plaintext_alphabet:
	la $a0, arg0
	la $a1, arg1
	jal generate_plaintext_alphabet

	# You must write your own code here to check the correctness of the function implementation.
	la $a0, arg0
	li $v0, 4
	syscall

	j exit

call_encrypt_letter:
	lbu $a0, arg0
	lw $a1, arg1
	la $a2, arg2
	la $a3, arg3
	jal encrypt_letter

	move $a0, $v0 # a0 = v0
	li $v0, 1 # print int
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall

	j exit

call_encrypt:
 	la $a0, arg0
	la $a1, arg1
	la $a2, arg2
	la $a3, arg3
	jal encrypt

	# You must write your own code here to check the correctness of the function implementation.
	move $s0, $v0
	move $s1, $v1

	la $a0, arg0
	li $v0, 4
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
	move $a0, $s0
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
	move $a0, $s1
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall

	j exit

call_decrypt:
	la $a0, arg0
	la $a1, arg1
	la $a2, arg2
	la $a3, arg3
	jal decrypt

	# You must write your own code here to check the correctness of the function implementation.
	move $s0, $v0
	move $s1, $v1
	la $a0, arg0
	li $v0, 4
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
	move $a0, $s0
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
	move $a0, $s1
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall

	j exit

print_int_in_v0:
	move $a0, $v0 # a0 = v0
	li $v0, 1 # print int
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
	j exit

exit:
    li $v0, 10
    syscall

.include "hwk2.asm"
