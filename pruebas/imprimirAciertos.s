.data
        matrizAciertos: .asciz "+-------------------------------------------+      |\n"
                        .asciz "|                                           |      |\n"
                        .asciz "|    @a@@us                                 |      |\n"
                        .asciz "|                                           |      |\n"
                        .asciz "+-------------------------------------------+      |\n"
                        longitudMatrizAciertos=.-matrizAciertos
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

	// imprime cuadrante de matriz de palabra a adivinar
	// Entrada r1 -> dirección de memoria
	imprimirAciertos:
				.fnstart
					push {r1, r2, lr} // Protegemos los registros
					ldr r1, =matrizAciertos // Cargamos el cuadrante de la matriz Aciertos
					ldr r2, =longitudMatrizAciertos // Cargamos la longitud de la matrizAciertos
					bl imprimir // Llamamos a la función imprimir con los parámetros de r1 y r2
					pop {r1, r2, lr} // Quitamos la protección de los registros
					bx lr // Volvemos a donde estaba apuntando el Link Register en el main
				.fnend

	.global main
	main:
		bl imprimirAciertos
		mov r7, #1
		swi 0