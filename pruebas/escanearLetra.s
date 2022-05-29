.data
  msjArriesgarLetra:          .asciz "Por favor, ingrese la letra que desea arriegar: "
  letraElegida:               .asciz " \n"
  elegiste:                   .asciz "Elegiste la letra: "


.text

    // Entrada r1 -> dirección de memoria del mensaje en asciz
    imprimirAsciz:
        .fnstart
            push {r0, r2, lr}
            bl largoCadena
            mov r2, r0
            bl imprimir
            pop {r0, r2, lr}
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
    // Salida r0 -> longitud cadena
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

    // Actualiza el asciz que empieza en =letraElegida
    // con la letra elegida por el usuario
    escanearLetra:
        .fnstart
            push {r0, r1, r2, r7, lr}
            ldr r1, =msjArriesgarLetra    // Mensaje al usuario
            bl imprimirAsciz
            mov r7, #3                    // Función escanear input del usuario
            mov r0, #0                    // EL búfer
            mov r2, #1                    // Con cuánto me quedo del input
            ldr r1, =letraElegida         // Donde se guarda el resultado
            swi 0
            pop {r0, r1, r2, r7, lr}
            bx lr
        .fnend


	.global main
	main:
        bl escanearLetra
    
        ldr r1, =elegiste
        bl imprimirAsciz  
    
        ldr r1, =letraElegida
        bl imprimirAsciz
    

	fin:
		mov r7, #1
		swi 0
