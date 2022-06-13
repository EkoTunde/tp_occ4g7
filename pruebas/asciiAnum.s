.data
valorInt .word 0
.text
 // Entrada r0 <- dirección de memoria del dato ingresado
 //Salida r1 el ascii en formato numero.
aciiADecim:

    .fnstart
		push {r0,lr}

			mov r10, #10 @ para desplazar 1 posicion en el num c → d → u
			mov r2, #0 @se guarda el valor numero actual, parcialmente
			
			whileAsciiNum:
				 
				ldrb r5, [r0] @obtengo el primer caracter
				cmp r5,#00 @ compari si es Caracter Nulo
				beq guardarValor
				mul r2,r10 @multimplicamos x 10 para desplazar 1 pos en decimal
				add r0,#1 @posiciono el siguiente caracter #1(byte)
				sub r5, #0x30 // resta el valor 30 en hexa para obtener del ascii valor entero en decimal
				add r2,r5  //guardo en r2 el primer numero
				bal whileAsciiNum
			  
			guardarValor:
				ldr r1,=valorInt
				str r2,[r1] @ r1 ← r2

	 pop {r0,lr}
     bx lr
	.fnend
	
	
	
	