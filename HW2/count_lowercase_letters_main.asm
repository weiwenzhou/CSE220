.data
counts: .word -890186 -438641 -817157 612618 -145953 -440997 -774137 758469 889951 834642 -919986 -204919 124497 179267 -303331 -285295 786955 -891155 -665164 -716764 -292806 176422 -299979 471550 -485856 -656536
message: .ascii "The specialization in artificial intelligence and data science emphasizes modern approaches for building intelligent systems using machine learning.\0"

test1: .ascii "We can only see a short distance ahead, but we can see plenty there that needs to be done. -Alan Turing\0"

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
	la $a0, counts
	la $a1, test1
	jal count_lowercase_letters

	# You must write your own code here to check the correctness of the function implementation.
	print_int_in_v0
	
	li $v0, 10
	syscall
	
.include "hwk2.asm"
