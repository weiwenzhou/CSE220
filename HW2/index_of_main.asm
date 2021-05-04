.data
str: .ascii "CSE 220 COVID-19 Edition\0"
ch: .byte 'V'
start_index: .word 3

test_str4: .ascii "\0"
test_str5: .ascii "CSE 220\0"

test_ch2: .byte 'n'
test_ch4: .byte 'z'
test_ch5: .byte 'E'

test_index1: .word 13
test_index2: .word 5
test_index3: .word -5
test_index4: .word 0
test_index5: .word 10


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
	# "CSE 220 COVID-19 Edition\0", 'V', 3
	la $a0, str
	lbu $a1, ch
	lw $a2, start_index
	jal index_of
	
	# You must write your own code here to check the correctness of the function implementation.
	print_int_in_v0 # 10
	
	# "CSE 220 COVID-19 Edition\0", 'V', 13
	la $a0, str
	lbu $a1, ch
	lw $a2, test_index1
	jal index_of
	print_int_in_v0 # -1
	
	# "CSE 220 COVID-19 Edition\0", 'n', 5
	la $a0, str
	lbu $a1, test_ch2
	lw $a2, test_index2
	jal index_of
	print_int_in_v0 # 23
	
	# "CSE 220 COVID-19 Edition\0", 'n', -5
	la $a0, str
	lbu $a1, test_ch2
	lw $a2, test_index3
	jal index_of
	print_int_in_v0 # -1
	
	# "\0", 'z', 0
	la $a0, test_str4
	lbu $a1, test_ch4
	lw $a2, test_index4
	jal index_of
	print_int_in_v0 # -1
	
	# "CSE 220\0", 'E', 10
	la $a0, test_str5
	lbu $a1, test_ch5
	lw $a2, test_index5
	jal index_of
	print_int_in_v0 # -1
	
	li $v0, 10
	syscall
	
.include "hwk2.asm"
