    .global writeFloat,_print_Zeros
    .fpu neon-fp-armv8
    .text

    @ EXPECTS:
    @ r0 <-- Address of float

    @ RETURNS:
    @ Void
writeFloat:
    push {r0-r10, LR}           @ preserve all data, just a print

    push {r0}
    ldr r5, [r0]

    @ check if the string is negative
    ldr r6, =M_SIGN_32
    and r6, r5
    cmp r6, #0
    bllt _print_neg_sign        @ less than because it is a signed comparison,
    ldrlt r6, =M_SIGN_CLEAR     @ and we are checking sign bit
    andlt r5, r6                @ clear sign bit

    
    

    @ Check if number is less than 1 (or greater than 1)
    @ The hacky way I am using is this:
    @ 0x3F800000 == (float) 1.0
    @ 0x7f800000 == Bitmask of Exponenet only
    @ If r0 & 0x7f800000 >= 0x3F800000, then we know that the number does not need to be checked for leading 0s
    ldr r6, =M_EXPONENT_32
    ldr r7, =CON_FLOAT_ONE
    and r6, r5
    cmp r6, r7
    blt wf_LT1
    b   wf_GT1

    wf_GT1:
        mov r0, r5
        bl getParts


        bl wf_GT1_printLoop
        mov r0, r2
        bl _print_Dot
        b printDecimalPart

    @ The hackiest hack I have done in a while. Like holy shit.
    @ This isn't the best description of what I am doing, but here is an annotated version of it
    @ 1. Chop off decimal part
    @ 2. divide by 10
    @ 3. get decimal part
    @ 4. multiply by 10
    @ 5. convert to int
    @ 6. push number to stack
    @ 7. repeat until done
    @ 8. pop each number from stack and print it
    @ convert to int and print
    wf_GT1_printLoop:
        push {r0-r12, LR}       @ r12 is preserved, because it is used in a subroutine

        vmov s0, r1             @ r1 is from getParts, called in previous func. is int part
        vcvt.f32.u32 s0, s0     @ convert to int because getParts returns int
        ldr r10, =f_10
        ldr r10, [r10]
        vmov s10, r10

        ldr r5, =f_05
        ldr r5, [r5]

        ldr r9, =SENTINEL
        push {r9}

        printLoop:
            vcmp.f32 s0, #0
            vmrs apsr_nzcv, fpscr
            ble pldone

            vdiv.f32 s1, s0, s10 @ s1 = new, s0 = old, s10 = 10
            vmov r0, s1
            bl getParts
            push {r1}           @ save integral part (int)
            vmov s2, r2
            vmul.f32 s2, s10
            vmov r0, s2
            bl getParts

            @ prepare to round
            @ This is being done like this because (float) 7/10 -> 0.69999...
            vmov s26, r2        @ decimal part
            vmov s25, r5
            vcmp.f32 s25, s26
            vmrs apsr_nzcv, fpscr

            mov r0, r1
            addlt r0, #1        @ round

            pop {r1}            @ retrieve saved integral part (int)
            push {r0}           @ This pushes to stack because we will be grabbing nums in reverse order
            vmov s0, r1
            vcvt.f32.u32 s0, s0 @ getParts returns an int, so we convert it to dec

            b printLoop

        pldone:
            bl printFromStack
            pop {r0-r12, PC}


    wf_GT1_old:
        mov r0, r5

        @ Get the integer part and print it
        bl getParts
        mov r0, r1
        bl printDecimal

        bl _print_Dot

        mov r0, r2
        bl printDecimalPart

        @ Grab the decimal part and print it using the hack
        mov r0, r2

        b wf_done


    wf_LT1:
        bl getLeadingZerosDereferenced
        cmp r0, #12
        beq _err_too_small
        bl _print_2_pos
        mov r0, r5
        bl printDecimalPart


    @ REQUIRES:
    @ R0 <-- float
    printDecimalPart:
        cmp r0, #0              @ check if the float is a 0
        beq print0ret           @ if it is a 0, print a single 0 and return
                                @ It should be noted due to float fuzziness, this is an imperfect method
        mov r5, r0
        bl getLeadingZerosDereferenced
        mov r8, r0              @ amount of 0s before we start caring about len

        mov r0, r5
        ldr r7, =f_10
        ldr r7, [r7]
        vmov s10, r7
        vmov s0, r0
        bl getParts
        add r8, #3
        mov r7, #0              @ counter           leadingZeros = r8
        pd_loop:                @ for(r7 = 0; r7 < leadingZeros + 3; r7++)
            vmov s2, r2
            vmul.f32 s2, s10
            vmov r0, s2

            bl getParts
            mov r5, r0
            mov r0, r1
            bl printDecimal

            add r7, #1
            cmp r7, r8
            blt pd_loop

        b wf_done

    print0ret:
        bl printDecimal
        b wf_done


    old_wf_LT1:
        bl getLeadingZeros
        mov r2, r0              @ Save leading 0s for later

        @CONSTRAINT!!!
        @ Maximum amount of leading 0s: 12
        cmp r0, #12
        bgt _err_too_small

        bl _print_Leading_Zeros

        mov r0, r5              @ r5 contains the float
        bl getDecimalPart
        vmov s1, r1

        mov r7, #4
        mul r2, r7
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
    pop {r0}                    @ DEBUG: lets me see r0 before leaving
    bl _print_New_Line
    pop {r0-r10, PC}



