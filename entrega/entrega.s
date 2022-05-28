
@ Declaramos las constantes, reservando el espacio en memoria
.data
    @Todo


@ Declaramos nuestro código del programa
.text
    
    // Entradas: r1 (dirección de memoria), r2 (tamaño cadena)
    imprimir:
        .fnstart
        push {r0, lr}
        mov r7, #4  // La función de swi que necesitamos para imprimir
        mov r0, #1
        swi 0
        pop {r0, lr}
        .fnend

    // Retorna el largo de la cadena
    // Entradas: r0 (dirección de memoria)
    // Saida: r1 (longitud cadena)
    largoCadena:
        .fnstart
            push {r0, lr}
            mov r3, #0 // Caracter nulo
            mov r1, #0 // Contador

            cicloLargo:
                ldrb r2, [r0]
                cmp r3, r2
                beq finlargo
                add r1, #1
                add r0, #1
                bal cicloLargo

            finlargo:
                pop {r0, lr}
                bx lr
        .fnend


    @ Donde empieza nuestro programa
    .global main
    main:
        @Todo


    @ Para manejar el fin del programa
    fin:
        mov r7, #1
        swi 0
