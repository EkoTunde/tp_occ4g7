@ Declaramos las constantes, reservando el espacio en memoria
.data   
        mensaje: .ascii "Hola mundo"

@ Declaramos nuestro código del programa
.text

        @ Imprime en pantalla lo que este en la etiqueta mensaje
        imprimir:
                        push {lr}
                        mov r7, #4
                        mov r0, #1
                        mov r2, #10
                        ldr r1, =mensaje
                        swi 0
                        pop {lr}
                        bx lr

        @ Donde empieza nuestro programa
        .global main
        main:
                bl imprimir
                mov r7, #1
                swi 0
