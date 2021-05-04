.data
apples: .byte 3 2 1 4 4 3
apples_length: .word 3
apples2: .byte 2 5 3 5 1 4 4 3 2 9
apples_length2: .word 5
apples3: .byte 2 5 3 5 -1 -1 -1 -1 4 1 4 3 2 9
apples_length3: .word 7
.align 2
state:
.byte 5  # num_rows
.byte 12  # num_cols
.byte 1  # head_row
.byte 5  # head_col
.byte 7  # length
# Game grid:
.asciiz ".............a.#.1..#......#.2..#......#.3..#........4567..."

.macro newline
	li $a0, '\n'
	li $v0, 11
	syscall
.end_macro

.text
.globl main
main:
	la $a0, state
	la $a1, apples3
	lw $a2, apples_length3
	jal place_next_apple

	# You must write your own code here to check the correctness of the function implementation.
	move $a0, $v0
	li $v0, 1
	syscall
	newline # 6
	
	move $a0, $v1
	li $v0, 1
	syscall
	newline # 12
	
	la $s0, state 
	addi $a0, $s0, 5 # to get to string
	li $v0, 4 
	syscall # 16
	
	li $v0, 10
	syscall

.include "hwk3.asm"
