    .global getLeadingZeros,getLeadingZerosDereferenced
    .fpu neon-fp-armv8
    .text

    @ Expects:
    @ r0 <-- address of float
    @ getLeadingZeros(float* r0)
    @ Returns: r0: amount of leading 0s
getLeadingZeros:
    push {r1-r10, LR}
    ldr r2, =float10
    ldr r3, =float1
    ldr r0, [r0]
    ldr r2, [r2]
    ldr r3, [r3]

    vmov s1, r0                 @ our float
    vmov s2, r2                 @ 10
    vmov s3, r3                 @ 1
    mov r0, #0
loop:
    @ Note to future self, there was a bug where I had a vmullt here
    vmul.f32   s1, s2         @ s1 = s1 * 10
    vcmp.f32     s1, s3         @ is s1 less than 1?
    vmrs  apsr_nzcv, fpscr
    addlt r0, #1
    blt loop


    pop {r1-r10, PC}


getLeadingZerosDereferenced:
    push {r1-r10, LR}
    ldr r2, =float10
    ldr r3, =float1
    ldr r2, [r2]
    ldr r3, [r3]

    vmov s1, r0
    vmov s2, r2
    vmov s3, r3
    mov r0, #0
    b loop


.data
float10: .single 10
float1:  .single 1
