.data

    posCuerdaX: .word 0x7 
    posCuerdaY: .word 0xe
    cadCoordX: .asciz "    "
    cadCoordY: .asciz "    "
    coordenadaX: .word 0 
    coordenadaY: .word 0 
    fallasteTiro: .asciz "Te equivocaste, Perdiste el juego!!\n"
    acertasteTiro:  .asciz "Diste en el blanco! Ganaste el juego!!\n"
    printX: .asciz "Ingrese la coordenada x para el disparo: \n"
    printY: .asciz "Ingrese la coordenada y para el disparo: \n"

.text
/**
  *  Convierte un numero en ascii a su equivalente en hexadecimal.
  *  ---------------------------------------------------------
  *  Entrada r0: puntero a la cadena.
  *  ---------------------------------------------------------
  *  Salida r1: el numero en decimal.
  */
  asciiADecim:
    .fnstart
      push {r0, r2, r3, r4, lr}
    
      ldrb r1, [r0]           // r1 <- inputUsuario[0]: primerCaracter
      sub r1, r1, #0x30
      mov r2, #1              // r2 <- indice i: empieza en 1
      mov r10, #10
      
      cicloAsciiADecim:
        ldrb r3, [r0, r2]      // r3 <- inputUsuario[r2]
        
        cmp r3, #00            // Comparamos con caracter nul
        beq finAsciiADecim
        cmp r3, #' '           // Comparamos con caracter ' ' 
        beq finAsciiADecim
        cmp r3, #'\n'          // Comparamos con caracter '\n'
        beq finAsciiADecim
        
        sub r3, r3, #0x30      // r3 <- el equivalente al caracter en numero
        
        mul r4, r1, r10        // r4 <- r1 x r10
        
        add r4, r3             // r1 <- r4 += r3
        mov r1, r4             // r1 <- el resultado que esta en r4
        add r2, #1             // r2 <- i++
        bal cicloAsciiADecim   // Siguiente iteracion
      
      finAsciiADecim:
        pop {r0, r2, r3, r4, lr}
        bx lr
.fnend  
 
  /**
  *   ---------------------------------------------------------------
  *   Imprime un mensaje indicando que se ingrese la coordenada X del disparo.
  *   ---------------------------------------------------------------
  */
imprimirPedidoX:
.fnstart
   mov r7, #4              @Tipo de interrupcion  = salida por pantalla
   mov r0, #1              @Salida de cadena
   mov r2, #43            @Tamaño de la cadena, 
   ldr r1, = printX
   swi 0
   bx lr
.fnend

  /**
  *   ---------------------------------------------------------------
  *   Imprime un mensaje indicando que se ingrese la coordenada Y del disparo.
  *   ---------------------------------------------------------------
  */
imprimirPedidoY:
.fnstart
   mov r7, #4             @Tipo de interrupcion = salida por pantalla 
   mov r0, #1             @Salida de cadena
   mov r2, #43            @Tamaño de la cadena
   ldr r1, = printY
   swi 0
   bx lr
.fnend

   /**
  *   Lee el ingreso por teclado de la coordenada X en asciz y lo
  *   y convierte en hexadecimal
  *   ---------------------------------------------------------------
  *   Entrada r0: direccion memoria de la coordenada Y ingresada 
  *   ---------------------------------------------------------------
  *   Salida r4: la coordenada X transformada de Asciz a Hexadecimal.
  */
inputX:
.fnstart
   push {lr}                     
   bl imprimirPedidoX
   pop {lr}                      

   mov r7, #3                    @Tipo de interrupcion = lectura por teclado
   mov r0, #0                    @Ingresa cadena            
   mov r2, #4                    @Tamaño de la cadena // Con cuánto me quedo del input
   ldr r1, = cadCoordX           @ guardo la direccion de la cadena ingresada en r0 PARA USAR EN AsciiAnum  
   swi 0

   mov r0,r1
   push {lr}                     
   bl asciiADecim
   pop {lr}                      

   ldr r4, = coordenadaX
   str r1, [r4] @r1 tiene el valor pasado a asciiADecim y lo guarda en r5

   bx lr
.fnend


 
 
   /**
  *   Lee el ingreso por teclado de la coordenada Y en asciz y lo
  *   y convierte en hexadecimal
  *   ---------------------------------------------------------------
  *   Entrada r0: direccion memoria de la coordenada Y ingresada 
  *   ---------------------------------------------------------------
  *   Salida r11: la coordenada Y transformada de Asciz a Hexadecimal.
  */
