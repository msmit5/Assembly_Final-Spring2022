    .global asciiToInt
    .text

    @EXPEXTS:
    @ r0 <-- addr of str
    @ r1 <-- len of str
    @ RETURNS:
    @ r0 <-- integer
asciiToInt:
    push {r1-r10, LR}
    cmp r1, #9                  @ check for max size (highest power before overflow)
    bgt err_size
    mov r5, r0
    mov r0, #0                  @ zero accumulator

    lsl r1, #2                  @ get memory offset
    ldr r9, =pows
    mov r10, r9                 @ sentinel
    add r10, r1                 @ value to be read from

    ascii_loop:
        cmp  r10, r9           @ check sentinel
        beq  done
        ldr  r3, [r10]         @ load the power to r3
        ldrb r4, [r5]          @ load the ascii ro r4
        sub  r4, #0x30         @ convert ascii to int
        mul  r4, r3            @ multiply r4 and r3
        add  r0, r4            @ accumulate
        add  r5, #1            @ load next ascii character
        sub  r10, #4            @ load lower power
        b ascii_loop


done:
    pop {r1-r10, PC}


err_size:
    mov r0, #4
    ldr r1, =err_large_str
    ldr r2, =err_large_len
    push {r1}
    push {r2}
    b exit

    .data
pows:
pow0:   .word 0x00000000 @ 0           Sentinel
pow1:   .word 0x00000001 @ 1
pow2:   .word 0x0000000a @ 10
pow3:   .word 0x00000064 @ 100
pow4:   .word 0x000003e8 @ 1000
pow5:   .word 0x00002710 @ 10000
pow6:   .word 0x000186a0 @ 100000
pow7:   .word 0x000f4240 @ 1000000
pow8:   .word 0x00989680 @ 10000000
pow9:   .word 0x05f5e100 @ 100000000
pow10:  .word 0x3b9aca00 @ 1000000000

err_large_str: .asciz "ERROR: Num too large"
err_large_len= .-err_large_str
