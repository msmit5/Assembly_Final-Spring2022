.global wf_single,wf_double,_start
.fpu neon-fp-armv8
.text

@ Remove this when testing is done
_start:

    ldr r0, =sarr
    bl wf_single

    b exit


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
    nop
    # DO THE HACK!!!
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

.data
pmpt:   .ascii "> "
nline:  .byte 0x0A,0x00
neg:    .ascii "-"
dot:    .ascii "."
buffer: .space 16
nums:   .ascii "0123456789"

.align 4
@MASKS
M_SIGN_32     = 0x80000000 
M_EXPONENT_32 = 0x7F800000
M_MANTISSA_32 = 0x007FFFFF

@ 64 bit
M_SIGN_64_0 = 0x00000000 
M_SIGN_64_1 = 0x80000000         @ NOTE: stored in memory with lsw before msw
@ M_EXPONENT_64_0
@ M_EXPONENT_64_1


@ CONSTANTS
EXPONENT_32 = 127 
@ EXPONENT_64


@ for decimal hack
fpow5:  .single 100000



err_below_0: .asciz "Cannot hit target, too close and/or too fast!"
err_len = .-err_below_0

@ This string is a hack used to print the leading 0s without using a loop
zeroString: .ascii "0000000000000000000000000000000000000000000000000000"

@ TESTING:
sarr:
sng1: .single 3.1415926
sng2: .single 13.37
sng3: .single 98765.4321
serr: .single -98765.4321
