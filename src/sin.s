    .global sin
    .fpu neon-fp-armv8


    @ EXPECTS:
    @ r0 <-- input (float)
    @
    @ RETURNS:
    @ r0 <-- result (float)
sin:
    push {r1-r10, LR}
    bl sanitize
    mov r5, r0                  @ our number
    mov r6, r0                  @ accumulator. We are skipping the first iteration, which returns itself
    mov r10, #2                 @ iterator.    We are skipping the first iteration, which returns itself
    mov r7, #70               @ 2 * (MAX ITERATIONS) (35 total)
    mov r8, #2

    @ mov r5,
    @ mov r1, iterator + 1
    @ mov r2, pow
    @ mov r3, fac
    @ mov r4, getSign
    @ mov r5, x
    sinLoop:
        cmp r10, r7
        bgt sinDone
        mov r1, r10
        add r1, #1

        bl powHelper
        bl facHelper
        bl getSignHelper

        @ Move the data to the FPU for processing
        vmov s0, r0
        vmov s2, r2
        vmov s3, r3
        vmov s4, r4

        vdiv.f32 s18, s2, s3    @ s18 is temporarily being used to house the result
        vmul.f32 s18, s4        @ multiply the sign by the temporary result reg
        vadd.f32 s0, s18            @ add to the accumulator

        vmov r0, s0             @ move accumulator to r0 for preservation

        add r10, #2             @ increase iterator
        b sinLoop

    sinDone:
        pop {r1-r10, PC}


@-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-@
    @ EXPECTS:
    @ r1 <-- input (int)
    @
    @ RETURNS:
    @ r3 <-- reuslt (float)
facHelper:
    push {r0-r2,r4-r10, LR}

    vmov s0, r1                 @ move input to fpu to convert
    vcvt.f32.u32 s0, s0         @ convert the int to a float
    vmov r0, s0                 @ return to r0
    bl fac_float                @ get factorial
    mov r3, r0                  @ move into designated return register

    pop {r0-r2,r4-r10, PC}


    @ EXPECTS:
    @ r1 <-- power
    @ r5 <-- base               This is atypical. Please note
    @
    @ RETURNS:
    @ r2 <-- result
powHelper:
    push {r0,r1,r3-r10, LR}

    mov r0, r5                  @ move data to proper input for subroutine
    bl pow_float
    mov r2, r0                  @ move to proper output

    pop {r0,r1,r3-r10, PC}

    @ NOTE! This function has atypical I/O.
    @ I am only using this atypical I/O because it is only accessible by a function with standard IO
    @ EXPECTS:
    @ r10 <-- iterator
    @
    @ RETURNS
    @ R4 <-- +-1.0 (float)
getSignHelper:
    push {r0-r3, r5-r10, LR}

    mov r0, r10
    lsr r0, #1                  @ r10 = 2i. Change it from 2i to i
    tst r0, #1                  @ ands r0, #1
                                @ If even z flag is set. If odd, no flags set
                                @ EQ checks z set, NE checks z not set
    ldreq r4, =f_one            @ In this case, r0 was even
    ldrne r4, =f_neg            @ in this case, r0 was odd
    ldr r4, [r4]                @ dereference

    pop {r0-r3, r5-r10, PC}     @ return


    @ EXPECTS:
    @ r0 <-- radians (float)
    @
    @ RETURNS:
    @ r0 <-- -pi <=radians <=pi
sanitize:
    push {r1-r10, LR}

    ldr r10, =f_tau
    ldr r10, [r10]
    ldr r9,  =f_pi
    ldr r9, [r9]
    mov r8, #0

    vmov s9, r9                 @ PI
    vmov s10, r10               @ TAU
    vmov s0, r0                 @ input
    vmov s20, r8                @ zero

    vcmp.f32 s0, s20
    vmrs apsr_nzcv, fpscr
    bge san_loop_pos
    b   san_loop_neg_hlpr

    san_loop_pos:
        vcmp.f32 s0, s9             @ cmp to pi
        vmrs apsr_nzcv, fpscr   @ copy flags
        vsubgt.f32 s0, s10      @ subtract 2pi (tau)
        bgt san_loop_pos
        b sanDone

    san_loop_neg_hlpr:
        ldr r10, =f_tau
        ldr r10, [r10]
        ldr r9,  =f_npi
        ldr r9, [r9]
        b san_loop_neg


    san_loop_neg:
        vcmp.f32 s0, s9             @ cmp to pi
        vmrs apsr_nzcv, fpscr   @ copy flags
        vaddlt.f32 s0, s10      @ subtract 2pi (tau)
        blt san_loop_pos
        b sanDone



    sanDone:
        vmov r0, s0
        pop {r1-r10, PC}


    .data
    .align 4
f_one:  .single 1.0
f_neg:  .single -1.0
f_pi:   .single 3.1415926
f_npi:  .single -3.1415926
f_tau:  .single 6.2831853
f_ntau: .single -6.2831853
