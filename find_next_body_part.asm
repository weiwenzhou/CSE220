.data
row: .byte 4
col: .byte 5
target_part: .byte '5'
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
	lb $a1, row
	lb $a2, col
	lbu $a3, target_part
	jal find_next_body_part


	# You must write your own code here to check the correctness of the function implementation.
	move $a0, $v0
	li $v0, 1
	syscall
	newline # 6
	
	move $a0, $v1
	li $v0, 1
	syscall # 9
	
	li $v0, 10
	syscall

.include "hwk3.asm"
