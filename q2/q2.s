.section .data 

fmt_out: .asciz "%d "

.section .text

.global main

main:
    addi sp,sp,-64
    sd s0,0(sp)
    sd s1,8(sp)
    sd s2,16(sp)
    sd s3,24(sp)
    sd s4,32(sp)
    sd s5,40(sp)
    sd s6,48(sp)
    sd ra,56(sp)


    mv s0,a0
    mv s1,a1
    # s2 will be the stack array and s3 will be the result array
    slli a0,a0,3
    call malloc
    mv s2,a0

    mv a0,s0
    slli a0,a0,3
    call malloc
    mv s3,a0

    # current : s0 - n , s1 - base address of input array , s2 - base address of stack array , s3 - base address of result array

    li s4,-1 # stack top pointer
    addi s5,s0,-1 # iterator
    nge_loop:
        li t2,1
        blt s5, t2, exitNge

        slli t2,s5,3
        add t2,t2,s1
        ld a0,0(t2)
        call atoi

        mv s6,a0

        innerLoop:
            li t2,-1
            beq s4,t2,innerExit

            slli t2,s4,3
            add t2,t2,s2
            ld t2,0(t2)

            # t2 = st.top() i.e. the index, now get the arr[st.top()]
            slli t2,t2,3
            add t2,t2,s1
            ld t2,0(t2)

            mv a0,t2
            call atoi
            blt s6,a0,innerExit

            addi s4,s4,-1
            j innerLoop
        innerExit:
        
        li t2,-1
        beq s4,t2,emptyStack

        slli t2,s5,3
        add t2,t2,s3

        slli t3,s4,3
        add t3,t3,s2

        ld t4,0(t3)
        addi t4,t4,-1
        sd t4,0(t2)

        beq a0,a0,stackPush
        emptyStack:

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
    ld ra,56(sp)
    addi sp,sp,64

    li a0,0 #for successful exit code

    ret
