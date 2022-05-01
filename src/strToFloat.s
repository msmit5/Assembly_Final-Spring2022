    .global strToFloat
    .fpu neon-fp-armv8
    .text

    @ EXPECTS:
    @ r0 <-- addr of integral part
    @ r1 <-- len of integral part
    @ r2 <-- addr of decimal part
    @ r3 <-- len of decimal part
    @ RETURNS:
    @ r0 <-- float
strToFloat:
    push {r1-r10, LR}

    mov r5, r0
    bl asciiToInt
    push {r0}                   @ r0 has integral part

    mov r0, r2
    mov r1, r3
    bl asciiToInt

    @ Convert decimal float to decimal
    vmov s4, r0                 @ contains num
    vcvt.f32.u32 s4, s4
    ldr r7, =f10
    ldr r7, [r7]
    vmov s10, r7

    loop:
        vmul.f32 s4, s10
        sub  r1, #1
        cmp r1, #0
        bgt loop

    pop {r0}
    vmov s0, r0
    vcvt.f32.u32 s0, s0
    vadd.f32 s0, s4

    vmov r0, s0
    pop {r1-r10, PC}

    .data
f10:    .single 0.1
