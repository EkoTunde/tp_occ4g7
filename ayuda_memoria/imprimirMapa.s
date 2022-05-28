.data
        mapa:    .ascii "1234567890123456789012345678901234567890123456789012"
                         .ascii "1234567890123456789012345678901234567890123456789012"
                         .ascii "1234567890123456789012345678901234567890123456789012"
                         .ascii "1234567890123456789012345678901234567890123456789012"
                         .ascii "1234567890123456789012345678901234567890123456789012"
.text
    imprimirMapa:
        .fnstart
                        push {lr}
                        mov r7, #4
                        mov r0, #1
                        mov r2, #260
                        ldr r1, =mapa
                        swi 0
                        pop {lr}
                        bx lr
        .fnend
        .global main
        main:
                bl imprimirMapa
                mov r7, #1
                swi 0

