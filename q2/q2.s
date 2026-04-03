.section .data 

fmt_out: .asciz "%d "

.section .text

.global main

main:
    addi sp,sp,-80
    sd s0,0(sp)
    sd s1,8(sp)
    sd s2,16(sp)
    sd s3,24(sp)
    sd s4,32(sp)
    sd s5,40(sp)
    sd s6,48(sp)
    sd s7,56(sp)
    sd ra,64(sp)

    mv s0,a0          # s0 = argc - number of arguments
    mv s1,a1          # s1 = argv - argumets , right now they are strings

    # allocate memory to integer array ( that will come from argv)
    mv a0,s0
    slli a0,a0,3
    call malloc
    mv s7,a0          # s7 = int_arr

    # memory allocate stack array (s2)
    mv a0,s0
    slli a0,a0,3
    call malloc
    mv s2,a0          # s2 = stack array

    # memory allocate result array (s3)
    mv a0,s0
    slli a0,a0,3
    call malloc
    mv s3,a0          # s3 = result array

    # pre-convert all argv strings to integers and store in s7
    li s5,1           # i = 1 as at 0 , the program name is saved
    convert_loop:
        beq s5,s0,convert_done
        slli t1,s5,3
        add t1,t1,s1
        ld a0,0(t1) # a0 = argv[i]
        call atoi   # a0 = integer value
        slli t1,s5,3
        add t1,t1,s7
        sd a0,0(t1) # arr[i] = integer value
        addi s5,s5,1
        j convert_loop
    convert_done:

    # s0 = argc, s7 = int_arr, s2 = stack, s3 = result
    li s4,-1           # stack top pointer
    addi s5,s0,-1      # iterator = argc - 1

    nge_loop:
        li t2,1
        blt s5,t2,exitNge

        # Load current value from arr[s5]
        slli t2,s5,3
        add t2,t2,s7
        ld s6,0(t2)        # s6 = int_arr[current_index]

        innerLoop:
            li t2,-1
            beq s4,t2,innerExit

            # load stack top index
            slli t2,s4,3
            add t2,t2,s2
            ld t3,0(t2)        # t3 = stack top value (an argv index)

            # load arr[stack.top()] directly
            slli t2,t3,3
            add t2,t2,s7
            ld t2,0(t2)        # arr[stack.top()]

            blt s6,t2,innerExit   # if current < stack's top value, we found the next greater

            addi s4,s4,-1
            j innerLoop
        innerExit:
        
        li t2,-1
        beq s4,t2,emptyStack

        # if stack is not empty: result[current] = stackTopIndex - 1 (convert to 0-indexed)
        slli t2,s5,3
        add t2,t2,s3

        slli t3,s4,3
        add t3,t3,s2

        ld t4,0(t3)
        addi t4,t4,-1
        sd t4,0(t2)

        beq a0,a0,stackPush
        emptyStack:

        # stack empty: result[current] = -1
        slli t2,s5,3
        add t2,t2,s3

        li t3,-1
        sd t3,0(t2)

        stackPush:

        addi s4,s4,1
        slli t3,s4,3
        add t3,t3,s2
        sd s5,0(t3)

        addi s5,s5,-1
        j nge_loop

        exitNge:

        printResult:
        li s1,1 # iterator
            loop:
                beq s1,s0,exitPrint

                slli t1,s1,3
                add t1,t1,s3

                la a0,fmt_out
                ld a1,0(t1)
                call printf

                addi s1,s1,1
                j loop
        exitPrint:

    ld s0,0(sp)
    ld s1,8(sp)
    ld s2,16(sp)
    ld s3,24(sp)
    ld s4,32(sp)
    ld s5,40(sp)
    ld s6,48(sp)
    ld s7,56(sp)
    ld ra,64(sp)
    addi sp,sp,80

    li a0,0

    ret
