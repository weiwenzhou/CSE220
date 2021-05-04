.data
str1: .asciiz "ABCD"
str2: .asciiz "ABCGG"

.text
.globl main
main:
	la $a0,  str1
	la $a1,  str2
	jal strcmp

	# Write code to check the correctness of your code!
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall

.include "hwk4.asm"
