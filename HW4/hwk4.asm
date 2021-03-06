# Wei Wen Zhou
# WEIWEZHOU
# 112928274

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
        beq $t0, $t1, get_book_increment
        move $a1, $s1 
        jal strcmp # strcmp(current, isbn) -> v0 
        beqz $v0, get_book_done # s2,s3 if v0 == 0 
        get_book_increment: # increment s2
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

            # zero out the next 68 bytes from s6
            li $t0, 68
            add_book_insert_zeroes: # while t0 > 0 -> s6[t0] = 0
                addi $t0, $t0, -1
                add $t1, $s6, $t0 # t1 = base:s6+offset
                sb $0, 0($t1) 
                bgtz $t0, add_book_insert_zeroes

            # insert isbn
            move $a1, $s1
            li $a2, 13 # length of isbn 
            jal memcpy # memcpy(bookStruct:a0/s6, isbn:s1, 13) -> v0: don't care
            # increment s6 to title
            addi $s6, $s6, 14 # isbn is 14 bytes (13+null terminator) 
            sb $0, -1($s6) # null terminate the 14th byte
            # find length of title
            li $a2, 0
            li $t1, 24 # upper limit
            add_book_find_title_length:
                add $t0, $s2, $a2
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
            sb $0, -1($s6) # null terminate
            # find length of author
            li $a2, 0
            li $t1, 24 # upper limit
            add_book_find_author_length:
                add $t0, $s3, $a2
                lbu $t0, 0($t0)
                beq $a2, $t1, add_book_insert_author
                beqz $t0, add_book_insert_author 
                addi $a2, $a2, 1 # increment
                j add_book_find_author_length
            add_book_insert_author: # insert author
                move $a0, $s6
                move $a1, $s3
                jal memcpy # memcpy(bookStruct:s6, author:s3, author.length) -> v0: don't care

            sb $0, 24($s6) # null terminate
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

delete_book: # int delete_book(Hashtable* books, string isbn)
    # a0 -> hashtable of books -> s0
    # a1 -> isbn
    # -> v0 -> from get_book(v0)
    # Allocate space on the stack 2 registers (s0, ra)
    addi $sp, $sp, -8
    sw $s0, 0($sp)
    sw $ra, 4($sp)

    move $s0, $a0
    jal get_book # get_book(books:a0, isbn:a1)
    bltz $v0, delete_book_done

    # book found need to delete
    # decrement size
    lw $t0, 4($s0)
    addi $t0, $t0, 1
    sw $t0, 4($s0)

    lw $t0, 8($s0) # element size
    mul $t0, $t0, $v0 # element size*v0
    addi $t0, $t0, 12 # offset to front elements
    add $t0, $t0, $s0 # book struct to delete

    li $t1, -1
    li $t2, 0 
    li $t3, 68 # 68 to -1 out
    # while t2 < t3 -> t0[t2] = -1
    delete_book_loop:
        add $t4, $t0, $t2 # t4 = base + offset
        sb $t1, 0($t4) 
        addi $t2, $t2, 1 # increment
        blt $t2, $t3, delete_book_loop



    delete_book_done:
    # Deallocate space on the stack 2 registers (s0, ra)
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

hash_booksale:# int hash_booksale(Hashtable* sales, string isbn, int customer_id)
    # a0 -> hashtable with sales
    # a1 -> 13 ASCII characters
    # a2 -> customer_id
    # -> v0: hash_funct = sum(isbn ascii character codes)+sum(digits of customer_id) mod sales.capacity:sales[0:4]
    
    li $v0, 0
    li $t0, 13
    # while --t0 >= 12 -> v0 += isbn[t0]
    hash_booksale_sum:
        addi $t0, $t0, -1 # decrement
        add $t9, $a1, $t0 # t9 = a0:base + t0:offset
        lbu $t9, 0($t9) # load ascii character
        add $v0, $v0, $t9 # sum
        bgtz $t0, hash_booksale_sum

    li $t0, 10
    hash_booksale_digits:
        div $a2, $t0
        mflo $a2 # dividend 
        mfhi $t1 # remainder
        add $v0, $v0, $t1 
        bnez $a2, hash_booksale_digits

    lw $t0, 0($a0) # sales.capacity
    div $v0, $t0 # modulus in hi
    mfhi $v0  
    jr $ra

