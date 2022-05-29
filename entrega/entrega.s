
@ Declaramos las constantes, reservando el espacio en memoria
.data
    @Todo


@ Declaramos nuestro código del programa
.text

    // Reemplaza el caracter de la posicion especificada
    // por otro en un vector asciz (termina en nulo)
    // Entrada r1: dirección de memoria del vector
    // Entrada r2: posicion del caracter a reemplazar
    // Entrada r3: caracter nuevo
    reemplazar:
        .fnstart
            push {r1, r2, r3, lr}   // Protegemos registros
            add r1, r2              // Sumo la posición deseada a la dirección que apunta mi vector
            str r3, r1              // Cargamos lo que está en r3 en la dirección de r1
            pop {r1, r2, r3, lr}    // Quitamos protección
            bx lr                   // Volvemos
        .fnend

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
    // Entradas: r1 (dirección de memoria)
    // Saida: r0 (longitud cadena)
    largoCadena:
        .fnstart
            push {r1, lr}
            mov r3, #0 // Caracter nulo
            mov r0, #0 // Contador

            cicloLargo:
                ldrb r2, [r1]
                cmp r3, r2
                beq finlargo
                add r0, #1
                add r1, #1
                bal cicloLargo

            finlargo:
                pop {r1, lr}
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
