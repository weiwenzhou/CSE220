.data
start_date: .asciiz "2020-10-12"
end_date: .asciiz "2020-10-25"

.text
.globl main
main:
la $a0, start_date
la $a1, end_date
jal datestring_to_num_days

# Write code to check the correctness of your code!
li $v0, 10
syscall

.include "hwk4.asm"

