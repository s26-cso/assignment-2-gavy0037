.section .data

fmt_yes:    .asciz "Yes\n"
fmt_no:     .asciz "No\n"
fileName:   .asciz "input.txt"
fileMode:   .asciz "r"

.section .text

.global main

main:
    addi sp,sp,-48
    sd s0,0(sp)
    sd s1,8(sp)
    sd s2,16(sp)
    sd s3,24(sp)
    sd s4,32(sp)
    sd ra,40(sp)

    # first open the file
    la a0,fileName
    la a1,fileMode
    call fopen

    #now a0 has the file pointer , save it
    mv s0,a0

    # now i need to find the end of the file
    # i am using fseek to go transfer file pointer to end of file and then ftell to find the offset to find the size of file

    #fseek(filePointer , offset , SEEK_END = 2(enum value))

    mv a0,s0 # a0 <- filePointer
    li a1,0 # a1 <- offset = 0 
    li a2,2 # seekEnd enum value = 2

    call fseek # moves the file pointer of file struct to the end of file , here a0 contains nothing so it contains 0 -> exit code of zero

    mv a0,s0 # load the file pointer to a0
    call ftell # places the file size in a0

    li s1,0 # leftPointer : 0
    addi s2,a0,-1 # right pointer: fileSize-1

    loop:
        bge s1,s2,exit # left>= right , exit

        # get the left character
        # using fseek(fp=s2,offset=leftPointer,SEEK_SET = 0)
        mv a0,s0
        mv a1,s1
        li a2,0
        call fseek

        mv a0,s0
        call fgetc
        # now a0 has left character
        mv s3,a0

        # using fseek(fp=s2,offset=rightPointer,SEEK_SET = 0)
        mv a0,s0
        mv a1,s2
        li a2,0
        call fseek

        #now a0 has 0 as exit code, now use fgetc
        mv a0,s0 # for fgetc we need filePointer as the argument
        call fgetc
        # now a0 has right character
        mv s4,a0

        # now i will compare s3 and s4

        bne s3,s4,notPalidrome
        addi s1,s1,1
        addi s2,s2,-1

        j loop
    
    exit:
        palidrome:
        la a0,fmt_yes
        call printf
        j mainExit

        notPalidrome:
        la a0,fmt_no
        call printf
        j mainExit
    
    mainExit:
    ld s0,0(sp)
    ld s1,8(sp)
    ld s2,16(sp)
    ld s3,24(sp)
    ld s4,32(sp)
    ld ra,40(sp)
    
    addi sp,sp,48
    ret
