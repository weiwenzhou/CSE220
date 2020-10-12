.data
filename: .asciiz "game02.txt"
.align 2
state: .byte 0 0 0 0 0
.asciiz "XArg153cyIJvv2dkivJvSpka5BXf4MyeauUCg5cfQjiY6bs6BKEqE1cXtvHZ"

#state: .byte 0x05 0x0c 0x0e 0x45 0x17
#.asciiz "XArg153cyIJvv2dkivJvSpka5BXf4MyeauUCg5cfQjiY6bs6BKEqE1cXtvHZ"

.macro newline
	li $a0, '\n'
	li $v0, 11
	syscall
.end_macro

.text
.globl main
main:
	la $a0, state
	la $a1, filename
	jal load_game

	# You must write your own code here to check the correctness of the function implementation.
	move $t0, $v0 
	move $t1, $v1
	
	la $s0, state # 3
	
	lbu $a0, 0($s0)
	li $v0, 1
	syscall
	newline # 9

	lbu $a0, 1($s0)
	li $v0, 1
	syscall
	newline # 15
	
	lbu $a0, 2($s0)
	li $v0, 1
	syscall
	newline # 21
	
	lbu $a0, 3($s0)
	li $v0, 1
	syscall
	newline # 27
	
	lbu $a0, 4($s0)
	li $v0, 1
	syscall
	newline # 33

	addi $a0, $s0, 5 # to get to string
	li $v0, 4 
	syscall
	newline # 39

	move $a0, $t0
	li $v0, 1
	syscall
	newline # 45
	
	move $a0, $t1
	li $v0, 1
	syscall
	newline # 51

	li $v0, 10
	syscall # 53

.include "hwk3.asm"
