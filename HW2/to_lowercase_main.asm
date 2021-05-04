.data
str: .ascii "Stony Brook University\0"
seperator: .ascii ": \0"

test1: .ascii "UNIVERSITY\0"
test2: .ascii "2020-2021\0"
test3: .ascii "\0"

.macro print_int_in_v0
	move $a0, $v0 # a0 = v0
	li $v0, 1 # print int
	syscall 	
	
	li $v0, 4 # print string
	la $a0, seperator
	syscall
	la $a0, str
	syscall
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
.end_macro

.text
.globl main
main:
	la $a0, str
	jal to_lowercase

	# You must write your own code here to check the correctness of the function implementation.
	print_int_in_v0
	
	la $a0, test1
	jal to_lowercase
	print_int_in_v0
	
	la $a0, test2
	jal to_lowercase
	print_int_in_v0
	
	la $a0, test3
	jal to_lowercase
	print_int_in_v0
	
	li $v0, 10
	syscall
	
.include "hwk2.asm"	
