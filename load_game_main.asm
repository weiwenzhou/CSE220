.data
filename: .asciiz "game01.txt"
.align 2
state: .byte 0x05 0x0c 0x0e 0x45 0x17
.asciiz "XArg153cyIJvv2dkivJvSpka5BXf4MyeauUCg5cfQjiY6bs6BKEqE1cXtvHZ"

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
	la $s0, state

	lbu $a0, 0($s0)
	li $v0, 1
	syscall
	newline

	lbu $a0, 1($s0)
	li $v0, 1
	syscall
	newline
	
	lbu $a0, 2($s0)
	li $v0, 1
	syscall
	newline
	
	lbu $a0, 3($s0)
	li $v0, 1
	syscall
	newline
	
	lbu $a0, 4($s0)
	li $v0, 1
	syscall
	newline

	addi $a0, $s0, 5 # to get to string
	li $v0, 4 
	syscall

	li $v0, 10
	syscall

.include "hwk3.asm"
