    .global verifyInputInt,verifyInputFloat
    .text

    @ INPUT:
    @ r0 <-- Head of null terminated string (or newline terminated)
    @
    @ OUTPUT:
    @ r0 <-- Head of string (unchanged)
    @ r1 <-- Length of the integral part
    @
    @ r2 <-- Head of the decimal part of the float
    @ r3 <-- Length of the decimal part of the float
verifyInputFloat:
    push {r4-r11, LR}
    ldr r10, =CANARY
    push {r10}

    ldr r10, =INTEGRAL_PART
    ldr r11, =INTEGRAL_PART
    mov r1, #0
    mov r3, #0
    mov r5, r0

    f_verifyLoop:
        ldrb  r6, [r5], #1

        @ Check if the input is a terminating character (\0 or \n)
        cmp r6, #0
        beq f_verifyDone
        cmp r6, #0x0A
        beq f_verifyDone

        cmp   r6, #0x2E          @ ascii '.'
        pusheq {r5}
        ldreq r10, =DECIMAL_PART
        moveq r2, r5            @ Assign r2 to the mem address of the number after the point (post increment means it is already that val)
        beq   f_verifyLoop

        @ Check for integer value
        subs  r6, #0x30
        bmi   verifFail
        cmp   r6, #9
        bgt   verifFail

        @ Increment proper counter
        cmp   r10, r11
        addeq r1, #1
        addne r3, #1
        b     f_verifyLoop


    @ EXPECTS:
    @ r0 <-- addr of the string
    @
    @ RETURNS:
    @ r1 <-- len of the string
verifyInputInt:
    push {r2-r10, LR}
    mov r1, #0
    mov r5, r0

    i_verifyLoop:
        ldrb  r6, [r5], #1

        @ Check if the input is a terminating character (\0 or \n)
        cmp r6, #0
        beq i_verifyDone
        cmp r6, #0x0A
        beq i_verifyDone


        @ Check for integer value
        subs r6, #0x30
        bmi  verifFail
        cmp  r6, #9
        bgt  verifFail

        add r1, #1
        b   i_verifyLoop


f_verifyDone:
    pop {r5}                    @ This should pop the "." if the data is valid
    pop {r5}                    @ This should pop the canary if the data is valid
    ldr r6, =CANARY
    cmp r5, r6
    bne verifFail

    cmp r1, #0
    cmpne r3, #0
    beq verifFail

    pop {r4-r11, PC}

i_verifyDone:
    cmp r1, #0
    beq verifFail
    pop {r2-r10, PC}


verifFail:
    mov r1, #3
    ldr r1, =err_fail_str
    ldr r2, =err_fail_len
    push {r1}
    push {r2}
    b exit_p

    .data
    @ FLAGS
    INTEGRAL_PART = 0x494E5400  @ ascii INT
    DECIMAL_PART  = 0x44454300  @ ascii DEC

CANARY: .asciz "CANARY"

err_fail_str:   .ascii "ERROR: Input is malformed!"
err_fail_len= .-err_fail_str