is_leap_year: # int is_leap_year(int year) 
    # a0 -> year
    # -> v0: 0 if year < 1582, 1 if year is leap_year else num_of_years_until_leap_year
    li $v0, 0
    li $t0, 1582
    blt $a0, $t0, is_leap_year_done # a0 < 1582:t0

    # check if leap year
    li $v0, 1
    li $t0, 400
    div $a0, $t0
    mfhi $t0
    beqz $t0, is_leap_year_done # if divisible by 400 -> leap year
    li $t0, 100
    div $a0, $t0
    mfhi $t0
    beqz $t0, not_leap_year # divisible by 100 but not 400 -> not a leap year
    li $t0, 4
    div $a0, $t0
    mfhi $t0
    beqz $t0, is_leap_year_done # divisible by 4 but not 400 or 100 -> year
    # not a leap year
    not_leap_year:
        li $v0, 0
        find_leap_year:
            addi $a0, $a0, 1 
            addi $v0, $v0, -1
            li $t0, 400
            div $a0, $t0
            mfhi $t0
            beqz $t0, is_leap_year_done # if divisible by 400 -> leap year
            li $t0, 100
            div $a0, $t0
            mfhi $t0
            beqz $t0, find_leap_year # divisible by 100 but not 400 -> not a leap year
            li $t0, 4
            div $a0, $t0
            mfhi $t0
            beqz $t0, is_leap_year_done # divisible by 4 but not 400 or 100 -> year
            j find_leap_year

    is_leap_year_done:
    jr $ra

