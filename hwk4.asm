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

initialize_hashtable:
    jr $ra

hash_book:
    jr $ra

get_book:
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
