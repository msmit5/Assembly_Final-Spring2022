    .global _start

    .text

_start:
    mov r0, #0
    ldr r1, =buf
    mov r2, #18
    mov r7, #3
    svc 0

    ldr r0, =buf
    bl verifyInputFloat
    @ r0-r3 is the important info
    bl strToFloat
test1:

    ldr r5, = tmp
    str r0, [r5]
    mov r0, r5

    bl writeFloat

    mov r0, #1
    ldr r1, =nl
    mov r2, #1
    mov r7, #4
    svc 0
	
    nop
    b exit

zeroBuffer:
    push {r0-r10, LR}

    ldr r0, =buf
    ldr r1, =snt
    mov r2, #0
    
    loop:
        cmp r0, r1
        popeq {r0-r10, PC}
	str r2, [r0], #1
	b loop

    .data
tmp:    .space 4
buf:    .space 32
snt: 	.space 32
nl:     .asciz "\n"
