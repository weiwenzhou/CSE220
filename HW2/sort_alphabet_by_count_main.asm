.data
sorted_alphabet: .ascii "drfXArg153cyIJvv2dkivJvSpka"
counts: .word 28 13 24 2 28 19 12 2 0 10 23 14 3 28 1 2 21 4 4 25 29 0 9 29 13 18
			   
counts1: .word 21 17 20 25 21 19 28 26 15 16 21 13 11 16 1 27 24 20 5 23 26 2 29 15 21 9
counts2: .word 23 26 29 1 20 9 15 30 24 20 23 7 17 15 5 4 17 14 12 24 14 1 0 4 14 6

.text
.globl main
main:
	la $a0, sorted_alphabet
	la $a1, counts2
	jal sort_alphabet_by_count
	
	# You must write your own code here to check the correctness of the function implementation.
	la $a0, sorted_alphabet
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
	
.include "hwk2.asm"
