# First string is smaller; mismatch in middle
.data
str1: .asciiz "ABCD"
str2: .asciiz "ABCGG"

# First string is larger; mismatch in middle
.data
str1: .asciiz "WHOOP"
str2: .asciiz "WHOA"

# First string is smaller; mismatch at start
.data
str1: .asciiz "Intel"
str2: .asciiz "pentium"

# First string is larger; mismatch at start
.data
str1: .asciiz "STONY"
str2: .asciiz "BROOK"

# First string is empty
.data
str1: .asciiz ""
str2: .asciiz "mouse"

# Second string is empty
.data
str1: .asciiz "lonely guy"
str2: .asciiz ""

# Identical non-empty strings
.data
str1: .asciiz "Wolfie"
str2: .asciiz "Wolfie"

# Two empty strings
.data
str1: .asciiz ""
str2: .asciiz ""

# One argument is very short
.data
str1: .asciiz "happy"
str2: .asciiz "Z"

