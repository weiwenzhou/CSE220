# Copy some of the src buffer to dest buffer
.data
.align 2
n: .word 3
.align 2
src: .ascii "ABCDEFGHIJ"
.align 2
dest: .ascii "XXXXXXX"

# Overwrite entire dest buffer
.data
.align 2
n: .word 7
.align 2
src: .ascii "ABCDEFGHIJ"
.align 2
dest: .ascii "XXXXXXX"

# Invalid argument
.data
.align 2
n: .word -3
.align 2
src: .ascii "ABCDEFGHIJ"
.align 2
dest: .ascii "XXXXXXX"

# Invalid argument
.data
.align 2
n: .word 0
.align 2
src: .ascii "ABCDEFGHIJ"
.align 2
dest: .ascii "XXXXXXX"

