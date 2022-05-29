.data
    plantillaEscanear: .ascii "Esta es la plantilla para escanear"
    solicitudNumero: .ascii "Por favor, ingrese un número entre 0 y 9, inclusive: "

.text

    // Retorna el input de un numero del usuario
    escanearNum:
        .fnstart
            push {lr}
            mov r7, #3 // Leer el input del usuario
            mov r0, #0 // El primer parametro es el buffer
            mov r2, #1 // El segundo parametro es el tamaño del buffer
            ldr r1, =plantillaEscanear // Donde se guarda la direccion del input
            swi 0
            pop {lr}
            bx lr
        .fnend

    asciiANum:
        .fnstart
            push {lr}
            ldr r1, =plantillaEscanear
            ldrb r2, [r1]
            sub r2, #48
            pop {lr}
            bx lr
        .fnend

    // Entrada r1 -> dirección de memoria
    // Entrada r2 -> tamaño cadena
    imprimir:
        .fnstart
            push {r0, lr}
            mov r7, #4  // La función de swi que necesitamos para imprimir
            mov r0, #1
            swi 0
            pop {r0, lr}
            bx lr
        .fnend


    // Retorna el largo de la cadena
    // Entradas r1 -> dirección de memoria
    // Saida r0 -> longitud cadena
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


    .global main
    main:
        // Pedirle al usuario que ingrese un numero
        ldr r1, =solicitudNumero
        bl largoCadena
        mov r2, r0
        bl imprimir
        // Escanea el numero
        bl escanearNum
        bl asciiANum

    fin:
        mov r7, #1
        swi 0
