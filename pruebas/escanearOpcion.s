.data
  ingreseOpcion:  .asciz "Ingrese una opción: \n"
                  .asciz "1: Arriegar letra   \n"
                  .asciz "2: Arriesgar palabra\n"
                  longitudOpciones=.-ingreseOpcion
  opcionElegida:  .byte 0
.text

	// Entrada r1 -> dirección de memoria
	// Entrada r2 -> tamaño cadena
	imprimir:
		.fnstart
				push {r0, r7, lr}
				mov r7, #4
				mov r0, #1
				swi 0
				pop {r0, r7, lr}
				bx lr
		.fnend
   
  leer:
    .fnstart
        push {r7, r0, r2, lr}
        mov r7, #3 // Leer el input del usuario
        mov r0, #0 // El primer parametro es el buffer
        mov r2, #1 // El segundo parametro es el tamaño del buffer
        ldr r3, =opcionElegida // Donde se guarda la direccion del input
        swi 0
        pop {r7, r0, r2, lr}
        bx lr
    .fnend
   

	// imprime las opciones a elegir y devuelve la opción elegida por el usuario
    // Entrada r1 -> dirección de memoria
    // Entrada r2 -> tamaño cadena
    // Salida  r3 -> opción elegida por el usuario (Lee la opción que ingresó pero falta pasar el valor ingresado de ascii a int)
	escanearOpcion:
        .fnstart
            push {r1, r2, lr} // Protegemos los registros
            ldr r1, =ingreseOpcion // Cargamos el input con la sugerencia de Opciones a elegir
			ldr r2, =longitudOpciones // Cargamos la longitud de la matriz ingreseOpcion
  			bl imprimir // Llamamos a la función imprimir con los parámetros de r1 y r2
            bl leer // Leemos la opción que ingresó el usuario
            pop {r1, r2, lr} // Quitamos la protección de los registros
  			bx lr // Volvemos a donde estaba apuntando el Link Register en el main
	    .fnend

	.global main
	main:
		bl escanearOpcion
   
     fin:
	    mov r7, #1
	    swi 0