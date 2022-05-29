.data
    feedback: .asciz "Quedan 5 letras por adivinar."
    vidas: .byte 5
	  vida0: .ascii "0"

.text
    
    // Retorna un numero en su equivalente de ascii
    // Entrada r0: el numero en ascii
    // Salida r1: el equivalente de ascii
    asciiDeNum:
        .fnstart
      		push {r0, lr}
      		ldr r1, =vida0
      		ldrb r1, [r1]
      		add r1, r0
      		pop {r0, lr}
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


    imprimirFeedback:
        push {r0, r1, r2, r3, lr}       // Protegemos los registros
        mov r2, #7          // El índice que queremos reemplazar
        ldr r6, =vidas	    // Direc de las vidas
        ldr r0, [r6]       // El número de vidas a r0
        bl asciiDeNum       // En r1 ponemos el equivalente en ascii de r0
        mov r3, r1          // Copias el ascii en r3
        ldr r1, =feedback   // Dirección de memoria de la cadena
        bl reemplazar
        bl largoCadena      // Obtenemos el largo de la cadena
        mov r2, r0          // Guardamos el largo en r2
        bl imprimir         //
        pop {r0, r1, r2, r3, lr}        // Quitamos la protección de los registros
        bx lr               // Volvemos

    .global main
    main:
      	ldr r1, =feedback
      	mov r2, #7
      	mov r3, #52
      	bl reemplazar
        bl imprimirFeedback

    fin:
        mov r7, #1
        swi 0
