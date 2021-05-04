.data
ciphertext_alphabet: .ascii "drfXArg153cyIJvv2dkivJvSpka5BXf4MyeauUCg5cfQjiY6bs6BKEqE1cXtvHZ"
keyphrase: .ascii "Stony Brook University\0"

keyphrase1: .ascii "Monday, September 21st, 2020 4:39 PM EDT\0"
keyphrase2: .ascii "suPeRcalIfrAgiListICexPiaLIdoCIOus\0"

keyphrase3: .asciiz "Stony? ?Brook? ?UniversityStony? ?Brook? ?UniversityStony? ?Brook? ?UniversityStony? ?Brook? ?UniversityMonday,? ?September? ?21st,? ?2020? ?4:39? ?PM? ?EDTMonday,? ?September? ?21st,? ?2020? ?4:39? ?PM? ?EDT"
keyphrase4: .asciiz "adfsdifgrqerjUBRFBOhiyhdouwjqoemvxmcjvbzx,DSNFOSDNF[][][[QWE[]QWE]QQWEHIHS"

arg2: .asciiz ""
arg3: .asciiz ""

.macro print_int_in_v0
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
	la $a0, ciphertext_alphabet
	la $a1, keyphrase
	la $a2, arg2
	la $a3, arg3
	jal generate_ciphertext_alphabet
	
	# You must write your own code here to check the correctness of the function implementation.
	print_int_in_v0
	
	la $a0, ciphertext_alphabet
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
	
.include "hwk2.asm"
