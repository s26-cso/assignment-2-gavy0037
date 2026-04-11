.section .data 

fmt_out: .asciz "%d "
fmt_out_last: .asciz "%d\n"

.section .text

.global main

main:
    # alright, saving all the registers we're gonna use onto the stack
    # sp grows downward so we make room for 10 slots (8 bytes each = 80 bytes)
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

    mv s0,a0          # s0 = argc (how many args including program name)
    mv s1,a1          # s1 = argv (pointer to the array of string pointers, still raw strings for now)

    # malloc enough space for arr — one 8-byte slot per argument
    # we're over-allocating by 1 (slot 0 unused) but that's fine, keeps indexing simple
    mv a0,s0
    slli a0,a0,3      # argc * 8 bytes
    call malloc
    mv s7,a0          # s7 = arr (our integer array, filled starting at index 1)

    # malloc for the stack array — same size, we won't ever need more slots than elements
    mv a0,s0
    slli a0,a0,3
    call malloc
    mv s2,a0          # s2 = stack (stores argv indices of elements waiting for their next greater)

    # malloc for the result array — again same size, result[i] will hold the answer for element i
    mv a0,s0
    slli a0,a0,3
    call malloc
    mv s3,a0          # s3 = result

    # convert all argv strings to integers and dump them into arr
    # start at i=1 because argv[0] is just the program name, we don't care about that
    li s5,1
    convert_loop:
        beq s5,s0,convert_done   # if i == argc, we're done converting
        slli t1,s5,3
        add t1,t1,s1
        ld a0,0(t1)              # a0 = argv[i] (the string pointer)
        call atoi                # atoi turns it into an int, result comes back in a0
        slli t1,s5,3
        add t1,t1,s7
        sd a0,0(t1)              # arr[i] = the integer we just parsed
        addi s5,s5,1
        j convert_loop
    convert_done:

    # quick register map before the main algorithm:
    # s0 = argc, s1 = (done with argv now), s2 = stack, s3 = result, s7 = arr
    # s4 = stack top pointer (starts at -1 meaning empty)
    # s5 = current index we're processing (goes from argc-1 down to 1)
    # s6 = arr[s5], the actual integer value at current index
    li s4,-1           # stack is empty to start
    addi s5,s0,-1      # start from the last element and go right to left

    nge_loop:
        li t2,1
        blt s5,t2,exitNge   # if s5 < 1 we've gone past the first real element, time to stop

        # grab the value at current index so we can compare it against the stack
        slli t2,s5,3
        add t2,t2,s7
        ld s6,0(t2)        # s6 = arr[s5]

        innerLoop:
            # if the stack is empty there's nothing to pop, just bail
            li t2,-1
            beq s4,t2,innerExit

            # peek at the index sitting on top of the stack
            slli t2,s4,3
            add t2,t2,s2
            ld t3,0(t2)        # t3 = stack.top() — this is an argv index (1-based)

            # now load the actual value that index points to in arr
            slli t2,t3,3
            add t2,t2,s7
            ld t2,0(t2)        # t2 = arr[stack.top()]

            # we want to pop while arr[stack.top()] <= arr[i]
            # so if arr[stack.top()] > arr[i], stop popping — we found the next greater for s5
            bgt t2,s6,innerExit

            # arr[stack.top()] <= arr[i], so this stack entry is useless for s5, pop it
            addi s4,s4,-1
            j innerLoop
        innerExit:

        # after the inner loop, check if the stack still has anything left
        li t2,-1
        beq s4,t2,emptyStack   # stack is empty, no next greater element exists for s5

        # stack isn't empty — the index on top is the next greater element's argv index
        # argv indices are 1-based but we want 0-indexed output, so subtract 1
        slli t2,s5,3
        add t2,t2,s3           # t2 = &result[s5]

        slli t3,s4,3
        add t3,t3,s2           # t3 = &stack[top]

        ld t4,0(t3)            # t4 = stack.top() (the argv index of the next greater element)
        addi t4,t4,-1          # convert from 1-based argv index to 0-based position
        sd t4,0(t2)            # result[s5] = that 0-based position

        j stackPush            # jump over the emptyStack block

        emptyStack:
        # no element to the right is greater, so result is -1
        slli t2,s5,3
        add t2,t2,s3           # t2 = &result[s5]
        li t3,-1
        sd t3,0(t2)            # result[s5] = -1

        stackPush:
        # push current index onto the stack so future elements (to the left) can use it
        addi s4,s4,1           # increment stack top
        slli t3,s4,3
        add t3,t3,s2
        sd s5,0(t3)            # stack[top] = s5 (current argv index)

        addi s5,s5,-1          # move to the next element on the left
        j nge_loop

    exitNge:

    # done computing, now just print result[1] through result[argc-1] separated by spaces
    printResult:
    li s1,1            # start printing from index 1 (index 0 is the unused program name slot)
        loop:
            beq s1,s0,exitPrint   # printed everything up to argc-1, we're done

            slli t1,s1,3
            add t1,t1,s3          # t1 = &result[s1]

            addi t2,s0,-1         # t2 = argc - 1
            beq s1,t2,printLast
            la a0,fmt_out         # not the last element, use "%d "
            j doPrint

            printLast:
            la a0,fmt_out_last    # last element, use "%d\n"

            doPrint:
            ld a1,0(t1)           # a1 = result[s1], the value to print
            call printf

            addi s1,s1,1
            j loop
    exitPrint:

    # restore all saved registers before leaving
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

    li a0,0   # return 0, all good
    ret
