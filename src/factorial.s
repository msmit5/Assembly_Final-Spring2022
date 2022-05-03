    .global fac_float,fac_int,fac_int2float
    .fpu neon-fp-armv8

    @ EXPECTS:
    @ r0 <-- num (float)
    @
    @ RETURNS:
    @ r0 <-- result (float)
fac_float:
    push {r1-r10, LR}

    bl getIntegralPart
    @ r1 now contains the counter (integral part of the fac)

    vmov s0, r0
    vmov s1, r0
    ldr r7, =uno
    ldr r7, [r7]
    vmov s7, r7

    fac_loop_float:
        sub r1, #1
        vsub.f32 s1, s7         @ subtract 1 from s1
        @ vmrs fpscr, apsr_nzcv   @ move flags to fpcu (does not work)
        cmp r1, #1

        @ I am doing this because I don't know how to move the arm flags to the coprocessor
        bge fac_loop_float_doThing

    vmov r0, s0

    pop {r1-r10, PC}


    @ EXPECTS:
    @ r0 <-- num (int)
    @
    @ RETURNS
    @ r0 <-- num (float)

fac_int2float:
    push {r1-r10, LR}

    bl fac_int

    @ convert to float
    vmov s0, r0
    vcvt.f32.u32 s0, s0
    vmov r0, s0

    pop {r1-r10, PC}

fac_int:
    push {r1-r10, LR}
    mov r1, r0

    fac_loop:
        sub r1, #1
        cmp r1, #1
        mulge r0, r1
        bge fac_loop

    pop {r1-r10, PC}

    @ see fac_float
fac_loop_float_doThing:
    vmulge.f32 s0, s1
    b fac_loop_float


    .data
uno:    .single 1.0             @ I have added this constant too many times... :/
