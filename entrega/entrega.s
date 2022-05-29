
@ Declaramos las constantes, reservando el espacio en memoria
.data
    feedback: .asciz "Quedan x letras por adivinar."
    vidas: .byte 7
	vida0: .ascii "0"


@ Declaramos nuestro código del programa
.text

    // Retorna un numero ascii equivalente a las vidas restantes
    // Entrada r0: el numero de vidas
    // Salida r1: el equivalente en ascii de las vidas
    asciiDeVidas:
        .fnstart
      		push {r0, lr}
      		ldr r1, =vida0
      		ldrb r1, [r1]
      		add r1, r0
      		pop {r0, lr}
      		bx lr
        .fnend

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

    // Reemplaza el caracter de la posicion especificada por otro
    // Entrada r1: dirección de memoria del vector
    // Entrada r2: posicion del caracter a reemplazar
    // Entrada r3: caracter nuevo
    reemplazar:
        .fnstart
            push {r1, r2, r3, lr}   // Protegemos registros
            add r1, r2              // Sumo la posición deseada a la dirección que apunta mi vector
            strb r3, [r1]              // Cargamos lo que está en r3 en la dirección de r1
            pop {r1, r2, r3, lr}    // Quitamos protección
            bx lr                   // Volvemos
        .fnend

    // Entrada r1 -> dirección de memoria
    // Entrada r2 -> tamaño cadena
    imprimir:
        .fnstart
            push {r0, r7, lr}
            mov r7, #4  // La función de swi que necesitamos para imprimir
            mov r0, #1
            swi 0
            pop {r0, r7, lr}
            bx lr
        .fnend

    // Retorna el largo de la cadena
    // Entradas r1: dirección de memoria
    // Saida r0: longitud cadena
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

    
    // Se encarga de imprimir las vidas restantes
    imprimirFeedback:
        push {r0, r1, r2, r3, r6, lr}   // Protegemos los registros
        mov r2, #7                  // El índice que queremos reemplazar
        ldr r6, =vidas              // Direc de las vidas
        ldr r0, [r6]                // El número de vidas a r0
        bl asciiDeVidas             // En r1 ponemos el equivalente en ascii de r0
        mov r3, r1                  // Copias el ascii en r3
        ldr r1, =feedback           // Dirección de memoria de la cadena
        bl reemplazar               // Reemplazamos con el valor actual de las vidas
        bl largoCadena              // Obtenemos el largo de la cadena
        mov r2, r0                  // Guardamos el largo en r2
        bl imprimir                 // Imprime el mensaje de feedback
        pop {r0, r1, r2, r3, r6, lr}    // Quitamos la protección de los registros
        bx lr                       // Volvemos

    @ Donde empieza nuestro programa
    .global main
    main:
        @Todo


    @ Para manejar el fin del programa
    fin:
        mov r7, #1  // Instrucción para salir del programa
        swi 0       // Interrumpimos para terminas
