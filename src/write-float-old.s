.global wf_single,wf_double
.fpu neon-fp-armv8
.text

@ EXPECTS:
@ r0 <-- Memory address of floating point number
wf_single:
    push {r0-r10, LR}   @ Because this is a void print function, we will be preserving every register
    
    @ Check if negative
    ldr  r5, [r0]
    ldr  r6, =M_SIGN_32
    and  r6, r5
    cmp  r6, #0
    blgt _print_sign    @ print a "-" if the number is negative

    @ finding exponent:
    ldr r6, =M_EXPONENT_32
    and r6, r5 
    lsr r6, #23
    
    subs r6, r6, #127
    mov r10, r6
    bmi wf32_belowZero
    b wf32_aboveZero

    wf32_aboveZero:
        ldr r6, =M_MANTISSA_32
        and r6, r5
        
        @ print integer part of number
        rsb r9, r10, #23    @ r9 = 23 - r10 (amount of bits to shift to remove fractional part. 23 is mantissa size)
        lsr r6, r9          @ chop off decimal part of mantissa
        mov r8, #1          @ Prepare to account for the binary digit that is chopped off
        lsl r8, r10         @ shift bit into position
        orr r6, r8          @ add bit to number
        mov r0, r6          @ move to r0 for printing
        mov r1, r6          @ Save for later
        bl printDecimal
        
        nop
        bl _print_dot

        @ print fractional part of number
        @ format to only be decimal part of the number
        vmov s0, r5
        vmov s1, r1
        ldr  r1, =fpow5
        ldr  r1, [r1]
        vmov s2, r1

        vcvt.f32.u32 s1, s1

        vsub.f32 s0, s0, s1
        vmul.f32 s0, s2
        vmov r5, s0 
        
        ldr r6, =M_EXPONENT_32
        and r6, r5 
        lsr r6, #23
    
        subs r6, r6, #127
        mov r10, r6

        ldr r6, =M_MANTISSA_32
        and r6, r5

        rsb r9, r10, #23    @ r9 = 23 - r10 (amount of bits to shift to remove fractional part. 23 is mantissa size)
        lsr r6, r9          @ chop off decimal part of mantissa
        mov r8, #1          @ Prepare to account for the binary digit that is chopped off
        lsl r8, r10         @ shift bit into position
        orr r6, r8          @ add bit to number
        mov r0, r6          @ move to r0 for printing
        mov r1, r6          @ Save for later
        bl printDecimal
        

        b wf32_done


    wf32_belowZero:
        ldr r0, =tmpbuf
        str r5, [r0]            @ getLeadingZeros wants a pointer
        bl getLeadingZeros
        bl _print_zeros

        @ Unlke the other one, we will want to find an alternate float to multiply our number with,
        @ because we don't want an output of 0 if we have a number with 6 leading 0s
        vmov s0, r5
        vmov s1, r1
        ldr  r1, =fpows
        mov  r4, #4
        mul r0, r4
        add r1, r4
        add r1, #24             @ add 6 more 0s for good measure
        ldr  r1, [r1]
        vmov s2, r1

        vcvt.f32.u32 s1, s1

        vsub.f32 s0, s0, s1
        vmul.f32 s0, s2
        vmov r5, s0

        ldr r6, =M_EXPONENT_32
        and r6, r5
        lsr r6, #23

        subs r6, r6, #127
        mov r10, r6

        ldr r6, =M_MANTISSA_32
        and r6, r5

        rsb r9, r10, #23    @ r9 = 23 - r10 (amount of bits to shift to remove fractional part. 23 is mantissa size)
        lsr r6, r9          @ chop off decimal part of mantissa
        mov r8, #1          @ Prepare to account for the binary digit that is chopped off
        lsl r8, r10         @ shift bit into position
        orr r6, r8          @ add bit to number
        mov r0, r6          @ move to r0 for printing
        mov r1, r6          @ Save for later
        bl printDecimal
        b wf32_done




