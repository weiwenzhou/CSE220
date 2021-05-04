.data
str: .ascii "College of Engineering and Applied Sciences\0"

test1: .asciiz "Wolfie Seawolf!!! 2020??" 
test2: .asciiz "MIPS"
test3: .asciiz ""

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
	la $a0, str
	jal strlen
	
	# You must write your own code here to check the correctness of the function implementation.
	# print_int_in_v0 # 43
	
	#la $a0, test1
	#jal strlen
	#print_int_in_v0 # 24
	
	#la $a0, test2
	#jal strlen
	#print_int_in_v0 # 4
	 
	#la $a0, test3
	#jal strlen
	#print_int_in_v0 # 0

	li $v0, 10
	syscall
	
.include "hwk2.asm"
