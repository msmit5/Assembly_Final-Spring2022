    .global getDropTime
    .fpu neon-fp-armv8
    .text

    @ EXPECTS:
    @ r0 <-- angle (degrees, float)
    @ r1 <-- height (meters, float)
    @ r2 <-- velocity (m/s, float )
    @
    @ RETURNS:
    @ r0 <-- result
getDropTime:
    push {r1-r10, LR}

    @ r3 <-- fallTime
    @ r4 <-- distance to target
    @ r5 <-- time to target

    bl getFallTime
    bl getDistance
    bl getTimeToTarg

    @ Solution: timeToTarget - fallTime
    vmov s5, r5
    vmov s3, r3
    vsub.f32 s5, s3

    vmov r0, s5


    pop {r1-r10, PC}


    @ EXPECTS:
    @ r1 <-- height
    @
    @ RETURNS:
    @ r3 <-- fallTime
    @
    @ FORMULA:
    @ r1 = 1/2 a * t^2
    @ sqrt((2 * r1)/a) = t
getFallTime:
    push {r0-r2, r4-r10, LR}

    ldr r9, =grav
    ldr r8, =two
    ldr r9, [r9]
    ldr r8, [r8]

    vmov s9, r9
    vmov s8, r8
    vmov s1, r1

    vmul.f32  s1, s8            @ 2 * y
    vdiv.f32  s1, s1, s9        @ 2y / a
    vsqrt.f32 s1, s1            @ sqrt(s1)
    vmov r3, s1

    pop {r0-r2, r4-r10, PC}


    @ ATYPICAL CALL!
    @ EXPECTS:
    @ r0 <-- angle
    @ r1 <-- height
    @
    @ RETURNS:
    @ r4 <-- angular distance to target
    @
    @ FORMULA:
    @ d = y/cos(90 - r0) (90 degrees == pi/2, cos(pi/2 - r0))
    @ d = y/sin(r0)      (applied confunction identity)
getAngularDistance:
    push {r0-r3, r5-r10, LR}
    bl deg2rad_float            @ convert r0 to radians
    bl sin                      @ sin(r0)

    vmov s0, r0                 @ sin(angle)
    vmov s1, r1                 @ height

    vdiv.f32 s2, s1, s0         @ r1/sin(r0) (y/sin(angle))
    vmov r4, s2

    pop  {r0-r3, r5-r10, PC}



    @ ATYPICAL CALL!
    @ EXPECTS:
    @ r0 <-- angle
    @ r1 <-- height
    @
    @ RETURNS:
    @ r4 <-- distance to target
    @
    @ FORMULA:
    @ angularDistance * sin(90 - r0)
    @ angularDistance * cos(r0) (appliend confunction identity)
getDistance:
    push {r0-r3, r5-r10, LR}

    bl getAngularDistance       @ returns in r4
    bl deg2rad_float            @ returns in r0
    bl cos                      @ returns in r0

    vmov s0, r0                 @ sin(angle)
    vmov s4, r4                 @ anglular Distance

    vmul.f32 s4, s0             @ result

    vmov r4, s4

    pop {r0-r3, r5-r10, PC}


    @ ATYPICAL CALL!!
    @ EXPECTS:
    @ r2 <-- velocity
    @ r4 <-- distance
    @
    @ RETURNS:
    @ r5 <-- time to target
    @
    @ FORMULA
    @ v = d/t
    @ t = d/v
getTimeToTarg:
    push {r0-r4, r6-r10, LR}

    vmov s2, r2
    vmov s4, r4

    vdiv.f32 s0, s4, s2         @ distance / velocity
    vmov r5, s0

    pop {r0-r4, r6-r10, PC}


    .data
grav:   .single 9.80665         @ acceleration due to gravity
half:   .single 0.5
two:    .single 2.0