oldSolution:
        @ get the positive version of the exponent
        mvn r10, r10        @ Make the negative number positive
        add r10, #1         @ Add 1 because mvn just finds complement
        mov r11, r10


        @ Divide by three, because it will let me know how many 0s to add
	@ The reason we are dividing by three is because 3 is approx log_2(10)
        mov r0, #0
        b div3
        div3:
            sub r11, #3
            cmp r11, #0
            ble divDone
            add r0, #1
            b div3

    divDone:
        bl _print_zeros

        @ Unlke the other one, we will want to find an alternate float to multiply our number with,
        @ because we don't want an output of 0 if we have a number with 6 leading 0s
        vmov s0, r5
        vmov s1, r1
        ldr  r1, =fpows
        mov  r4, #4
        mul r0, r4
        add r1, r4
        add r1, #24             @ add 6 more 0s for good measure
        ldr  r1, [r1]
        vmov s2, r1

        vcvt.f32.u32 s1, s1

        vsub.f32 s0, s0, s1
        vmul.f32 s0, s2
        vmov r5, s0

        ldr r6, =M_EXPONENT_32
        and r6, r5
        lsr r6, #23

        subs r6, r6, #127
        mov r10, r6

        ldr r6, =M_MANTISSA_32
        and r6, r5

        rsb r9, r10, #23    @ r9 = 23 - r10 (amount of bits to shift to remove fractional part. 23 is mantissa size)
        lsr r6, r9          @ chop off decimal part of mantissa
        mov r8, #1          @ Prepare to account for the binary digit that is chopped off
        lsl r8, r10         @ shift bit into position
        orr r6, r8          @ add bit to number
        mov r0, r6          @ move to r0 for printing
        mov r1, r6          @ Save for later
        bl printDecimal
        b wf32_done


    wf32_done:
        bl _print_ln
        pop {r0-r10, PC}    @ pop LR into the PC in a similar way that is done by gcc
        @ bx lr   (not needed because return already occurred)

wf_double:
    push {r0-r10, LR}
    nop
    pop  {r0-r10, PC}

@-------------------------------------------------------------------------------------------------@
_print_ln:
    push {r0-r10, LR}

    mov r0, #1
    ldr r1, =nline
    mov r2, #1
    mov r7, #4    
    svc 0

    pop {r0-r10, PC}

_print_dot:
    push {r0-r10, LR}

    mov r0, #1
    ldr r1, =dot
    mov r2, #1
    mov r7, #4    
    svc 0

    pop {r0-r10, PC}

_print_sign:
    push {r0-r10, LR}

    mov r0, #1
    ldr r1, =neg
    mov r2, #1
    mov r7, #4    
    svc 0

    pop {r0-r10, PC}

    @ Args: r0, which is how many tailing 0s to print
_print_zeros:
    push {r0-r10, LR}

    add r0, #2                  @ Because I want to print the amount of trailing 0s in the string, I need to account  for the 0. that prefixes it
    mov r2, r0                  @ msglen
    mov r0, #1                  @ write to stdout
    ldr r1, =zeroString         @ "0.00000..."
    mov r7, #4                  @ write syscall num
    svc 0

    pop {r0-r10, PC}

.data
pmpt:   .ascii "> "
nline:  .byte 0x0A,0x00
neg:    .ascii "-"
dot:    .ascii "."
tmpbuf: .space 16

.align 4
@MASKS
M_SIGN_32     = 0x80000000 
M_EXPONENT_32 = 0x7F800000
M_MANTISSA_32 = 0x007FFFFF


@ for decimal hack
fpow0:  .single 1
fpows:
fpow1:  .single 10
fpow2:  .single 100
fpow3:  .single 1000
fpow4:  .single 10000
fpow5:  .single 100000
fpow6:  .single 1000000
fpow7:  .single 10000000
fpow8:  .single 100000000
fpow9:  .single 1000000000
fpowA:  .single 10000000000
fpowB:  .single 100000000000
fpowC:  .single 1000000000000
fpowD:  .single 10000000000000
fpowE:  .single 100000000000000

err_below_0: .asciz "Cannot hit target, too close and/or too fast!"
err_len = .-err_below_0

@ This string is a hack used to print the leading 0s without using a loop
zeroString: .ascii "0.0000000000000000000000000000000000000000000000000000"