inputY:
.fnstart
   push {lr}                   
   bl imprimirPedidoY
   pop {lr}                    

   mov r7, #3                  @Tipo de interrupcion = lectura por teclado.
   mov r0, #0                  @Ingresa cadena
   mov r2, #4                  @Tamaño de la cadena.// Con cuánto me quedo del input
   ldr r1, = cadCoordY         @ guardo la direccion de la cadena ingresada en r0 PARA USAR EN AsciiAnum  
   swi 0

   mov r0,r1 @guardo en r0 la direccion del memoria del input r1 para usar la rutina asciiADecim
   push {lr}                   
   bl asciiADecim
   pop {lr}                   

   ldr r11, = coordenadaY
   str r1, [r11] @r1 tiene el valor pasado a asciiADecim y lo guarda en r3

   bx lr
.fnend


  /**
  *   Chequea si el input de la coordenada X coincide con la posicion
  *   X de la cuerda, y devuelve 1:si acierta 0:no acierta 
  *   ---------------------------------------------------------------
  *   Entrada r0: direccion memoria de la posicion X de la cuerda
  *   ---------------------------------------------------------------
  *   Salida r6: 1:si acierta 0:no acierta 
  */
 
aciertaDisparoX:
.fnstart
   push {r2,r4,lr}
        ldr r4, = coordenadaX      
        ldr r4, [r4]   
         
        ldr r0,=posCuerdaX
        ldr r2,[r0] @cargo en r2 la coordenada X de la cuerda

        cmp r2,r4 @ r4 tiene la coordenada ingresada por el usuario (ver rutina capturarX)
        beq aciertaX
		bal noAciertaX
		
		aciertaX:
		  mov r6, #1
		  bal nada1
		  
        noAciertaX:
          mov r6, #0
		
		nada1:
		  nop

   pop {r2,r4,lr}
   bx lr
.fnend



 
  /**
  *   Chequea si el input de la coordenada Y coincide con la posicion
  *   Y de la cuerda, y devuelve 1:si acierta 0:no acierta 
  *   ---------------------------------------------------------------
  *   Entrada r0: direccion memoria de la posicion X de la cuerda
  *   ---------------------------------------------------------------
  *   Salida r10: 1:si acierta 0:no acierta 
  */ 
 
aciertaDisparoY:
.fnstart
   push {r5,r11,lr} 
        ldr r11, = coordenadaY      
        ldr r11, [r11]  

        ldr r8,=posCuerdaY
        ldr r5,[r8] @cargo en r11 la coordenada Y de la cuerda
        
        cmp r5,r11  @ r11 tiene la coordenada Y ingresada por el usuario (ver rutina capturarY)
		beq aciertaY
		bal noAciertaY
		
		aciertaY:
          mov r10, #1
		  bal nada2
           
        noAciertaY:
          mov r10, #0
		nada2:
		  nop

   pop {r5,r11,lr}
   bx lr
.fnend


  /**
  *   Chequea si las 2 salidas de las subrutinas: 
  *   aciertaDisparoX (r6) y aciertaDisparoY(r10) si ambas son iguales a 1
  *   ---------------------------------------------------------------
  *   Salida: imprime una cadena diciendo si acierta o no el disparo 
  */ 

validarDisparo:
.fnstart
   push {r6,r10,lr} 
      cmp r6, #1  @r6 Contiene el aciertaDisparoX
		beq puedeGanar
		bal apuntoPerder
		
		apuntoPerder:
			cmp r10,#2  // no importa el estado del registro, pierde directo para que pueda mostrar el msj
			            // y no corte el ingreso de la coordenada Y
            bne perdiste
		
		
		puedeGanar:
		  cmp r10,#1
		  beq ganaste
		  bal perdiste
		
        ganaste:
            mov r7, #4             @Tipo de interrupcion  = salida por pantalla
            mov r0, #1             @Salida de cadena
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

   pop {r6,r10,lr}
   bx lr
.fnend

.global main
   main:

	   bl inputX
       bl aciertaDisparoX
       bl inputY
       bl aciertaDisparoY
	   bl validarDisparo
	
   fin:
		mov r7, #1
      swi 0
		