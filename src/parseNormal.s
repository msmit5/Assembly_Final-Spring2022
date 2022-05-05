    .global parseNormal
    .text

    @ EXPECTS:
    @ r0 <-- pointer to string
    @ r1 <-- address of where to store A1
    @ r2 <-- address of where to store Y
    @ r3 <-- address of where to store vx
    @
    @ RETURNS
    @ NONE in registers
    @ modifies data stored at r1, r2, r3
    @ changes spaces in the
    @
    @ EXAMPLE INPUT
    @ r0 <-- *"UPDATE A1:30.0 DEGREES, Y:900.0 METERS, VX:760.0 M/S"
parseNormal:
    push {r0-r10, LR}
    push {r3}                   @ store vx loc
    push {r2}                   @ store y loc
    push {r1}                   @ store angle loc

    bl traverse
    @ r6 <-- num1
    @ r7 <-- num2
    @ r8 <-- num3

    mov r10, r0

    @ parsing angle (num1)
    mov r0, r6                  @ num1/angle
    bl verifyInputFloat
    bl strToFloat
    pop {r1}                    @ retrieve angle loc
    str r0, [r1]

    @ parsing y (num2)
    mov r0, r7                  @ num2/y
    bl verifyInputFloat
    bl strToFloat
    pop {r1}                    @ retrieve y loc
    str r0, [r1]

    mov r0, r8                  @ num3/vx
    bl verifyInputFloat
    bl strToFloat
    pop {r1}                    @ retrieve vx loc
    str r0, [r1]

    pop {r0-r10, PC}


    @ ATYPICAL RETURNS
    @ EXPECTS:
    @ r0 <-- pointer to string
    @
    @ RETURNS:
    @ r6 <-- pointer to first num
    @ r7 <-- pointer to second num
    @ r8 <-- pointer to third num
    @
    @ MODIFIES r0 IN PLACE! (changes all spaces to null bytes)
traverse:
    push {r0-r5, r9-r10, LR}
    ldr r10, =null
    ldr r10, [r10]              @ load null byte into r10
    mov r9, #1


    traverseLoop:
        ldrb r5, [r0]
        cmp r5, #0
        beq traverseLoopDone
        cmp r5, #0x3A           @ ":"
        addeq r0, #1            @ add 1 so it is now past the colon
        beq _setPointer
        cmp r5, #0x20           @ <space>
        beq storeNull
        add r0, #1
        b traverseLoop

        storeNull:
            strb r10, [r0]
            add r0, #1
            b traverseLoop


        @ thisfunction sets the correct register to the pointer
        _setPointer:
            cmp r9, #1
            moveq r6, r0
            addeq r9, #1
            beq traverseLoop
            cmp r9, #2
            moveq r7, r0
            addeq r9, #1
            beq traverseLoop
            cmp r9, #3
            moveq r8, r0
            addeq r9, #1
            beq traverseLoop
            b traverseLoop


    traverseLoopDone:
        pop {r0-r5, r9-r10, PC}

    .data
    .align 4
null:   .byte 0x00
