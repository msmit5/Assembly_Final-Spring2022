    .global pow_float
    .fpu neon-fp-armv8

    @ EXPECTS:
    @ r0 <-- float (base)
    @ r1 <-- int (exponent)
    @
    @ NOTE: It is assumed that the exponent and base are non-negative numbers
    @
    @ RETURNS:
    @ r0 <-- float (result)
pow_float:
    push {r1-r10, LR}

    ldr r5, =one
    ldr r5, [r5]
    vmov s0, r5                 @ accumulator
    vmov s1, r0                 @ our number


    pow_loop:
        cmp r1, #0
        vmovle r0, s0
        pople {r1-r10, PC}
        vmul.f32 s0, s1
        sub r1, #1
        b pow_loop



    .data
one:    .single 1.0
