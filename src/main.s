    .global _start
    .fpu neon-fp-armv8
    .text

_start:
    bl promptRead_init
    bl modeSelect

    @ here I can do anything I need to do before mode jump but after modeSelect

    @ branch to the mode
    ldr r9, =cmp_NORM
    ldr r9, [r9]
    @ because the input must match to get here, if not NORM, it is TEST
    cmp r9, r10
    bleq normal
    blne test

    bl getDropTime_helper

    @ checking if negative
    ldr r0, =dropTime
    ldr r2, [r0]
    mov r1, #1
    lsl r1, #31
    and r3, r2, r1
    cmp r3, #0
    bne abort

    bl print_helper

    b exit


test:
    push {r0-r10, LR}

    ldr r0, =input_buf

    @ READ DATA

    mov r1, #0x41               @ "A" read A1 or angle
    ldr r5, =angle
    bl  prompt_read
    bl  verifyInputFloat
    bl  strToFloat
    str r0, [r5]
    bl  flush


    ldr r0, =input_buf
    mov r1, #0x48               @ "H" read y or height
    ldr r5, =height
    bl  prompt_read
    bl  verifyInputFloat
    bl  strToFloat
    str r0, [r5]
    bl  flush


    ldr r0, =input_buf
    mov r1, #0x56               @ "V" read v or velocity
    ldr r5, =velocity
    bl  prompt_read
    bl  verifyInputFloat
    bl  strToFloat
    str r0, [r5]
    bl  flush

    pop {r0-r10, PC}

normal:
    push {r0-r10, LR}

    ldr r0, =normalBuf
    ldr r1, =angle
    ldr r2, =height
    ldr r3, =velocity
    bl parseNormal

    pop {r0-r10, PC}


    @ EXPECTS:
    @ init_buf <-- NORM,
    @
    @ RETURNS:
    @ r10 <-- flag
modeSelect:
    push {r0-r9, LR}

    ldr r5, =cmp_NORM
    ldr r6, =cmp_TEST
    ldr r7, =init_buf

    ldr r5, [r5]
    ldr r6, [r6]
    ldr r7, [r7]

    cmp   r7, r5
    moveq r10, r5
    popeq {r0-r9, PC}
    cmp   r7, r6
    moveq r10, r6
    popeq {r0-r9, PC}

    @ no match
    b err_mode
    pop {r0-r9, PC} @ <-- useless


promptRead_init:
    push {r0-r10, LR}

    @ prompt
    ldr r1, =initPrompt_str
    ldr r2, =initPrompt_len
    mov r0, #1
    mov r7, #4
    svc 0
    nop

    mov r7, #3
    ldr r1, =init_buf
    mov r2, #10
    mov r0, #0
    svc  0

    pop {r0-r10, PC}


    @ INPUT:
    @ r1 <-- Code (determines prompt)
    @
    @ OUTPUT:
    @ Buffers are updated with the given input
prompt_read:
    push {r0-r10, LR}
    mov r0, r1                  @ move input to r0 to preserve it

    @ Determine prompt and len
    cmp   r0, #0x41             @ angle
    ldreq r1, =ang_prompt_str
    ldreq r2, =ang_prompt_len

    cmp   r0, #0x48             @ height
    ldreq r1, =hei_prompt_str
    ldreq r2, =hei_prompt_len

    cmp   r0, #0x56             @ velocity
    ldreq r1, =vel_prompt_str
    ldreq r2, =vel_prompt_len

    @ other necessary variables
    mov r0, #1
    mov r7, #4
    svc 0                       @ write syscall

    @ prepare to read
    mov r7, #3                  @ read
    mov r0, #0                  @ stdin
    mov r2, #12                 @ len
    ldr r1, =input_buf          @

    svc 0                       @ read

    pop {r0-r10, PC}


    @ INPUT:
    @
    @ OUTPUT:
    @ None (input buffer is flushed though)
flush:
    push {r0-r10, LR}
    ldr r0, =input_buf
    mov r7, r0
    add r7, #33
    mov r2, #0
    floop:                      @ Flush loop
        cmp r0, r7
        popge {r0-r10, PC}
        strb r2, [r0], #1       @ store one 0 byte to the input buffer, flushing it
        b floop

getDropTime_helper:
    push {r0-r10, LR}

    ldr r0, =angle
    ldr r1, =height
    ldr r2, =velocity
    ldr r0, [r0]
    ldr r1, [r1]
    ldr r2, [r2]
    bl  getDropTime

    ldr r5, =dropTime
    str r0, [r5]

    pop {r0-r10, PC}

    @ EXPECTS:
    @ none
    @
    @ RETURNS:
    @ none
print_helper:
    push {r0-r10, LR}

    ldr r1, =p1_str
    ldr r2, =p1_len
    mov r0, #1
    mov r7, #4
    svc 0

    ldr r0, =dropTime
    bl writeFloat

    ldr r1, =p2_str
    ldr r2, =p2_len
    mov r0, #1
    mov r7, #4
    svc 0

    pop {r0-r10, PC}


abort:
    mov r0, #1
    ldr r1, =abort_str
    ldr r2, =abort_len
    push {r1}
    push {r2}
    b exit_p

err_mode:
    ldr r1, =err_mode_str
    ldr r2, =err_mode_len
    mov r0, #1
    mov r7, #4
    push {r1}
    push {r2}
    b exit_p


    .data
    @ PROMPTS
initPrompt_str: .asciz "NORM or TEST mode: \n"
initPrompt_len= .-initPrompt_str

err_mode_str:   .asciz "Mode not recognized"
err_mode_len=   .-err_mode_str

ang_prompt_str: .asciz "Angle:    "
ang_prompt_len= .-ang_prompt_str

hei_prompt_str: .asciz "Height:   "
hei_prompt_len= .-hei_prompt_str

vel_prompt_str: .asciz "Velocity: "
vel_prompt_len= .-vel_prompt_str

@ abort
abort_str:  .asciz "SOLUTION ABORT!"
abort_len=  .-abort_str

@ print messages
p1_str: .asciz "SOLUTION DROP IN "
p1_len= .-p1_str

p2_str: .asciz " SECS\n"
p2_len= .-p2_str

    @ BUFFERS
    @ Reading
init_buf:   .space 32
input_buf:  .space 32

    @ Storage buffers
    .align 4
velocity:   .single 0.0
height:     .single 0.0
angle:      .single 0.0
dropTime:   .single -0.0        @ negative 0 to trigger error

cmp_NORM:   .word 0x4D524F4E

cmp_TEST:   .word 0x54534554


@ TEST DATA (REAL MODE)
normalBuf:
t1: .asciz "UPDATE A1:15.0 DEGREES, Y:939.0 METERS, VX:200.0 M/S"



