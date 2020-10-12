.data
head_row_delta: .byte -1
head_col_delta: .byte 0
apples: .byte 1 7 3 2 1 4 4 3
apples_length: .word 4
.align 2
state:
.byte 8  # num_rows
.byte 14  # num_cols
.byte 4  # head_row
.byte 5  # head_col
.byte 15  # length
# Game grid:
.asciiz "....................##......................#..a.....#....#..1234..#..........56...E......##.7..CD.........89AB."

.macro newline
	li $a0, '\n'
	li $v0, 11
	syscall
.end_macro

.text
.globl main
main:
	la $a0, state
	lb $a1, head_row_delta
	lb $a2, head_col_delta
	la $a3, apples
	addi $sp, $sp, -4
	lw $t0, apples_length
	sw $t0, 0($sp)
	li $t0, 7918273    # putting some random garbage in $t0
	jal slide_body
	addi $sp, $sp, 4

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