datestring_to_num_days: # int datestring_to_num_days(string start_date, string end_date)
    # a0: start_date YYYY-MM-DD that is 1600-01-01 or later -> s0
    # a1: end_date YYYY-MM-DD that is 1600-01-01 or later -> s1
    # -> v0: num of days elapsed
    
    # check years for quick error
    li $t9, 1000
    li $t2, 0 # year for start
    li $t3, 0 # year for end
    lbu $t0, 0($a0)
    lbu $t1, 0($a1) 
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    mul $t0, $t0, $t9
    mul $t1, $t1, $t9
    add $t2, $t2, $t0
    add $t3, $t3, $t1
    li $t9, 100 # hundreds place 
    lbu $t0, 1($a0)
    lbu $t1, 1($a1) 
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    mul $t0, $t0, $t9
    mul $t1, $t1, $t9
    add $t2, $t2, $t0
    add $t3, $t3, $t1
    li $t9, 10 # tens
    lbu $t0, 2($a0)
    lbu $t1, 2($a1) 
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    mul $t0, $t0, $t9
    mul $t1, $t1, $t9
    add $t2, $t2, $t0
    add $t3, $t3, $t1
    lbu $t0, 3($a0) # ones
    lbu $t1, 3($a1) 
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    add $t2, $t2, $t0
    add $t3, $t3, $t1

    li $v0, -1
    bgt $t2, $t3, datestring_to_num_days_done # if t2 > t3 -> error

    # Allocate space on the stack for 9 registers (s0-7, ra)
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

    move $s2, $t2 # start year
    move $s3, $t3 # end year
    move $s5, $a0 # copy of start date
    move $s6, $a1 # copy of end date
    li $s4, 1600 

    li $t0, 366
    sgt $s0, $s2, $s4 # if s2 > 1600 -> s0 = 366 else 0
    mul $s0, $s0, $t0
    sgt $s1, $s3, $s4 # if s3 > 1600 -> s1 = 366 else 0
    mul $s1, $s1, $t0
    
    addi $s4, $s4, 1 # s4 = 1601
    year_to_days: # while s2 < s4 or s3 < s4 
        move $a0, $s4 
        jal is_leap_year # is_leap_year(s4) -> ignored 0, 1 should not be returned
        # v0 = -(years until leap year)
        li $t9, 365
        add_days_per_year: # while v0 < 0
            
            sgt $t0, $s2, $s4 # if s2 > s4 -> s0 += 365 
            mul $t0, $t0, $t9
            add $s0, $s0, $t0
            sgt $t1, $s3, $s4 # if s3 > s4 -> s1 += 365 
            mul $t1, $t1, $t9
            add $s1, $s1, $t1 

            addi $v0, $v0, 1 # increment 
            addi $s4, $s4, 1 # increment

            bltz $v0, add_days_per_year
            # when v0 == 0 it is a leap year -> t9 = 366
            li $t9, 366
            blez $v0, add_days_per_year
        blt $s4, $s2, year_to_days
        blt $s4, $s3, year_to_days

    # use s4 to track leap year for start date
    move $a0, $s2
    jal is_leap_year # is_leap_year(start year) -> s4 = v0
    move $s4, $v0
    # use s7 to track leap year for end date
    move $a0, $s3
    jal is_leap_year # is_leap_year(end year) -> s4 = v0
    move $s7, $v0

    # get the month of start and end and store in s2,s3
    li $s2, 0
    li $s3, 0
    li $t9, 10 # tens
    lbu $t0, 5($s5)
    lbu $t1, 5($s6) 
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    mul $t0, $t0, $t9
    mul $t1, $t1, $t9
    add $s2, $s2, $t0
    add $s3, $s3, $t1
    lbu $t0, 6($s5) # ones
    lbu $t1, 6($s6) 
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    add $s2, $s2, $t0
    add $s3, $s3, $t1

    # month to date
    li $t2, 28
    li $t3, 1
    li $t4, 30
    li $t5, 31
    # 1->2: 31
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t5
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t5
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    # 2->3: 28/29
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    sgt $t8, $s4, $0 # if s4 > 0-> leap 
    mul $t8, $t0, $t8 # 1 * 1 / 0 * 0,1 ; 1 * 0
    mul $t0, $t0, $t2
    add $s0, $s0, $t8
    add $s0, $s0, $t0

    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    sgt $t8, $s7, $0 # if s7 > 0-> leap
    mul $t8, $t1, $t8 # 1 * 1 / 0 * 0,1 ; 1 * 0
    mul $t1, $t1, $t2
    add $s1, $s1, $t8
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    # 3->4: 31
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t5
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t5
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    # 4->5: 30
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t4
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t4
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    # 5->6: 31
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t5
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t5
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    # 6->7: 30
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t4
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t4
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    # 7->8: 31
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t5
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t5
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    # 8->9: 31
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t5
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t5
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    # 9->10: 30
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t4
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t4
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    #10->11: 31
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t5
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t5
    add $s1, $s1, $t1 
    addi $t3, $t3, 1
    #11->12: 30
    sgt $t0, $s2, $t3 # if s2 > 1:t3 -> add
    mul $t0, $t0, $t4
    add $s0, $s0, $t0
    sgt $t1, $s3, $t3 # if s3 > 1:t3 -> add
    mul $t1, $t1, $t4
    add $s1, $s1, $t1 

    # get the date field and add to s0, s1
    li $t9, 10 # tens
    lbu $t0, 8($s5)
    lbu $t1, 8($s6) 
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    mul $t0, $t0, $t9
    mul $t1, $t1, $t9
    add $s0, $s0, $t0
    add $s1, $s1, $t1
    lbu $t0, 9($s5) # ones
    lbu $t1, 9($s6) 
    addi $t0, $t0, -48
    addi $t1, $t1, -48
    add $s0, $s0, $t0
    add $s1, $s1, $t1

    # if s0 > s1 : error return -1
    sub $v0, $s1, $s0 # else return s1 - s0
    bgez $v0, datestring_to_num_days_deallocate
    # v0 < 0 -> return -1
    li $v0, -1

    datestring_to_num_days_deallocate:

    # Deallocate space on the stack for 9 registers (s0-7, ra)
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
    datestring_to_num_days_done:
    jr $ra

