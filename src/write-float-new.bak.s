    .global writeFloat
    .fpu neon-fp-armv8
    .text


    @ EXPECTS:
    @ r0 <-- Address of float

    @ RETURNS:
    @ Void
writeFloat:
    push {r0-r10, LR}           @ preserve all data, just a print

    ldr r5, [r0]

    @ check if the string is negative
    ldr r6, =M_SIGN_32
    and r6, r5
    cmp r6, #0
    bne _err_neg

    @ Check if number is less than 1 (or greater than 1)
    @ The hacky way I am using is this:
    @ 0x3F800000 == (float) 1.0
    @ 0x7f800000 == Bitmask of Exponenet only
    @ If r0 & 0x7f800000 >= 0x3F800000, then we know that the number does not need to be checked for leading 0s
    ldr r6, =M_EXPONENT_32
    ldr r7, =CON_FLOAT_ONE
    and r6, r5
    cmp r7, r6
    blt wf_LT1
    b   wf_GT1

    wf_GT1:
        mov r0, r5

        @ Get the integer part and print it
        bl getParts
        mov r0, r1
        bl printDecimal

        @ Grab the decimal part and print it using the hack
        vmov s2, r2             @ s2 contains the decimal part
        ldr  r8, =farr          @ get the current amount of extra decimal places printed
        ldr  r8, [r8]           @ dereference
        vmov s8, r8             @ mov the power of 10 to s8
        vmul.f32 s2, s8         @ multiply the decimal part by the power of 10 to get an integral part
        vcvt.u32.f32 s2, s2     @ convert the float to an unsigned int (decimals are unsigned)
        vmov r0, s2             @ move the unsigned int to r0

        bl printDecimal
        b wf_done


    wf_LT1:
        bl getLeadingZeros
        @CONSTRAINT!!!
        @ Maximum amount of leading 0s: 12
        cmp r0, #12
        bgt _err_too_small

        bl printLeadingZeros
        mov r2, r0              @ Save leading 0s for later


        mov r0, r5              @ r5 contains the float
        bl getDecimalPart
        vmov s1, r1

        mul r2, #4
        ldr r3, =farr
        add r3, r2
        ldr r2, [r3]
        vmov s2, r2
        vmul.f32 s1, s2
        vcvt.u32.f32 s0, s1
        vmov r0, s0
        bl printDecimal
        b wf_done


wf_done:
    pop {r0-r10, PC}



@-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    @ Expects:
    @ r0 <-- amount of leading 0s
_print_Leading_Zeros
    push {r0-r10, LR}
    add r0, #2                  @ This accounts for the "0." in the zeroString

    mov r7, #4                  @ print syscall number
    mov r2, r0                  @ len
    ldr r1, =zeroString         @ addr of zeroString
    mov r0, #1                  @ stdout

    pop {r0-r10, PC}

_err_neg:
    mov r0, #1
    ldr r1, =err_neg_str
    ldr r2, =err_neg_len
    push {r1}
    push {r2}
    b exit_p


_err_too_small:
    mov r0, #1
    ldr r1, =err_too_small_str
    ldr r2, =err_too_small_len
    push {r1}
    push {r2}
    b exit_p

    .data

zeroString: .ascii "0.00000000000000000000000000000000000000000000000000000000000"
dot:        .ascii "."
tmpbuf:     .space 16
nline:      .byte 0x0A, 0x00

err_neg_str:    .asciz "ERROR: NEGATIVE VALUE!!\nTHIS SHOULD NOT REACH writeFloat!\n"
err_neg_len:    .-err_neg_str

err_too_small_str:  .asciz "ERROR! VALUE TOO SMALL\n"
err_too_small_len:  .-err_too_small_str

    .align 4

@ bitmasks for some float related things
M_SIGN_32     = 0x800000000
M_EXPONENT_32 = 0x7F8000000
M_MANTISSA_32 = 0x007FFFFFF
M_EXP_SIGN_32 = 0x400000000
CON_FLOAT_ONE = 0x3F8000000


    @ floats for conversion
farr:
f3:     .single 1000
f4:     .single 10000
f5:     .single 100000
f6:     .single 1000000
f7:     .single 10000000
f8:     .single 100000000
f9:     .single 1000000000
fa:     .single 10000000000
fb:     .single 100000000000
fc:     .single 1000000000000
fd:     .single 10000000000000
fe:     .single 100000000000000
ff:     .single 1000000000000000
