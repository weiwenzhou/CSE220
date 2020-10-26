.data
.align 2
n: .word 3
.align 2
src: .ascii "ABCDEFGHIJ"
.align 2
dest: .ascii "XXXXXXX"

.text
.globl main
main:
la $a0,  dest
la $a1,  src
lw $a2,  n
jal memcpy

# Write code to check the correctness of your code!
li $v0, 10
syscall

.include "hwk4.asm"
