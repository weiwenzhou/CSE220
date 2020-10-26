# erase this line and type your first and last name here in a comment
# erase this line and type your Net ID here in a comment (e.g., jmsmith)
# erase this line and type your SBU ID number here in a comment (e.g., 111234567)

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text
memcpy: # int memcpy(byte[] dest, byte[] src, int n)
	# a0 -> dest (at least n bytes)
	# a1 -> src
    # a2 -> num of bytes
    # => v0 -1 if n <= 0 else n
    li $v0, -1
    blez $a2, memcpy_done
    # valid n
    move $v0, $a2

    # while --n >= 0 -> copy dest[n]:t0 = src[n]:t1
    memcpy_copy:
        addi $a2, $a2, -1 # decrement
        bltz $a2, memcpy_done
        add $t0, $a0, $a2
        add $t1, $a1, $a2
        lbu $t1, 0($t1)
        sb $t1, 0($t0)
        j memcpy_copy
    
    memcpy_done:
    jr $ra

strcmp: # int strcmp(string str1, string str2)
    # a0 -> str1 null terminated
    # a1 -> str2 null terminated
    # => v0 str1[n] - str2[n] if difference else 0 if str1 === str2 
        # else str1.length if str1 != "" && str2 == "" 
        # else -str2.length if str1 == "" && str2 != ""

    # check if str1 == ""
    lbu $t0, 0($a0)
    beqz $t0, strcmp_empty_case
    lbu $t0, 0($a1)
    beqz $t0, strcmp_empty_case

    li $t9, 0 # tracker for non_empty
    j strcmp_not_empty
    strcmp_empty_case: # Note: includes both empty since they would be equal -> 0
        li $t8, 0 # length of str1
        li $t9, 0 # length of str2
        strcmp_find_str1: # find length of str1
            add $t0, $a0, $t8
            lbu $t0, 0($t0)
            beqz $t0, strcmp_find_str2 
            addi $t8, $t8, 1 # increment
            j strcmp_find_str1
            
        strcmp_find_str2: # find length of str2
            add $t0, $a1, $t9
            lbu $t0, 0($t0)
            beqz $t0, strcmp_take_diff
            addi $t9, $t9, 1 # increment
            j strcmp_find_str2

        strcmp_take_diff: 
            sub $v0, $t8, $t9
            jr $ra

    # !(one str empty) 
    strcmp_not_empty:
        add $t0, $a0, $t9
        add $t1, $a1, $t9
        lbu $t0, 0($t0)
        lbu $t1, 0($t1)
        addi $t9, $t9, 1 # increment
        
        sne $v0, $t0, $t1 # 0 if t0 == t1 else 1
        sub $t8, $t0, $t1 # 1 -> t0 != t1 -> v0 = t0 - t1
        blez $t0, strcmp_done 
        blez $t1, strcmp_done
        beqz $v0, strcmp_not_empty # 0 -> check next bit
        
    strcmp_done:
        move $v0, $t8
    jr $ra

initialize_hashtable: # int initialize_hashtable(Hashtable* hashtable, int capacity, int element_size)
    # a0 -> hashtable
    # a1 -> capacity
    # a2 -> element_size
    # -> v0 : -1 if capacity < 1 or element_size < 1  else 0
    li $v0, -1
    li $t0, 1
    blt $a1, $t0, initialize_hashtable_done # a1:capacity < 1 -> -1
    blt $a2, $t0, initialize_hashtable_done # a2:element_size < 1 -> -1

    li $v0, 0
    # initialize hashtable
    sw $a1, 0($a0) # store capacity
    sw $0,  4($a0) # store 0 in size
    sw $a2, 8($a0) # store element_size

    mul $t0, $a1, $a2 # t1 = a1*a2:num_of_bytes_to_initialize (counter)

    # while --t0 >= 0 -> a0[12+t0] = 0, t0++
    initialize_hashtable_loop:
        addi $t0, $t0, -1 # decrement
        add $t9, $a0, $t0 # t9 = a0:base + t0:offset
        sb $0, 12($t9) # store 0
        bgtz $t0, initialize_hashtable_loop

    initialize_hashtable_done:
    jr $ra

hash_book: # int hash_book(Hashtable* books, string isbn)
    # a0 -> hashtable with books
    # a1 -> 13 ASCII characters
    # -> v0: hash_funct = sum(isbn ascii character codes) mod books.capacity:books[0:4]
    
    li $v0, 0
    li $t0, 13
    # while --t0 >= 12 -> v0 += isbn[t0]
    hash_book_sum:
        addi $t0, $t0, -1 # decrement
        add $t9, $a1, $t0 # t9 = a0:base + t0:offset
        lbu $t9, 0($t9) # load ascii character
        add $v0, $v0, $t9 # sum
        bgtz $t0, hash_book_sum

    lw $t0, 0($a0) # books.capacity
    div $v0, $t0 # modulus in hi
    mfhi $v0   
    jr $ra

get_book: # int, int get_book(Hashtable* books, string isbn)
    # a0 -> hashtable with books -> s0
    # a1 -> 13 ASCII characters -> s1
    # -> v0: index if found else -1 <- s2
    # -> v1: num of times strcmp is called <- s3
    # Allocate space on stack for 5 registers (s0-5, ra)
    # s4 = element size
    # s5 = capacity
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $ra, 24($sp)

    move $s0, $a0
    move $s1, $a1
    jal hash_book # hash_book(books:a0, isbn:a1)

    move $s2, $v0 # starting index
    li $s3, 0 # num of comparison
    lw $s4, 8($s0) # get element size
    lw $s5, 0($s0) # capacity
    
    # do: s0[12+s2*s4:element_size]strcmp while loop
    get_book_loop:
        mul $a0, $s2, $s4 # offset
        add $a0, $s0, $a0 # base+offset
        addi $a0, $a0, 12 # 12 offset
        addi $s3, $s3, 1 # increment
        # check if entry is empty, deleted, or ISBN
        lb $t0, 0($a0) 
        beqz $t0, get_book_not_found
        li $t1, -1
        beq $t0, $t1, get_book_loop
        move $a1, $s1 
        jal strcmp # strcmp(current, isbn) -> v0 
        beqz $v0, get_book_done # s2,s3 if v0 == 0 
        # increment s2
        addi $s2, $s2, 1 # check next index
        seq $t0, $s2, $s5 # s2 = capacity -> $t0 === 1 else 0
        mul $t0, $t0, $s5 # capacity if t0 === 1 else 0 
        sub $s2, $s2, $t0 # s2 = s2 - t0 (to wrap around if s2 == capacity)
        blt $s3, $s5, get_book_loop # check next if s3 < capacity 
        get_book_not_found:
            li $s2, -1 # else -1, s3


    get_book_done:
        move $v0, $s2
        move $v1, $s3

    # Deallocate space on the stack 5 registers (s0-4, ra)
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 20

    jr $ra 

add_book:
    jr $ra

delete_book:
    jr $ra

hash_booksale:
    jr $ra

is_leap_year:
    jr $ra

datestring_to_num_days:
    jr $ra

sell_book:
    jr $ra

compute_scenario_revenue:
    jr $ra

maximize_revenue:
    jr $ra

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