sell_book: # int, int sell_book(Hashtable* sales, Hashtable* books, string isbn, int customer_id, string sale_date, int sale_price)
    # a0: hashtable of sales -> s0
    # a1: hashtable of books -> s1
    # a2: 13 ASCII characters -> s2
    # a3: customer id -> s3
    # 0($sp): sale_date -> s4
    # 4($sp): sale_price -> s5

    # check if sales[0]:capacity === sales[4]:size
    lw $t0, 0($a0)
    lw $t1, 4($a0)
    bne $t0, $t1, sell_book_not_full
    li $v0, -1
    li $v1, -1
    jr $ra

    sell_book_not_full:
        # save sale_date and sale_price
        lw $t0, 0($sp)
        lw $t1, 4($sp)

        # allocate space on the stack for 7 registers(s0-5, ra)
        addi $sp, $sp, -28
        sw $s0, 0($sp)
        sw $s1, 4($sp)
        sw $s2, 8($sp)
        sw $s3, 12($sp)
        sw $s4, 16($sp)
        sw $s5, 20($sp)
        sw $ra, 24($sp)

        # saving arguments in s registers 
        move $s0, $a0 # sales
        move $s1, $a1 # books
        move $s2, $a2 # isbn
        move $s3, $a3 # c_id
        move $s4, $t0 # sale_date
        move $s5, $t1 # sale_price
        
        # check if isbn is in books
        move $a0, $s1
        move $a1, $s2
        jal get_book # get_book(books:s1, isbn:s2)
        bgez $v0, sell_book_is_found
        # if v0 == -1 (< 0) then book not found -> -2, -2
        li $v0, -2
        li $v1, -2
        j sell_book_done

        sell_book_is_found: # if book is found then search for 
            # increment times sold for books[12+element_size*v0(index)+64]
            lw $t0, 8($s1) # element_size for books
            mul $t0, $t0, $v0 # t0 = t0:element_size * v0:index
            add $t0, $t0, $s1 
            lw $t1, 76($t0) # 76 is offset for books.element[v0].times_sold
            addi $t1, $t1, 1 # increment
            sw $t1, 76($t0) # store incremented value

            # now add new sales
            move $a0, $s0
            move $a1, $s2
            move $a2, $s3
            jal hash_booksale # hash_booksale(sales:s0, isbn:s2, c_id:s3) # v0 = index

            # no longer need to keep address for books:s1
            move $s1, $v0 # use $s1 to store v0 (index) for v0
            lw $t8 0($s0) # capacity for sales
            li $t9, 0 # for v1
        
            sell_book_add_sale:
                # sales[12+element_size*v0(index)]
                lw $t0, 8($s0) # element_size for sales
                mul $t0, $t0, $s1 # t0 = t0:element_size * s1:index
                add $t0, $s0, $t0 # front of index if offset by 12
                addi $t0, $t0, 12 # offset 12
                lbu $t1, 0($t0) # offset 12 
                addi $t9, $t9, 1 # increment

                beqz $t1, sell_book_insert # if 0 -> insert 

                # increment s4
                addi $s1, $s1, 1 # check next index
                seq $t0, $s1, $t8 # s1 = capacity -> $t0 === 1 else 0
                mul $t0, $t0, $t8 # capacity if t0 === 1 else 0 
                sub $s1, $s1, $t0 # s1 = s1 - t0 (to wrap around if s == capacity)

                j sell_book_add_sale # don't need to worry about an infinite loop because there is guarantee a spot open
            
            sell_book_insert: 
                move $s0, $t0 # address of sales.element to modify is in t0 move to s0
                # insert isbn
                move $a0, $s0
                move $a1, $s2
                li $a2, 13
                move $s2, $t9 # don't need to keep isbn in s2 after memcpy
                jal memcpy # memcpy(s0, isbn:s2, 13)

                # empty = all 0s don't need to null terminate

                # convert sales date to date since 1600-01-01 using datestring_to_num_days
                # allocate 12 bytes on the stack to store 1600-01-01\0\0
                addi $sp, $sp, -12
                li $t0, '1'
                sb $t0, 0($sp) # 1xxxxxxxxxxx
                sb $t0, 6($sp) # 1xxxxx1xxxxx
                sb $t0, 9($sp) # 1xxxxx1xx1xx
                li $t0, '0'
                sb $t0, 2($sp) # 1x0xxx1xx1xx
                sb $t0, 3($sp) # 1x00xx1xx1xx
                sb $t0, 5($sp) # 1x00x01xx1xx
                sb $t0, 8($sp) # 1x00x01x01xx
                li $t0, '6'
                sb $t0, 1($sp) # 1600x01x01xx
                li $t0, '-'
                sb $t0, 4($sp) # 1600-01x01xx
                sb $t0, 7($sp) # 1600-01-01xx
                sb $0, 10($sp) # 1600-01-01\0x
                sb $0, 11($sp) # 1600-01-01\0\0

                move $a0, $sp
                move $a1, $s4
                jal datestring_to_num_days # datestring_to_num_days(1600-01-01:stack, sale_date:s4)
                addi $sp, $sp, 12 # deallocate space on stack

                sw $s3, 16($s0) # insert c_id:s3 to s0[16]
                sw $v0, 20($s0) # copy $v0 to s0[20]
                sw $s5, 24($s0)# insert sale_price:s5 to s0[24]

                move $v0, $s1
                move $v1, $s2

        sell_book_done:
        # deallocate space on the stack for 7 registers(s0-5, ra)
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $s5, 20($sp)
        lw $ra, 24($sp)
        addi $sp, $sp, 28

    jr $ra
