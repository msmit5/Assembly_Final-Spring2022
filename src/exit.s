    @----------------------------------------------------------------------------------------------@
    @                                                                                              @
    @                                          exit.s                                              @
    @                                        version 1.0                                           @
    @                                       Matthew Smith                                          @
    @                                  msmit29@unh.newhaven.edu                                    @
    @                                                                                              @
    @           This module provides some basic exit functionality that I would find               @
    @           useful in most programs I would write. It offers 4 functions, all of               @
    @           which I use. They are as follows:                                                  @
    @                                                                                              @
    @           exit:   Abruptly close program with exit code 0.                                   @
    @                                                                                              @
    @           exit_c: Abruptly close program. Exit code is expected to be loaded                 @
    @                   into r0 at this point.                                                     @
    @                                                                                              @
    @           exit_f: Abruptly close program with exit code 1.                                   @
    @                                                                                              @
    @           exit_p: Print error message before exiting program. Expects message and            @
    @                   length to be loaded into stack. See documentation below.                   @
    @                                                                                              @
    @----------------------------------------------------------------------------------------------@


    .global exit,exit_c,exit_f,exit_p
    .text
exit:
    mov r0, #0
    mov r7, #1
    svc 0

exit_f:
    mov r0, #1
    mov r7, #1
    svc 0

    @ Exit code is expected to be preloaded in r0
exit_c:
@   r0 <- error code,
    mov r7, #1
    svc 0

    @ This function takes 3 arguments:
    @ r0 <- Exit code
    @
    @ Stack:
    @  .
    @ /|\
    @  |    length of error message  (pop 1)
    @  |    address of error message (pop 2)
    @  |
    @
    @ Essentially, I chose to use the stack just because it seemed like an interesting choice
    @ There is no practical reason to do it at this point. But I might try implementing multiple
    @ error strings in the future, to allowing easier debugging In that case, using the stack would
    @ be a viable choice In that case, I could implement recursion to print in reverse order too ;)
exit_p:
@   r0 <- error code
    mov r10, r0                 @ Preserve exit code

    @ Prepare to write error message
    mov r0, #1                  @ write to stdout
    mov r7, #4                  @ Write syscall num
    pop {r2}                    @ length
    pop {r1}                    @ message
    svc 0

    @ exit
    mov r7, #1
    mov r0, r10
    svc 0

    @ NOTE to future matt: If I do the recursion, I would need to use stack bp shenanigans in order
    @ to make things work
