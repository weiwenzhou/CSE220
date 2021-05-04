.data
ciphertext: .ascii "drfXArg153cyIJvv2dkivJvSpka5BXf4MyeauUCg5cfQjiY6bs6BKEqE1cXtvHZEn0MO"
plaintext: .ascii "never trust a computer you can't throw out a window. -steve wozniak\0"
keyphrase: .ascii "I'll have you know that I stubbed my toe last week and only cried for 20 minutes.\0"
corpus: .ascii "When in the Course of human events, it becomes necessary for one people to dissolve the political bands which have connected them with another, and to assume among the powers of the earth, the separate and equal station to which the Laws of Nature and of Nature's God entitle them, a decent respect to the opinions of mankind requires that they should declare the causes which impel them to the separation.\0"


plaintext1: .asciiz "The trouble with having an open mind, of course, is that people will insist on coming along and trying to put things in it. -Terry Pratchett"
keyphrase1: .asciiz "What's the difference between ignorance and apathy? I don't know and I don't care."
corpus1: .asciiz "Call me Ishmael. Some years ago - never mind how long precisely - having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen and regulating the circulation."

plaintext2: .asciiz "If debugging is the process of removing software bugs, then programming must be the process of putting them in. -Edsger Dijkstra"
keyphrase2: .asciiz "What is the sum of 12 and 37? The answer, CLEARLY, is 49!"
corpus2: .asciiz "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the season of Light, it was the season of Darkness, it was the spring of hope, it was the winter of despair, we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way - in short, the period was so far like the present period, that some of its noisiest authorities insisted on its being received, for good or for evil, in the superlative degree of comparison only."

.macro newline
	li $a0, '\n'
	li $v0, 11 # print newline
	syscall
.end_macro

#  n              om       o    n    h           in o           o ni k
#aaaaabcdeeeeeeeeefghhhhhhiijklmnnnnooooooopqrsssttttttttuvwxyz
#aaaaabcdeeeeeeeeefghhhhhhiijklmnnnnooooooopqrsssttttttttuvwxyz

#Ilhaveyouknwtsbdmcrif20gjpqxzABCDEFGHJKLMNOPQRSTUVWXYZ13456789
#Ilhaveyouknwtsbdmcrif20gjpqxzABCDEFGHJKLMNOPQRSTUVWXYZ13456789

.text
.globl main
main:
	li $s0, -1
 	la $a0, ciphertext
	la $a1, plaintext2
	la $a2, keyphrase2
	la $a3, corpus2
	jal encrypt
		
	# You must write your own code here to check the correctness of the function implementation.
	move $s0, $v0
	move $s1, $v1
	
	la $a0, ciphertext
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
	
.include "hwk2.asm"