@-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

    @ EXPECTS:
    @ STACK:
    @ Sentinel must be in stack
    @
    @ RETURNS:
    @ r12 <-- Stack pointer before it pushes registers to stack
    @ STACK MODIFICATIONS:
    @ The stack will be left WITH THE SENTINEL AT THE TOP OF THE STACK

printFromStack:
    mov r12, LR

    ldr r9, =SENTINEL

    printFromStackLoop:
        pop {r0}
        cmp r0, r9
        beq pfsDone
        bl printDecimal
        b printFromStackLoop


    pfsDone:
    bx r12
    @ Expects:
    @ r0 <-- amount of leading 0s
_print_Leading_Zeros:
    push {r0-r10, LR}
    add r0, #2                  @ This accounts for the "0." in the zeroString

    mov r7, #4                  @ print syscall number
    mov r2, r0                  @ len
    ldr r1, =zeroString         @ addr of zeroString
    mov r0, #1                  @ stdout
    svc 0

    pop {r0-r10, PC}

_print_2_pos:
    push {r0-r10, LR}
    mov r0, #2

    mov r7, #4                  @ print syscall number
    mov r2, r0                  @ len
    ldr r1, =zeroString         @ addr of zeroString
    mov r0, #1                  @ stdout
    svc 0

    pop {r0-r10, PC}


    @ requires r0 have len of 0s
_print_Zeros:
    push {r0-r10, LR}

    mov r2, r0

    mov r7, #4
    ldr r1, =zeroString
    add r1, #2                  @ This pushes the ptr past the 0.
    mov r0, #1
    @ r2 will have len already
    svc 0

    pop {r0-r10, PC}


_print_Dot:
    push {r0-r10, LR}

    mov r0, #1
    ldr r1, =dot
    mov r2, #1
    mov r7, #4
    svc 0

    pop {r0-r10, PC}

_print_New_Line:
    push {r0-r10, LR}

    mov r7, #4
    mov r2, #1
    ldr r1, =nline
    mov r0, #1
    svc 0

    pop {r0-r10, PC}

_print_neg_sign:
    push {r0-r10, LR}

    mov r0, #1	
    ldr r1, =neg
    mov r2, #1
    mov r7, #4
    svc 0

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
neg:        .ascii "-"
tmpbuf:     .space 16

nline:      .asciz "\n\n Overrunning nline"

err_neg_str:    .asciz "ERROR: NEGATIVE VALUE!!\nTHIS SHOULD NOT REACH writeFloat!\n"
err_neg_len=    .-err_neg_str

err_too_small_str:  .asciz "ERROR! VALUE TOO SMALL\n"
err_too_small_len=  .-err_too_small_str

    .align 4

@ bitmasks for some float related things
M_SIGN_32     = 0x80000000
M_EXPONENT_32 = 0x7F800000
M_MANTISSA_32 = 0x007FFFFF
M_EXP_SIGN_32 = 0x40000000
CON_FLOAT_ONE = 0x3F800000
M_SIGN_CLEAR  = 0x7FFFFFFF


    @ floats for conversion
f_10:   .single 10
f_05:   .single 0.5
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


PRINT_INTEGRAL_ZERO = 0x01020304
SENTINEL = 0x12312312
