    .global _start
    .text

_start:
    ldr r1, =buf
    mov r2, #12
    mov r0, #1
    mov r7, #3
    svc 0

    ldr r0, =buf
    bl verifyInputFloat
    bl strToFloat
    bl deg2rad_float

    @ write-float expects address
    ldr r5, =buf
    str r0, [r5]
    mov r0, r5
    bl writeFloat
    bl exit

    .data
buf:    .space 32
