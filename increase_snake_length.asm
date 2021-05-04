.data
direction: .byte 'D'
.align 2
state:
.byte 5  # num_rows
.byte 12  # num_cols
.byte 1  # head_row
.byte 5  # head_col
.byte 7  # length
# Game grid:
.asciiz ".............a.#.1..#......#.2..#......#.3..#........4567..."

filename: .asciiz "game06.txt"

.macro newline
	li $a0, '\n'
	li $v0, 11
	syscall
.end_macro

.text
.globl main
main:
	# load game
	la $a0, state
	la $a1, filename
	jal load_game

	la $a0, state
	lbu $a1, direction
	jal increase_snake_length
	# You must write your own code here to check the correctness of the function implementation.
	move $a0, $v0
	li $v0, 1
	syscall
	newline # 6
	
	la $s0, state 
	addi $a0, $s0, 5 # to get to string
	li $v0, 4 
	syscall # 10
	
	li $v0, 10
	syscall

.include "hwk3.asm"