compute_scenario_revenue: # int compute_scenario_revenue(BookSale[] sales_list, int num_sales, int scenario)
    # a0: array of BookSales
    # a1: length of sales_list and the number of relevant bits(from right) from scenario 
    # a2: 32 bit 
    
    # a0 points to the first
    # t0 points to the last element in the array
    addi $a1, $a1, -1 # index of last element = len-1
    li $t0, 28
    mul $t0, $a1, $t0 
    add $t0, $a0, $t0 # last element in the array

    li $t1, 1 # t1 for and-ing
    sllv $t1, $t1, $a1
    li $t2, 0 # t2 is a counter
    li $v0, 0 # start and accumulator
    compute_scenario_revenue_loop: 
        # while t1 != 0 -> add price of a0 if t1 & a2 == 0 else add price of t0
        beqz $t1, compute_scenario_revenue_done # t1 == 0 -> done
        and $t3, $t1, $a2

        srl $t1, $t1, 1 # shift 1 right
        addi $t2, $t2, 1 # increment
        beqz $t3, compute_scenario_revenue_add_front # add price of a0 and increment

        lw $t4, 24($t0)
        mul $t4, $t4, $t2 # t4 = price:t4 * day#:t2
        add $v0, $v0, $t4
        addi $t0, $t0, -28 # decrement
        j compute_scenario_revenue_loop
        compute_scenario_revenue_add_front:
            lw $t4, 24($a0)
            mul $t4, $t4, $t2 # t4 = price:t4 * day#:t2
            add $v0, $v0, $t4
            addi $a0, $a0, 28 # increment
            j compute_scenario_revenue_loop
    compute_scenario_revenue_done:
    jr $ra

maximize_revenue: # int maximize_revenue(BookSale[] sales_list, int num_sales)
    # a0: array of BookSale -> s0
    # a1: number of sales in sales_list -> s1
    # -> v0: maximum revenue : s3
    # s2 <- scenario
    # Allocate space on the stack for 5 registers (s0-3, ra) 
    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)

    move $s0, $a0
    move $s1, $a1
    li $s2, 1
    sllv $s2, $s2, $s1 
    addi $s2, $s2, -1 # start off at 2^n-1 
    li $s3, 0 # 0 is lowest

    maximize_revenue_find_max:
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        jal compute_scenario_revenue # compute_scenario_revenue(sales_list:s0, num_sales:s1, scenario:s2)
        addi $s2, $s2, -2 # decrement s2 (last bit doesn't matter)
    
        # s3 = s3 if v0 < s3 else v0
        ble $v0, $s3, maximize_revenue_find_max_next # v0 <= s3 -> don't change s3
        move $s3, $v0 # v0 > s3 -> update s3 to be v0

        maximize_revenue_find_max_next:
            bgez $s2, maximize_revenue_find_max
    
    move $v0, $s3 
    # Deallocate space on the stack for 5 registers (s0-3, ra) 
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
