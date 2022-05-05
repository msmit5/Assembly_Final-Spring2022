    .global _start
    .text

_start:
    ldr r7, =fend
    ldr r0, =farr

    ldr r0, =i3
    bl verifyInputFloat
    bl exit

loop:
    cmp r0, r7
    beq exit
    loop2:
        ldrb r5, [r0], #1
        cmp r5, #0x00
        bleq verifyInputFloat
        bne loop2
    b loop


    .data
    @ The buffer written to will be 20 bytes. Because of this, I plan on aligning the data on 20 bit boundaries
    @ This has the added benefit of allowing the strings to be swapped to in a loop :)
farr:
.byte 0x00
v1: .asciz "13.37"
v2: .asciz "445.0"
v3: .asciz "0.0000000001"
v4: .asciz "6.54321"
fend:
i1: .asciz "12"
i2: .asciz "792.168.1.1"
i3: .asciz ""
i4: .asciz "This is an invalid str"
i5: .asciz "."
