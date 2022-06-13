.data
valorInt: .word 0
posCuerdaX: .byte 0x7 
posCuerdaY: .byte 0xE
coordenadaX: .word 0
coordenadaY: .word 0
fallasteTiro: .asciz "Te equivocaste, Perdiste el juego!!\n"
acertasteTiro:  .asciz "Diste en el blanco! Ganaste el juego!!\n"
ingresarX: .asciz "Ingrese la coordenada x para el disparo: \n"
ingresarY: .asciz "Ingrese la coordenada y para el disparo: \n"

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
	




@Imprime un mensaje indicando que se ingrese la coordenada X del disparo.
imprimirPedidoX:
.fnstart
   mov r7, #4              @Tipo de interrupcion  = salida por pantalla
   mov r0, #1              @Salida de cadena
   mov r2, #43            @Tamaño de la cadena, 
   ldr r1, = ingresarX
   swi 0
   bx lr
.fnend

@Imprime un mensaje indicando que se ingrese la coordenada Y del disparo.
imprimirPedidoY:
.fnstart
   mov r7, #4             @Tipo de interrupcion = salida por pantalla 
   mov r0, #1             @Salida de cadena
   mov r2, #43            @Tamaño de la cadena
   ldr r1, = ingresarY
   swi 0
   bx lr
.fnend


 // Entrada r0 <- dirección de memoria del dato ingresado
 //Salida r5  <- el valor X transformado a AsciiAnum (hexa).
capturarX:
.fnstart
   push {lr}                     
   bl imprimirPedidoX
   pop {lr}                      

   mov r7, #3                    @Tipo de interrupcion = lectura por teclado
   mov r0, #0                    @Ingresa cadena            
   mov r2, #2                    @Tamaño de la cadena // Con cuánto me quedo del input
   ldr r1, = coordenadaX
   swi 0

   ldr r0, = coordenadaX @cargo en r0 la direccion de coordenada X para usarla
						 @en la subrutina asciiADecim 

   push {lr}                     
   bl asciiADecim
   pop {lr}                      

   ldr r5, = coordenadaX
   str r1, [r5] @r1 tiene el valor pasado a asciiADecim y lo guarda en r5

   bx lr
.fnend

 // Entrada r0 <- dirección de memoria del dato ingresado
 //Salida r3 <- el valor Y transformado a AsciiAnum (hexa).
capturarY:
.fnstart
   push {lr}                   
   bl imprimirPedidoY
   pop {lr}                    

   mov r7, #3                  @Tipo de interrupcion = lectura por teclado.
   mov r0, #0                  @Ingresa cadena
   mov r2, #2                  @Tamaño de la cadena.// Con cuánto me quedo del input
   ldr r1, = coordenadaY
   swi 0

   ldr r0, = coordenadaY  @cargo en r0 la direccion de la coordenada Y para usarla
						  @en la subrutina asciiADecim 

   push {lr}                   
   bl asciiADecim
   pop {lr}                   

   ldr r3, = coordenadaY
   str r1, [r3] @r1 tiene el valor pasado a asciiADecim y lo guarda en r3

   bx lr
.fnend

 // Entrada r0 <- dirección de memoria de la pos X de la cuerda
 //Salida r1 <- devuelve 1: si acerto el dispa, 0: si no lo acierta
aciertaDisparoX:
.fnstart
   push {r0,lr} 
        ldr r2,[r0] @cargo en r2 la coordenada x de la cuerda
        cmp r2,r5 @ r5 tiene la coordenada ingresada por el usuario (ver rutina capturarX)
        beq acierta
        bal noAcierta
        
        aciertoX:
                mov r1, #1
        noAciertaX:
                mov r1, #0

   pop {r0,lr}
   bx lr
.fnend


 // Entrada r1 <- dirección de memoria de la pos Y de la cuerda
 //Salida r2 <- devuelve 1: si acerto el dispa, 0: si no lo acierta
aciertaDisparoY:
.fnstart
   push {r1,lr} 
        ldr r6,[r1]
        cmp r6,r3  @ r3 tiene la coordenada Y ingresada por el usuario (ver rutina capturarY)
        beq acierta
        bal noAcierta
        
        aciertoY:
                mov r2, #1
        noAciertaY:
                mov r2, #0

   pop {r1,lr}
   bx lr
.fnend


  // Entrada r1 <-  resultado de la rutina aciertaX
  // Entrada r2 <- resultado de la rutina aciertaY
  // salida: imprimir los carteles de finalizacion del juego 
validarDisparo:

.fnstart
   push {r1,r2,lr} 
        cmp r1,r2
        beq ganaste
        bal perdiste

        ganaste:
            mov r7, #4              @Tipo de interrupcion  = salida por pantalla
            mov r0, #1              @Salida de cadena
            mov r2, #40            @Tamaño de la cadena, 
            ldr r1, = acertasteTiro
            swi 0
            bal fin
        perdiste:
            mov r7, #4            @Tipo de interrupcion  = salida por pantalla
            mov r0, #1            @Salida de cadena
            mov r2, #37           @Tamaño de la cadena, 
            ldr r1, = fallasteTiro
            swi 0
            bal fin

   pop {r1,r2,lr}
   bx lr
.fnend

.global main
      main:

		 bl capturarX
		 bl capturarY
		 bl aciertaDisparoX
		 bl aciertaDisparoY
		 bl validarDisparo
	
      fin:
		mov r7, #1
        swi 0
		