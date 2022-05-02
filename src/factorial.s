    .global fac_float,fac_int
    .fpu neon-fp-armv8

    @ EXPECTS:
    @ r0 <-- num (int)
    @
    @ RETURNS:
    @ r0 <-- result (float)
fac_float:
    push {r1-r10, LR}

    bl getIntegralPart
    @ r1 now contains the counter
    mov r0, r1
    bl fac_int

    vmov s0, r0
    vcvt.f32.u32 s0, s0         @ convert back to float
    vmov r1, s0

    pop {r1-r10, PC}


fac_int:
    push {r1-r10, LR}
    mov r1, r0

    fac_loop:
        subs r1, #1
        mulge r0, r1
        bge fac_loop

    pop {r1-r10, PC}
