
.data
        mensaje: .space 20
.text
        leer:
                .fnstart
                        push {lr}
                        mov r7, #3 // Leer el input del usuario
                        mov r0, #0 // El primer parametro es el buffer
                        mov r2, #10 // El segundo parametro es el tamaño del buffer
                        ldr r1, =mensaje // Donde se guarda la direccion del input
                        swi 0
                        pop {lr}
                        bx lr
                .fnend

                
        imprimir:
                .fnstart
                        push {lr}
                        mov r7, #4
                        mov r0, #1
                        mov r2, #10
                        ldr r1, =mensaje
                        swi 0
                        pop {lr}
                        bx lr
                .fnend

        .global main
        main:
                bl leer
                bl imprimir
                mov r7, #1
                swi 0
