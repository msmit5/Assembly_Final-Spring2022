    .global deg2rad_float,deg2rad_int
    .fpu neon-fp-armv8

    .text
    @ EXPECTS:
    @ r0 <-- integer
    @
    @ RETURNS:
    @ r0 <-- floating point result
deg2rad_int:
    push {r1-r10, LR}
    vmov s0, r0
    vcvt.f32.u32 s0, s0
    bl convert
    vmov r0, s0
    pop {r1-r10, PC}

    @ EXPECTS:
    @ r0 <-- floating point number
    @
    @ RETURNS:
    @ r0 <-- floating point result
deg2rad_float:
    push {r1-r10, LR}
    vmov s0, r0
    bl convert
    vmov r0, s0
    pop {r1-r10, PC}


    @ EXPECTS:
    @ s0 <-- floating point num
    @
    @ RETURNS:
    @ s0 <-- floating point number
    @
    @ Essentially, it just multiplies the degrees by pi/180
convert:
    push {r1-r10, LR}

    ldr  r7, =CONVERSION_CONST
    ldr  r7, [r7]
    vmov s7, r7
    vmul.f32 s0, s7

    pop {r1-r10, PC}


    .data
CONVERSION_CONST:   .single 0.01745329251 @ PI/180
