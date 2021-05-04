.data
plaintext: .ascii  "2WPlU0f6FQqkvvJz4eUDyKXvbmLf1Oxa5wozIGU06dOsF9WOUoIEljICyWDcaiDmbqZ\0"
ciphertext: .ascii "Dk5wQ 1Q4RW h yLCO4XnQ 8H4 yaE'3 VpQH6 L4V a 6qGoJ6. -R3n5t 6J9GqIA\0"
keyphrase: .ascii "I'll have you know that I stubbed my toe last week and only cried for 20 minutes.\0"
corpus: .ascii "When in the Course of human events, it becomes necessary for one people to dissolve the political bands which have connected them with another, and to assume among the powers of the earth, the separate and equal station to which the Laws of Nature and of Nature's God entitle them, a decent respect to the opinions of mankind requires that they should declare the causes which impel them to the separation.\0"

ciphertext1: .asciiz "Xjc 1UN4dDn 6xXj jW5vJk WJ ORcK GmKf, PI iO4TVn, mV 0jW3 RwQREy 6mDE xKVlV1 NJ iMGqLk aDPJk aJf 2U8uHk 2Q R40 2jlJkV xK lZ. -3rUT8 RThYijc23"
keyphrase1: .asciiz "What's the difference between ignorance and apathy? I don't know and I don't care."
corpus1: .asciiz "Call me Ishmael. Some years ago - never mind how long precisely - having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen and regulating the circulation."

ciphertext2: .asciiz "L7 e1iXTTAkT 9K MCu zFxsnGH x7 F2jxZEkT Gy7P0hDo iXTI, VCfk zFqTDhjj4kT jXKP in Mwm zFqsdKG q7 zXNOEkT VCnj Rk. -2eGTuD eAbcKSDt"
keyphrase2: .asciiz "What is the sum of 12 and 37? The answer, CLEARLY, is 49!"
corpus2: .asciiz "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the season of Light, it was the season of Darkness, it was the spring of hope, it was the winter of despair, we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way - in short, the period was so far like the present period, that some of its noisiest authorities insisted on its being received, for good or for evil, in the superlative degree of comparison only."


.macro newline
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
.end_macro

.text
.globl main
main:
 	la $a0, plaintext
	la $a1, ciphertext2
	la $a2, keyphrase2
	la $a3, corpus2
	jal decrypt
	
	# You must write your own code here to check the correctness of the function implementation.
	move $s0, $v0
	move $s1, $v1
	la $a0, plaintext
	li $v0, 4
	syscall
	newline
	move $a0, $s0
	li $v0, 1
	syscall
	newline
	move $a0, $s1
	li $v0, 1
	syscall
	newline
	li $v0, 10
	syscall

	li $v0, 10
	syscall
	
.include "hwk2.asm"
