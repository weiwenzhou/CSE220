.data
plaintext_letter: .byte 'u'
letter_index: .word 3
plaintext_alphabet: .ascii "abbbbbbbbcdefffffffgggghiiijkklmnopqrstuuuuuvvvvvvwxxxxxxxxxyz\0"
ciphertext_alphabet: .ascii "StonyBrkUivesNwYadfAmcbghjlpquxzCDEFGHIJKLMOPQRTVWXZ0123456789\0"

plaintext_letter1: .byte 'p'
letter_index1: .word 46
plaintext_alphabet1: .ascii  "abcdeeefghijkkkkkkkllllllmmnoppppppppqrstuvvvvvwxyyyyzzzzzzzzz\0"

plaintext_letter2: .byte 'x'
letter_index2: .word 37
plaintext_alphabet2: .ascii "abcccccdeeeeeeeeeffffffffgghijkkklmnoppppqrstuvwxxxxxxyzzzzzzz\0"

plaintext_letter3: .byte 'n'
letter_index3: .word 15
plaintext_alphabet3: .ascii  "abccccccccdddddefghiiiiiijjjjjjjjjklmmnopqrstuvwwwwwwwxyyyyzzz\0"

plaintext_letter4: .byte 'n'
letter_index4: .word 0
plaintext_alphabet4: .ascii  "aaaaabcdeeeeeeeeefghhhhhhiijklmnnnnooooooopqrsssttttttttuvwxyz\0"
ciphertext_alphabet4: .ascii "Ilhaveyouknwtsbdmcrif20gjpqxzABCDEFGHJKLMNOPQRSTUVWXYZ13456789\0"



.macro print_char_in_v0
	move $a0, $v0 # a0 = v0
	li $v0, 1 # print int
	syscall 	
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
.end_macro

.text
.globl main
main:
 	lbu $a0, plaintext_letter
	lw $a1, letter_index
	la $a2, plaintext_alphabet
	la $a3, ciphertext_alphabet
	jal encrypt_letter
	
	# You must write your own code here to check the correctness of the function implementation.
 	print_char_in_v0
 	
	lbu $a0, plaintext_letter1
	lw $a1, letter_index1
	la $a2, plaintext_alphabet1
	la $a3, ciphertext_alphabet
	jal encrypt_letter
	print_char_in_v0

	lbu $a0, plaintext_letter2
	lw $a1, letter_index2
	la $a2, plaintext_alphabet2
	la $a3, ciphertext_alphabet
	jal encrypt_letter
	print_char_in_v0
	
	lbu $a0, plaintext_letter3
	lw $a1, letter_index3
	la $a2, plaintext_alphabet3
	la $a3, ciphertext_alphabet
	jal encrypt_letter
	print_char_in_v0
	
	lbu $a0, plaintext_letter4
	lw $a1, letter_index4
	la $a2, plaintext_alphabet4
	la $a3, ciphertext_alphabet4
	jal encrypt_letter
	print_char_in_v0
	
	li $v0, 10
	syscall
	
.include "hwk2.asm"
