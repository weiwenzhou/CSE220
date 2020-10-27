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
    # Allocate space on stack for 7 registers (s0-5, ra)
    # s4 = element size
    # s5 = capacity
    addi $sp, $sp, -28
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

    # Deallocate space on the stack 7 registers (s0-5, ra)
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28

    jr $ra 

add_book: # int, int add_book(Hashtable* books, string isbn, string title, string author)
    # a0 -> hashtable of books -> s0
    # a1 -> 13 ASCII characters -> s1
    # a2 -> title string -> s2
    # a3 -> author -> s3
    # -> v0 index of added <- s4
    # -> v1 num of entries <- s5
    # s6 = element size
    # s7 = capacity

    # check if books.size[4] == books.capacity[0]
    lw $t0, 0($a0)
    lw $t1, 4($a0)
    bne $t0, $t1, add_book_not_full
    li $v0, -1
    li $v1, -1
    jr $ra

    add_book_not_full:
        # Allocate space on stack for 9 registers (s0-7, ra)
        addi $sp, $sp, -36
        sw $s0, 0($sp)
        sw $s1, 4($sp)
        sw $s2, 8($sp)
        sw $s3, 12($sp)
        sw $s4, 16($sp)
        sw $s5, 20($sp)
        sw $s6, 24($sp)
        sw $s7, 28($sp)
        sw $ra, 32($sp)

        move $s0, $a0
        move $s1, $a1
        move $s2, $a2
        move $s3, $a3


        jal get_book # get_book(books:a0, isbn:a1) -> v0: -1 (not found)
        bgez $v0, add_book_done # v0 >= 0, book is found return v0 and v1
        
        # book not found
        move $a0, $s0
        move $a1, $s1
        jal hash_book # hash_book(books:s0, isbn:s1) -> v0: index

        move $s4, $v0 # starting index
        li $s5, 0 # num of entries checked
        lw $s6, 8($s0) # element size
        lw $s7, 0($s0) # capacity

        
        add_book_find_empty_spot:
            mul $a0, $s4, $s6 # offset
            add $a0, $s0, $a0 # base+offset
            addi $a0, $a0, 12 # 12 offset
            addi $s5, $s5, 1 # increment

            # check if ISBN (must start with '9') or empty/deleted
            lbu $t0, 0($a0) # get char
            li $t1, '9'
            bne $t0, $t1, add_book_insert # empty/deleted -> add book here 
            
            # not char -> check next
            # increment s4
            addi $s4, $s4, 1 # check next index
            seq $t0, $s4, $s5 # s4 = capacity -> $t0 === 1 else 0
            mul $t0, $t0, $s5 # capacity if t0 === 1 else 0 
            sub $s4, $s4, $t0 # s4 = s4 - t0 (to wrap around if s == capacity)

            j add_book_find_empty_spot # do not have to worry about infinite loop because there will always be an empty spot 

        add_book_insert:
            # s6 = base address for the book struct to insert book in
            move $s6, $a0

            # update books.size:s0[4]++
            lw $t0, 4($s0)
            addi $t0, $t0, 1 # increment by 1
            sw $t0, 4($s0)

            # insert isbn
            move $a1, $s1
            li $a2, 13 # length of isbn 
            jal memcpy # memcpy(bookStruct:a0/s6, isbn:s1, 13) -> v0: don't care
            # increment s6 to title
            addi $s6, $s6, 14 # isbn is 14 bytes (13+null terminator) 
            # find length of title
            li $a2, 0
            li $t1, 24 # upper limit
            add_book_find_title_length:
                add $t0, $s6, $a2
                lbu $t0, 0($t0)
                beq $a2, $t1, add_book_insert_title
                beqz $t0, add_book_insert_title 
                addi $a2, $a2, 1 # increment
                j add_book_find_title_length
            add_book_insert_title: # insert title
                move $a0, $s6
                move $a1, $s2
                jal memcpy # memcpy(bookStruct:s6, title:s2, title.length) -> v0: don't care
            

            addi $s6, $s6, 25 # title is 25 bytes (24+null terminator)
            # find length of author
            li $a2, 0
            li $t1, 24 # upper limit
            add_book_find_author_length:
                add $t0, $s6, $a2
                lbu $t0, 0($t0)
                beq $a2, $t1, add_book_insert_author
                beqz $t0, add_book_insert_author 
                addi $a2, $a2, 1 # increment
                j add_book_find_author_length
            add_book_insert_author: # insert author
                move $a0, $s6
                move $a1, $s3
                jal memcpy # memcpy(bookStruct:s6, author:s3, author.length) -> v0: don't care

            move $v0, $s4 # copy s4, s5 to v0, v1
            move $v1, $s5

        add_book_done:
        # Deallocate space on the stack 9 registers (s0-7, ra)
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $s5, 20($sp)
        lw $s6, 24($sp)
        lw $s7, 28($sp)
        lw $ra, 32($sp)
        addi $sp, $sp, 36

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
