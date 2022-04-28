.global getIntegralPart,getDecimalPart,getParts
.fpu neon-fp-armv8
.text

    @ Expects:
    @ r0 <-- float

    @ Reurns:
    @ r1 <-- integer
getIntegralPart:
    push {r0, r2-r10, LR}

    vmov s0, r0
    vcvt.s32.f32 s1, s0         @ Convert float s1 (r0) into an integer
    vmov r1, s1

    pop {r0, r2-r10, PC}


    @ Expects:
    @ r0 <-- float

    @ Reurns:
    @ r1 <-- float (no integral part)
getDecimalPart:
    push {r0, r2-r10, LR}

    bl getIntegralPart
    @ r1 <-- integer part of r0
    vmov s1, r1
    vmov s0, r0
    vcvt.f32.s32 s1, s1         @ Convert the int to a float
    vsub.f32 s1, s0, s1         @ remove the integer part ex: (0.14 = 3.14 - 3.0)
    vmov r1, s1

    pop {r0, r2-r10, PC}

    @ Expects:
    @ r0 <-- float

    @ Reurns:
    @ r1 <-- integral part
    @ r2 <-- decimal part
    @ TODO Make more efficient
    @ This can be done by removing calls in getParts
getParts:
    push {r3-r10, LR}
    bl getDecimalPart
    mov r2, r1
    bl getIntegralPart

    pop {r3-r10, PC}
