    .global cos
    .fpu neon-fp-armv8
    .text

    @ EXPECTS:
    @ r0 <-- input
    @
    @ RETURNS <-- result
cos:
    push {r1-r10, LR}

    @ I am using a trigonometric identity
    @ confunction identity
    @ cos(x) = sin(x + pi/2)
    ldr r5, =halfpi             @ pi/2
    ldr r5, [r5]
    vmov s0, r0                 @ our data
    vmov s5, r5                 @ pi/2
    vadd.f32 s0, s5             @ implementing the trig identity
    vmov r0, s0
    bl sin                      @ Call sin to do the full identity

    pop {r1-r10, PC}

    .data
halfpi: .single 1.57079632679
