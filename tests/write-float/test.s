    .global _start
    .text

_start:
    ldr r0, =farr
    ldr r2, =farr_end

testloop:
    cmp r0, r2
    beq exit

    bl writeFloat
    add r0, #4
    b testloop


    .data
.align 4
farr:
f0: .single 1
f1: .single 2
f3: .single 3.1415926
f4: .single 5.4321
f_:   .single 0.1
fa: .single 0.01
f5: .single 0.001
f6: .single 0.0001
f7: .single 0.00001
f8: .single 0.000001
f9: .single 0.0000001
f10:.single 0.00000001
f11:.single 0.000000001
f12:.single 0.0000000001
f13:.single 0.00000000001
err:.single 0.000000000001
farr_end:   .word 0
