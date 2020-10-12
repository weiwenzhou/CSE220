.data
filename: .asciiz "game01.txt"
.align 2
state: .byte 0x05 0x0c 0x0e 0x45 0x17
.asciiz "XArg153cyIJvv2dkivJvSpka5BXf4MyeauUCg5cfQjiY6bs6BKEqE1cXtvHZ"

.text
.globl main
main:

la $a0, state
la $a1, filename
jal load_game

# You must write your own code here to check the correctness of the function implementation.

li $v0, 10
syscall

.include "hwk3.asm"
