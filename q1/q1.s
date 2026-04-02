.section .text

# define the offsets for our struct
.equ NODE_VAL 0
.equ NODE_LEFT 4
.equ NODE_RIGHT 8
.equ NODE_SIZE 12 

.global make_node,insert,get,getAtMost
# i will use s0 to store the root's pointer

make_node:
    # val is palaced in a0
    addi sp,sp,-16
    sw a0,0(sp) # save the val on stack
    sw ra,4(sp)
    li  a0,NODE_SIZE
    call malloc
    # now i have base address of node in the a0
    lw t0,0(sp)
    lw ra,4(sp)
    addi sp,sp,16

    sw  t0,NODE_VAL(a0)
    li  t0,0
    sw  t0,NODE_LEFT(a0)
    sw  t0,NODE_RIGHT(a0)

    ret # as the base address is already in a0 , so just return

insert:
    # two parameters , first is root's address and second is value of newnode
    addi sp , sp , -16
    sw a0,0(sp) # save root's address
    sw ra,4(sp)


    li  t0,0
    bne a0,t0,notNULL
    
    mv a0,a1
    call make_node
    lw ra,4(sp)
    addi sp,sp,16
    # no need for a0 , as it's anyways zero
    ret

    notNULL:
    lw  t0,NODE_VAL(a0)
    ble t0,a1,GO_RIGHT

    # for value insertion in left subtree
    #call insert , we will get a value in a0 , that is the returned thing , and thatshould be placed in root's left

    lw  a0,NODE_LEFT(a0) # load the left's adress in first argument.
    call insert
    lw t0,0(sp)
    sw  a0,NODE_LEFT(t0)


    lw  a0,0(sp)
    lw  ra,4(sp)
    addi sp,sp,16
    ret
    

    GO_RIGHT:
    lw  a0,NODE_RIGHT(a0) # load the right's adress in first argument.
    call insert
    lw  t0,0(sp)
    sw  a0,NODE_RIGHT(t0)


    lw  a0,0(sp)
    lw  ra,4(sp)
    addi sp,sp,16
    ret

get:
    # two parameters , first is root's address and second is value of newnode
    addi sp , sp , -16
    sw ra,0(sp)


    li  t0,0
    bne a0,t0,notNULL

    lw ra,0(sp)
    addi sp,sp,16
    ret # a0 is already 0 , so just return root

    notNULL:
    
    lw t0,NODE_VAL(a0)
    bne t0,a1,leftOrRight

    lw ra,0(sp)
    addi sp,sp,16
    ret # a0 already contains the root's address
    
    leftOrRight:
    blt a1,t0,LEFT

    RIGHT:

    lw a0,NODE_RIGHT(a0)
    call get
    lw ra,0(sp)
    addi sp,sp,16
    ret

    LEFT:

    lw a0,NODE_LEFT(a0)
    call get
    lw ra,0(sp)
    addi sp,sp,16
    ret

getAtMost:
    # first argument is the val(upper bound) and second is the root

    li t0,-1 # int ans = -1
    li t1,0
    loop:
        beq a1,t1,exit

        lw t2,NODE_VAL(a1)
        blt a0,t2,goLeft

        mv t0,t2 # ans = root->val
        lw a0,NODE_RIGHT(a1)
        j loop

        goLeft:
        lw a0,NODE_LEFT(a1)
        j loop
    exit:
    mv a0,t0

    ret
