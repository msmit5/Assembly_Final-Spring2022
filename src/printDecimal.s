    @ This was taken directly from my #5 submission
    .global printDecimal
    .text

    @ Expects r0 to be value to print
    @ Returns nothing
printDecimal:
    push {LR}           @ Preserve LR

    @ Check if the value is 0, as I made an error and accidentally made it not support
    @ printing 0. This error is caused by my implementation of determineMagnitude.
    cmp r0, #0
    moveq r1, r0        @ printDigit expects value in r1
    bleq printDigit
    popeq {LR}          @ Because nothing else needs to be done, leave subroutine
    bxeq LR

    @ First and foremost, the magnitude of the number (amount of digits) needs to be learned
    bl determineMagnitude
    @ That value is returned in r3
    lsl r3, #2          @ I am storing magnitude in a halfword "array" at =magnitude

    ldr r5, =magnitude
    add r3, r5          @ set r3 to highest magnitude (0x2710 | 10,000)

    @ Iterate through the number from most significant digit to least significant digit
    @ Use repeated subtraction in inner loop "determineValueLoop" to determine the value of each digit
convertDec_loop:
    mov r1, #0                  @ Setting accumulator to 0
    cmp r3, r5                  @ Check if all magnitudes have been used
    bmi convertDone             @ If all magnitudes have been reached, each number has been converted

    @ Expects r0 to be the value
    @ Expects r1 to be 0, as it is an accumulator/counter
    @ Expects r3 to be physical offset for =magnitude
determineValueLoop:
    ldr r2, [r3]               @ Load r2 with current magnitude being read
    cmp r0, r2                  @ If the number-to-be-printed is larger than the magnitude...
    subge r0, r2                @ Then, remove one order of magnitude
    addge r1, #1                @ and add 1 to the accumulator which will track how large the number at the magnitude is
    bge determineValueLoop      @ Iterate because we still need to determine size
    sub r3, r3, #4              @ This is reached when the magnitude is > our num. This lowers the magnitude by a factor of 10
    bl printDigit               @ Print
    b convertDec_loop           @ Move onto next number

convertDone:
    pop {LR}                    @ Restore LR
    bx LR


@-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=@
    @ Expected Arguments:
    @ r0: value

    @ RETURNS:
    @ r3: amount of digits in number
determineMagnitude:
    ldr r5, =magnitude          @ load into r5 magnitude
    ldr r11, =magnitude         @ Temporary value for &magnitude. Given because I can't inline an addr
    add r5, #20                 @ point at final value

    @ determine digits helper
determineMagnitude_loop:
    ldr r6, [r5]               @ load value for comparison

    @ Determine the amount of digits used by using the offset in the "array"
    @ This works efficiently because I can divide by 4 (shift by 2) to convert raw mem
    @ offset to the logical offset.
    cmp r0, r6                  @ Check if num is > magnitude
    subge r3, r5, r11           @ Determine physical offset
    lsrge r3, #2                @ Determine logical offset by dividing by 4
    bxge LR                     @ Found amount of digits
    sub r5, #4                  @ Decrement subscript
    b determineMagnitude_loop   @ loop


@-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=@
    @ Expect: r1 to be INTEGER value to print
    @ Returns: Void (restores values)
printDigit:
    push {LR}           @ Preserve LR
    push {r0-r9}        @ Preserving all regs because I DO NOT want a print function to
                        @ taint values
    ldr r8, = charMap
    add r1, r8

    @ Create syscall
    mov r2, #1          @ len
    mov r0, #1          @ stdout
    mov r7, #4          @ syscall number
    svc 0

    pop {r0-r9}         @ Restoring values because I DO NOT want my print function to
                        @ taint values
    pop {LR}            @ Restore LR
    bx LR               @ Link back


@-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=@
    .data
magnitude:
    .word 0x00000001 @0d1
    .word 0x0000000A @0d10
    .word 0x00000064 @0d100
    .word 0x000003E8 @0d1000
    .word 0x00002710 @0d10000
    .word 0x000186A0 @0d100000


magnitude_old:
    .hword 0x0001 @ 0d1
    .hword 0x000A @ 0d10
    .hword 0x0064 @ 0d100
    .hword 0x03E8 @ 0x1000
    .hword 0x2710 @ 0x10000

charMap: .ascii "0123456789"
