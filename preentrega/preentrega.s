.data
    /* Definicion de datos */
	
	run: .byte 1

    mapa: .asciz "___________________________________________________|\n                                                   |\n     *** EL JUEGO DEL AHORCADO - ORGA 1 ***        |\n___________________________________________________|\n                                                   |\n                                                   |\n          +------------+                           |\n          |            |                           |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n +-------------------------------------------+     |\n |                                           |     |\n |                                           |     |\n |                                           |     |\n +-------------------------------------------+     |\n"
    lenMapa = . - mapa

    enter: .ascii "\n"
    
    cls: .asciz "\x1b[H\x1b[2J" //una manera de borrar la pantalla usando ansi escape codes
    lencls = .-cls
    
    saltoLinea: .ascii "\n"
    
    inputUsuario: .asciz "                  "
    lenInputUsuario = . - inputUsuario

    palabraOculta: .asciz "            "
    palabraActual: .asciz "            "
    letrasUsadas: .asciz "                          "
    
    vidas: .byte 7
    
    letrasRestantes: .asciz "Quedan letras por adivinar!"
    lenLetrasRestantes = . - letrasRestantes
     
    juegoPerdido: .asciz "Que lastima, perdiste! :("
    lenJuegoPerdido = . - juegoPerdido
    
    juegoGanado: .asciz "Felicitaciones, ganaste!"
    lenJuegoGanado = . - juegoGanado
    
    cadenaVidas: .asciz "vidas: 7"
    lenCadenaVidas = . - cadenaVidas
    
    ganado: .byte 0
    
    porFavorNoRepitasLetras: .asciz "Esa letra ya fue usada"
    lenPorFavorNoRepitasLetras = . - porFavorNoRepitasLetras
    
    indicePrimeraLetraUsadaEnMapa: .byte 213
    
    indicePalabraActual: .word 882
    
    lemario: .asciz "-diciembre," //1
             .asciz "hamburguesa," //2
             .asciz "sentado," //3
             .asciz "literatura," //4
             .asciz "temporada," //5
             .asciz "aspecto," //6
             .asciz "bostezar," //7
             .asciz "calzoncillos," //8
             .asciz "ahumado," //9
             .asciz "espectador," //10
             .asciz "arreglarse," //11
             .asciz "servilleta," //12
             .asciz "cantantes," //13
             .asciz "remolcador," //14
             .asciz "futbolista," //15
             .asciz "campamento," //16
             .asciz "laboratorio," //17
             .asciz "organillero," //18
             .asciz "carnaval," //19
             .asciz "plancha," //20
           
  solicitudNumero: .asciz "Por favor, ingresá un número entre 1 y 20: "
  lenSolicitudNumero = . - solicitudNumero
  
  solicitudLetra: .asciz "Por favor, ingresá una letra minúscula o arriesgá la palabra: "
  lenSolicitudLetra = . - solicitudLetra
  
  /*
  TODO:
  - una matriz que tiene 20 palabras
  - pedirle al usuario que ingrese un numero entre 1 y 20 (mostrar texto)
  - con ese numero cargar la palabraOculta
  - carcar la palabraActual
  */
  
.text
    /**
    *
    *  Lo que hace la función.
    *  -------------------------
    *  Entrada r1: el valor
    *  Entrada r2: el otro valor
    *  -------------------------
    *  Salida r2: la salida
    */
    /*<nombre>:
      .fnstart
        push {lr}
        nop
        pop {lr}
        bx lr
      .fnend
    */
    
    /**
    *   Imprime una cadena de caracteres ASCIZ 
	*	utilizando interrupciones.
    *   ------------------------------------------
    *   Entrada r1: puntero a la cadena a imprimir
    *   Entrada r2: longitud de la cadena
    */
    imprimir:
		.fnstart
			push {r0, r7}   // Protegemos los registros
			
			mov r7, #4		// La función de swi que necesitamos para imprimir
			mov r0, #1		// Indicamos a SWI que sera una cadena
			swi 0			// SWI, Software interrupt
			
			pop {r0, r7}    // Restauramos los registros
			bx lr			// Salimos de la funcion
		.fnend
  
    /**
    *	Imprime una cadena de caracteres ASCIZ utilizando
	*	interrupciones y luego imprime un salto de linea.
    *	---------------------------------------------------
    *	Entrada r1: puntero a la cadena a imprimir
    *	Entrada r2: longitud de la cadena
    */
    imprimirLinea:
		.fnstart
			push {r1, r2, lr}
			bl imprimir             // Imprimimos la cadena a la que apunta r1
			
			ldr r1, =saltoLinea     // r1 <- puntero a saltoLinea: '\n'
			mov r2, #1              // r2 <- 1 es lo que mide '\n'
			bl imprimir             // Imprimimos el salto del linea
			
			pop {r1, r2, lr}
			bx lr
		.fnend

    /**
    *   Imprime una cadena de caracteres ASCIZ 
	*	despues de borrar el contenido de la pantalla.
    *   ----------------------------------------------
    *   Entrada r1: puntero a la cadena a imprimir
    *   Entrada r2: longitud de la cadena
    */
    borrarEImprimir:
        .fnstart
            push {lr}
            push {r1}
            push {r2} 
            bl clearScreen
            pop {r2}
            pop {r1}
			bl imprimir
            pop {lr}
            bx lr
        .fnend
  
    /**
    *   Limpia la pantalla de la consola.
    */
    clearScreen:
        .fnstart
            ldr r1, =cls
            ldr r2, =lencls
			bl imprimir
            bx lr
        .fnend

	/**
    *   Limpia la pantalla de la consola.
    */
    //clearScreen:
    //    .fnstart
    //        mov r0, #1
    //        ldr r1, =cls
    //        ldr r2, =lencls
    //        mov r7, #4
    //        swi #0
    //        bx lr //salimos de la funcion clearScreen
    //    .fnend
      
    /**
    *   Imprime el mapa por consola con todos los datos actualizados.
    */
    imprimirMapa:
		.fnstart
			push {r1, r2, lr}
			ldr r1, =mapa
			ldr r2, =lenMapa
			bl borrarEImprimir	// Recibe en r1 puntero de cadena y en r2 la longitud de la misma
			pop {r1, r2, lr}
			bx lr
		.fnend
      
    /**
    *   Devuelve si quedan letras por adivinar (1, true) o no (0, false)
    *   ---------------------------------------------------------------
    *   Salida r2: 1 por true, 0 por false.
    */
    quedanLetrasPorAdivinar:
		.fnstart
			push {r0, r1, r3, lr}
        
			ldr r0, =palabraActual
			
			mov r1, #0		// i: contador para ciclar
        
			cicloQuedanLetrasPorAdivinar:

				ldrb r3, [r0, r1]    // r3 <- palabraActual[i]

				cmp r3, #00
				beq noQuedanLetrasPorAdivinar // Si palabraActual[i] == nul terminamos de iterar la cadena

				cmp r3, #0x20
				beq noQuedanLetrasPorAdivinar	// Si palabraActual[i] ==  ' ' tambien terminamos de iterar la cadena

				cmp r3, #'_'
				beq siQuedanLetrasPorAdivinar	// Si palabraActual[i] ==  '_' tambien terminamos de iterar la cadena

				add r1, #1	// i++
				bal cicloQuedanLetrasPorAdivinar
        
        
			siQuedanLetrasPorAdivinar:
				mov r2, #1	// r2 <- 1 para retornar true
				bal finQuedanLetrasPorAdivinar

			noQuedanLetrasPorAdivinar:
				mov r2, #0	// r2 <- 0 para retornar false          
			
			finQuedanLetrasPorAdivinar:
				pop {r0, r1, r3, lr}
				bx lr
		.fnend
  
    /**
    *	Agrega al mapa la letra que ingreso el usuario en la siguiente 
	*	posicion disponible para la lista en pantalla de letras usadas.
    */
    agregarLetraUsadaAlMapa:
        .fnstart
            push {r0, r1, r2, r3, r4}

            ldr r0, =inputUsuario
            ldr r1, =indicePrimeraLetraUsadaEnMapa
			ldr r2, =mapa

            ldrb r3, [r0]		// r3 <- la letra que ingreso el usuario
            ldrb r4, [r1]		// r4 <- indice/lugar disponible en mapa para agregar la letra (indicePrimeraLetraUsadaEnMapa)

            strb r3, [r2, r4]	// mapa[indice] = letra

            add r3, #2			// indice += 2
            strb r3, [r1]		// indicePrimeraLetraUsadaEnMapa = indice

            pop {r0, r1, r2, r3, r4}
            bx lr
        .fnend
  
    /**
    *   Intenta agregar la letra que ingreso el usuario a la lista de letras usadas.
	*	----------------------------------------------------------------------------
	*	Salida r0: 1 (true) si se agrego a la lista, 0 (false) en caso contrario.
    */
    guardarLetraUsada:
        .fnstart
            push {r0, r1, r3, r4, lr}

            ldr r0, =inputUsuario
            ldr r1, =letrasUsadas

            ldrb r2, [r0]          // r2 <- letra: la letra que ingreso el usuario

            mov r3, #0              // r3 <- i: indice/contador para ciclar

            cicloGuardarLetraUsada:
                ldrb r4, [r1, r3]    // r4 <- letrasUsadas[i]

                cmp r4, r2
                beq noAgregarLetraALista // Si letrasUsadas[i] == letra -> ya esta en la 'lista', podemos salir

                cmp r4, #' '			// Verificamos si r4 es ' '
                beq agregarLetraALista	// Si letrasUsadas[i] == ' ' -> hay espacio disponible para agregar

                add r3, #1					// i++
                bal cicloGuardarLetraUsada	// siguiente iteracion
				
			noAgregarLetraALista:
				mov r0, #0	// r0 <- para retornar false
				bal finGuardarLetraUsada

            agregarLetraALista:
				bl agregarLetraUsadaAlMapa
                strb r2, [r1, r3]	// r2 (letra del usuario) -> letrasUsadas[r3]
                mov r0, #1			// r0 <- para retornar true

            finGuardarLetraUsada:
                pop {r0, r1, r3, r4, lr}
                bx lr
        .fnend
      
    /**
    *	Imprime por consola el mensaje que indica
	*	que quedan letras restantes por adivinar.
    */
    imprimirMsjLetrasRestantes:
        .fnstart
            push {r1, r2, lr}
            ldr r1, =letrasRestantes
            ldr r2, =lenLetrasRestantes
            bl imprimirLinea
            pop {r1, r2, lr}
            bx lr
        .fnend
        
    /**
    *	Imprime por consola el mensaje que
	*	indica que el usuario gano el juego.
    */
    imprimirMsjJuegoGanado:
        .fnstart
            bl revelarPalabraOculta
            bl actualizarPalabraActualEnMapa
            bl imprimirMapa
            ldr r1, =juegoGanado
            ldr r2, =lenJuegoGanado
            bl imprimirLinea
            bal fin
        .fnend
  
    /**
    *	Reemplaza los '_' por '@' de la palabraActual para
	*	representar los caracteres que el usuario no pudo adivinar.
    */
    encriptarLetrasNoEncontradas:
        .fnstart
            push {r0, r1, r2, r9, lr}
            
            ldr r0, =palabraActual
            mov r1, #0              // r1 <- i (indice): contador para ciclar palabraActual
            mov r9, #'@'
            
            cicloEncriptarLetrasNoEncontradas:
                ldrb r2, [r0, r1]    // r2 <- palabraActual[i]
                
                cmp r2, #00
                beq finEncriptarLetrasNoEncontradas	// Si palabraActual[i] == nul -> terminamos de ciclar la palabraActual
                
                cmp r2, #'_'
				bne sigCicloEncriptarNoEncontradas	// Si palabraActual[i] != '_' -> siguiente iteracion
				
				strb r9, [r0, r1]					// palabraActual[i] = '@'
			
			sigCicloEncriptarNoEncontradas:
                add r1, #1								// i++
                bal cicloEncriptarLetrasNoEncontradas	// siguiente iteracion
            
            finEncriptarLetrasNoEncontradas:
                pop {r0, r1, r2, r9, lr}
                bx lr
        .fnend

        
    /**
    *	Imprime por consola el mensaje que
	*	indica que el usuario perdio el juego.
    */
    imprimirJuegoPerdido:
        .fnstart
            push {r1, r2, lr}
            bl encriptarLetrasNoEncontradas
            bl actualizarPalabraActualEnMapa
            bl imprimirMapa
            ldr r1, =juegoPerdido
            ldr r2, =lenJuegoPerdido
            bl imprimirLinea
            pop {r1, r2, lr}
            bx lr
        .fnend
  
    /**
    *	Actualiza el mensaje que indica la cantidad de
	*	vidas restantes con el valor actual de la misma.
    */
    actualizarMsjVidas:
        .fnstart
            push {r0, r1, r2, r3, lr}      

            ldr r0, =vidas
            ldrb r0, [r0]			// r0 <- vidas
            bl decimalToAscii		// r1 <- asciiDelNum <- decimalToAscii(r0: num decimal) 

            ldr r2, =cadenaVidas
			mov r3, #7				// r3 <- i: 7 es la parte de cadenaVidas donde esta el numero de vidas restantes
            strb r1, [r2, r3]		// cadenaVidas[7] = asciiDelNum
            
            pop {r0, r1, r2, r3, lr}
            bx lr
        .fnend
      
    /**
    *   Reemplaza el caracter de la matriz en los indices indicados, por el caracter indicado.
    *   offset = puntero + (fila x cant_columnas x tamaño_bytes) + (columna x tamaño_bytes)
    *   --------------------------------------------------------------------------------------
    *   Entrada r0: puntero de la matriz
    *   Entrada r1: ascii de reemplazo (.byte)
    *   Entrada r2: numero de fila
    *   Entrada r3: numero de columna
    *   Entrada r4: numero cantidad de columnas
    */
    reemplazarLetraEnMatriz:
        .fnstart
            push {r0, r1, r2, r3, r4, r5}
			
            mul r5, r2, r4		// r5 <-- r2 x r4 : fila * cantidad columnas
            add r5, r3			// r5 <-- r5 + r3 : r5 + numero de columna
    	    strb r1, [r0, r5]	// matriz[fila][columna] = ascii de reemplazo
    	    
			pop {r0, r1, r2, r3, r4, r5}
    	    bx lr
        .fnend
	
	/**
	*	Reemplaza en la matriz del mapa el caracter indicado si las vidas 
	*	restantes son menos que las necesarias para dibujar un espacio.
	*	-----------------------------------------------------------------------
	*	Entrada r0: vidas restantes
	*	Entrada r1: vidas necesarias para dibujar un espacio
	*	Entrada r2: caracter ASCII que representa la parte del cuerpo a dibujar
	*	Entrada r3: numero de fila
	*	Entrada r4: numero de columna
	*/
	actualizarParteEnMapa:
		.fnstart
		    push {r0, r1, r2, r3, r4, lr}

			cmp r0, r1
			bne usarCaracterEnParte	// Si vidasRestantes != vidasNecesarias -> dibujamos el caracter ASCII
			
			mov r1, #' '
			bal finActualizarParteEnMapa

			usarCaracterEnParte:
				mov r1, r2		// r1: ascii de reemplazo (.byte)

			finActualizarParteEnMapa:
				mov r0, =mapa	// r0: puntero de la matriz
				mov r2, r3		// r2: numero de fila
				mov r3, r4		// r3: numero de columna
				mov r4, #53		// r4: numero cantidad de columnas
				bl reemplazarLetraEnMatriz	// reemplazarLetraEnMatriz(r0, r1, r2, r3, r4)
				pop {r0, r1, r2, r3, r4, lr}
				bx lr
       .fnend
    
	/**
	*	Actualiza en el mapa el caracter correspondiente 
	*	en el lugar de la cabeza: si vidas >= 7, dibujar 'o'.
	*	-----------------------------------------------------
	*	Entrada r0: numero de vidas restantes
	*/
    actualizarCabezaEnMapa:
        .fnstart
			push {r0, r1, r2, r3, r4, lr}
			mov r1, #7		// r1 <- vidas necesarias para dibujar ' '
			mov r2, #'o'	// r2 <- cabeza
			mov r3, #8		// r3 <- numero de fila
			mov r3, #23		// r4 <- numero de columna
			bl actualizarParteEnMapa
			pop {r0, r1, r2, r3, r4, lr}
			bx lr
       .fnend
	   
	/**
	*	Actualiza en el mapa el caracter correspondiente 
	*	en el lugar del pecho: si vidas >= 6, dibujar '|'.
	*	-----------------------------------------------------
	*	Entrada r0: numero de vidas restantes
	*/
    actualizarPechoEnMapa:
        .fnstart
			push {r0, r1, r2, r3, r4, lr}
			mov r1, #6		// r1 <- vidas necesarias para dibujar ' '
			mov r2, #'|'	// r2 <- pecho
			mov r3, #9		// r3 <- numero de fila
			mov r3, #23		// r4 <- numero de columna
			bl actualizarParteEnMapa
			pop {r0, r1, r2, r3, r4, lr}
			bx lr
       .fnend

	/**
	*	Actualiza en el mapa el caracter correspondiente 
	*	en el lugar del brazo izquierdo: si vidas >= 5, dibujar '/'.
	*	-----------------------------------------------------
	*	Entrada r0: numero de vidas restantes
	*/
    actualizarBrazoIzqEnMapa:
        .fnstart
			push {r0, r1, r2, r3, r4, lr}
			mov r1, #5		// r1 <- vidas necesarias para dibujar ' '
			mov r2, #'/'	// r2 <- brazo izquierdo
			mov r3, #9		// r3 <- numero de fila
			mov r3, #22		// r4 <- numero de columna
			bl actualizarParteEnMapa
			pop {r0, r1, r2, r3, r4, lr}
			bx lr
       .fnend

	
	/**
	*	Actualiza en el mapa el caracter correspondiente 
	*	en el lugar del brazo derecho: si vidas >= 4, dibujar '\\'.
	*	-----------------------------------------------------
	*	Entrada r0: numero de vidas restantes
	*/
    actualizarBrazoDerEnMapa:
        .fnstart
			push {r0, r1, r2, r3, r4, lr}
			mov r1, #4		// r1 <- vidas necesarias para dibujar ' '
			mov r2, #'\\'	// r2 <- brazo derecho
			mov r3, #9		// r3 <- numero de fila
			mov r3, #24		// r4 <- numero de columna
			bl actualizarParteEnMapa
			pop {r0, r1, r2, r3, r4, lr}
			bx lr
       .fnend

	/**
	*	Actualiza en el mapa el caracter correspondiente 
	*	en el lugar del abdomen: si vidas >= 3, dibujar '|'.
	*	-----------------------------------------------------
	*	Entrada r0: numero de vidas restantes
	*/
    actualizarAbdomenEnMapa:
        .fnstart
			push {r0, r1, r2, r3, r4, lr}
			mov r1, #3		// r1 <- vidas necesarias para dibujar ' '
			mov r2, #'|'	// r2 <- abdomen
			mov r3, #10		// r3 <- numero de fila
			mov r3, #23		// r4 <- numero de columna
			bl actualizarParteEnMapa
			pop {r0, r1, r2, r3, r4, lr}
			bx lr
       .fnend

	/**
	*	Actualiza en el mapa el caracter correspondiente 
	*	en el lugar de la pierna izquierda: si vidas >= 2, dibujar '/'.
	*	-----------------------------------------------------
	*	Entrada r0: numero de vidas
	*/
    actualizarPiernaIzqEnMapa:
        .fnstart
			push {r0, r1, r2, r3, r4, lr}
			mov r1, #2		// r1 <- vidas necesarias para dibujar ' '
			mov r2, #'/'	// r2 <- pierna izquierda
			mov r3, #11		// r3 <- numero de fila
			mov r3, #22		// r4 <- numero de columna
			bl actualizarParteEnMapa
			pop {r0, r1, r2, r3, r4, lr}
			bx lr
       .fnend
	   
	/**
	*	Actualiza en el mapa el caracter correspondiente 
	*	en el lugar de la pierna derecha: si vidas >= 1, dibujar '\\'.
	*	-----------------------------------------------------
	*	Entrada r0: numero de vidas
	*/
    actualizarPiernaDerEnMapa:
        .fnstart
			push {r0, r1, r2, r3, r4, lr}
			mov r1, #1		// r1 <- vidas necesarias para dibujar ' '
			mov r2, #'\\'	// r2 <- pierna derecha
			mov r3, #11		// r3 <- numero de fila
			mov r3, #24		// r4 <- numero de columna
			bl actualizarParteEnMapa
			pop {r0, r1, r2, r3, r4, lr}
			bx lr
       .fnend

    
    /**
    *	Actualiza la persona en el mapa, dibujando las partes
	*	correspondientes segun el numero de vidas restantes.
    */
    actualizarPersonaEnMapa:
		.fnstart
			push {r0, r1, lr}
			
			ldr r1, =vidas
			ldrb r0, [r1]   // r0 <- vidas restantes

			/* Todas estas subrutinas reciben las vidas en r0 */
			bl actualizarCabezaEnMapa
			bl actualizarPechoEnMapa
			bl actualizarBrazoIzqEnMapa
			bl actualizarBrazoDerEnMapa
			bl actualizarAbdomenEnMapa
			bl actualizarPiernaIzqEnMapa
			bl actualizarPiernaDerEnMapa
        
			pop {r0, r1, lr}
			bx lr
		.fnend
      
    /**
    *	Actualiza el mapa para representar el estado actual de la palabra actual,
	*	es decir, las letras descubiertas y las ocultas representadas por '_'.
    */
    actualizarPalabraActualEnMapa:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, lr}

			ldr r0, =mapa
			mov r2, #17		// numero de fila
			mov r3, #8		// r3 <- numeroColumna: contador para ir incrementando los indices del mapa, inicia en 8.
			mov r4, #53		// numero cantidad de columnas
			
			ldr r5, =palabraActual
			mov r6, #0		// r6 <- i (indice): contador para ciclar palabraActual
			
			cicloActualizarPalabraActualEnMapa:
				ldrb r1, [r5, r6]	// r1 <- palabraActual[i]
				
				cmp r1, #00
				beq finActualizarPalabraActualEnMapa	// palabraActual[i] == nul -> no quedan caracteres para actualizar
				
				bl reemplazarLetraEnMatriz
				
				add r3, #2		// numeroColumna += 2 (Incremento de a 2 para dejar un espacio entre las letras/guiones)
				add r6, #1		// i++
				bal cicloActualizarPalabraActualEnMapa // siguiente iteracion
        
			finActualizarPalabraActualEnMapa:
				pop {r0, r1, r2, r3, r4, r5, r6, lr}
				bx lr
      .fnend
  
    /**
    *   Imprime el estado del juego por consola.
    */
    informarResultado:
      .fnstart
        push {r0, r1, r2, lr}   // Protegemos los registros
        
        bl quedanLetrasPorAdivinar  // r2 <- si quedan letras o no (true o false)
        cmp r2, #1                  // Quedan letras?
        bleq imprimirMsjLetrasRestantes // Si -> imprimir letras restantes
        cmp r2, #0                  // Quedan letras?
        beq imprimirMsjJuegoGanado     // No -> se gano el juego
        
        ldr r1, =vidas   // r1 <- puntero =vidas
        ldrb r1, [r1]    // r1 <- numero vidas
        cmp r1, #0       // compara r1 con #0
        bleq imprimirJuegoPerdido
        
        bl actualizarMsjVidas
        ldr r1, =cadenaVidas
        ldr r2, =lenCadenaVidas
        bl imprimirLinea // Recibe r1: puntero cadena, r2: longitud
        
        finInformarResultado:  
          pop {r0, r1, r2, lr}    // Restauramos los registros
          bx lr       // Salimos de la funcion
      .fnend
  
    /**
    *   Actualiza el string al que apunta =inputUsuario 
    *   con lo que el usuario haya ingresado por consola.
    */
    leerDatos:
      .fnstart
        push {r0, r1, r2, r7, lr}
        mov r7, #3                  // Función escanear input del usuario
        mov r0, #0                  // El búfer
        ldr r2, =lenInputUsuario    // Longitud de la cadena del input
        ldr r1, =inputUsuario       // Donde se guarda el resultado
        swi 0
        pop {r0, r1, r2, r7, lr}
        bx lr
      .fnend
  
    /**
    *   True/false si la letra especificada está presente en la cadena.
    *   ---------------------------------------------------------------
    *   Entrada r0: direccion memoria de la cadena
    *   Entrada r1: direccion memoria de la letra
    *   ---------------------------------------------------------------
    *   Salida r2: 1 o 0 (true/false)
    */
    cadenaContieneLetra:
		.fnstart
			push {r0, r1, r3, r4, lr}
			mov r2, #0		// r2 <- contador para ciclar incia en 0
			ldrb r1, [r1]	// r1 <- la letra que ingreso el usuario: inputUsuario[0]
			
			cicloCadenaContieneLetra: 
				ldrb r3, [r0, r2]               // r3 <- cadena[i]
				
				cmp r3, #0
				beq letraNoEstaEnCadena         // Si cadena[i] == nul -> la letra NO esta en la cadena
				
				cmp r3, r1                      // r3 es igual que la letra que esta en r1?
				beq letraSiEstaEnCadena         // Si cadena[i] == letra -> la letra esta en la cadena
				
				add r2, #1                     	// i++
				bal cicloCadenaContieneLetra    // siguiente iteracion
  
			letraSiEstaEnCadena:
				mov r2, #1	// r2 <-- 1 para retornar true
				bal finCadenaContieneLetra
				
			letraNoEstaEnCadena:
				mov r2, #0	// r2 <-- 0 para retornar false
			
			finCadenaContieneLetra:
				pop {r0, r1, r3, r4, lr}
				bx lr
      .fnend

    /**
    *	Reemplazar la letra ingresada por el usuario en la 
	*	palabra actual a mostrar, las veces que sea necesario.
    */
    agregarLetraAPalabraActual:
		.fnstart
			push {r0, r1, r2, r3, r4, r5}

			ldr r0, =palabraOculta
            ldr r1, =inputUsuario

			ldr r2, =palabraActual

			ldrb r3, [r1]	// r3 <- letra

			mov r4, #0		// r4 <- i: contador para iterar, empieza en 0

			cicloAgregarLetraAPalabra:
				ldrb r5, [r0, r4]    // r5 <- palabraOculta[i]

				cmp r5, #00
				beq finAgregarLetraAPalabraActual	// Si palabraOculta[i] == nul -> terminamos de iterar palabraActual

				cmp r5, r3
				bne sigCicloAgregarLetraAPalabra	// Si palabraOculta[i] != letra -> siguiente iteracion

				strb r3, [r2, r4]    				// else -> palabraActual[indice] = letra
			
			sigCicloAgregarLetraAPalabra:
				add r4, #1	// i++
				bal cicloAgregarLetraAPalabra

			finAgregarLetraAPalabraActual:
				pop {r0, r1, r2, r3, r4, r5}
				bx lr
      .fnend

	/**
	*	Resta una vida al contador de vidas restantes en =vidas.
	*/
    quitarVida:
		.fnstart
			push {r0, r1, r2}
			
			ldr r0, =vidas
			ldrb r1, [r0]	// r1 <- vidas
			sub r2, r1, #1	// r2 = vidas - 1
			strb r2, [r0]	// vidas = r2
			
			pop {r0, r1, r2}
			bx lr
		.fnend

	/**
	*	Copia el contenido de la primera cadena en la segunda.
	*	Precaución: ambas cadenas deben tener el mismo espacio reservado 
	*	en memoria para evitar pisar espacios por fuera de la cadena2.
	*	----------------------------------------------------------------
	*	Entrada r0: puntero a cadena1, que tiene el contenido a copiar
	*	Entrada r1: punteor a cadena2, que recibira el nuevo contenido
	*/
	copiarCadenas:
		.fnstart
			push {r0, r1, r2, r3}
			
			mov r2, #0	// r2 <- i (indice): contador para ciclar
			
			cicloCopiarCadenas:
				
				ldrb r3, [r0, r2]		// cadena1[i]
				
				cmp r3, #00
				beq finCopiarCadenas	// Si cadena1[i] == nul -> no quedan caracteres por copiar
				
				strb r3, [r1, r2]		// cadena2[i] = cadena1[i]
				
				add r2, #1				// i++
				bal cicloCopiarCadenas	// siguiente iteracion

			finCopiarCadenas:
				pop {r0, r1, r2, r3}
				bx lr
		.fnend

    /**
    *	Copia el contenido de palabraOculta en palabraActual.
    */
    revelarPalabraOculta:
		.fnstart
			push {r0, r1, lr}

			ldr r0, =palabraOculta	// Entrada r0: palabra a copiar
			ldr r1, =palabraActual	// Entrada r1: palabra que recibe contenido
			bl copiarCadenas

			pop {r0, r1, lr}
			bx lr
		.fnend

	/*
	*	Devuelve 1 (true) o 0 (false) si lo que ingreso
	*	el usuario es la palabra oculta.
	*	-----------------------------------------------
	*	Salida r0: 1 (true) o 0 (false)
	*/
	usuarioAcertoPalabra:
		.fnstart
			push {r1, r2, r3, r4}

			ldr r0, =palabraOculta
			ldr r1, =inputUsuario
			
			mov r2, #0              // r2 <- i (contador para iterar)

			cicloUsuarioAcertoPalabra:
				ldrb r3, [r0, r2]    // r3 <- palabraOculta[i]

				cmp r3, #00
				beq siUsuarioAcertoPalabra	// Si palabraOculta[i] == nul -> iteramos hasta el final y no hubo diferencias, acerto

				cmp r3, #' '
				beq siUsuarioAcertoPalabra	// Si palabraOculta[i] == ' ' -> iteramos hasta el final y no hubo diferencias, acerto

				ldrb r4, [r1, r2]    // r4 <- inputUsuario[i]
				
				cmp r3, r4
				bne noUsuarioAcertoPalabra	// Si palabraOculta[i] != inputUsuario[i] -> no acerto

				add r2, #1	// i++
				bal cicloUsuarioAcertoPalabra
			
			siUsuarioAcertoPalabra:
				mov r0, #1
				pop {r1, r2, r3, r4}
				bx lr
			
			noUsuarioAcertoPalabra:
				mov r0, #0
				pop {r1, r2, r3, r4}
				bx lr
		.fnend
		
	/*
	*	Devuelve 1 (true) o 0 (false) si lo que ingreso
	*	el usuario es la palabra oculta.
	*	-----------------------------------------------
	*	Salida r0: 1 (true) o 0 (false)
	*/
	usuarioAcertoLetra:
		.fnstart
			push {r1, r2, lr}

			ldr r0, =palabraOculta
            ldr r1, =inputUsuario
			bl cadenaContieneLetra  // r2 <- cadenaContieneLetra(r0:cadena, r1:letra): true/false
			mov r0, r2				// copiamos a r0 para retornarlo ahi

			pop {r1, r2, lr}
			bx lr
		.fnend
  
    /**
    *   Determina si la letra elegida pertenece a la 
    *   palabra oculta y, si es así, actualiza el mapa.
    */
    procesarDatos:
        .fnstart
            push {r0, r1, r2, lr}
            
            ldr r0, =inputUsuario
            
            ldrb r1, [r0, #1]       	// r1 <- inputUsuario[1]
            cmp r1, #'\n'           	// ¿inputUsuario[1] == '\n'?
            bne usuarioArriesgoPalabra	// El '\n' esta mas atras, ingreso una palabra
            beq usuarioArriesgoLetra
			
           
			ldr r0, =palabraOculta
            ldr r1, =inputUsuario

            bl cadenaContieneLetra  // r2 <- true o false si letra en cadena. Recibe en r0 la cadena, y en r1 la letra a verificar.
            cmp r2, #1              // Si r2 es true              
            bleq agregarLetraAPalabraActual // Si r2 es true agregamos la letra
            blne quitarVida
            blne guardarLetraUsada
            
			
			usuarioArriesgoPalabra:
				bl usuarioAcertoPalabra	// r0 <- 1 o 0 (true/false) si acerto
				cmp r0, #1
			
			marcarJuegoGanado:
				
			
			usuarioArriesgoLetra:
				ldr r0, =palabraOculta
				ldr r1, =inputUsuario
				bl cadenaContieneLetra  // r2 <- cadenaContieneLetra(r0:cadena, r1:letra): true/false
				cmp r2, #1
				bne usuarioNoAcertoLetra
				bl agregarLetraAPalabraActual

			usuarioNoAcertoLetra:
				bl quitarVida
				bl guardarLetraUsada

			finProcesarDatos:
				bl actualizarPalabraActualEnMapa
				bl actualizarPersonaEnMapa
				pop {r0, r1, r2, lr}
				bx lr
        .fnend
  
    /**
    *	Imprime por consola la solictud al usuario de ingresar
	*	una letra minuscula o la palabra si desea adivinar, 
	*	lee lo ingresado y vuelve a solicitar si lo que ingreso
	*	no es valido.
    */
    pedirLetra:
        .fnstart
            push {r0, r1, r2, lr}

            cicloPedirLetra:
            
                /* Imprimir mensaje de solicitud */
                ldr r1, =solicitudLetra
                ldr r2, =lenSolicitudLetra
                bl imprimir                    // imprimir(r1: cadena, r2: largo cadena)
                
				/* Registrar el input del usuario */
                bl leerDatos        // Registramos el input del usuario    
                
				ldr r0, =inputUsuario
                ldrb r1, [r0]			// inputUsuario[0]
                
                cmp r1, #'a'
                blt cicloPedirLetra		// Si inputUsuario[0] < 'a' -> volver a pedir
                
                cmp r1, #'z'
                bgt cicloPedirLetra		// Si inputUsuario[0] < 'z' -> volver a pedir
                
            finCicloPedirLetra:
                pop {r0, r1, r2, lr}
                bx lr
        .fnend
  
    /**
    *
    *  TODO.
    */
    jugar:
        .fnstart
            push {lr}
            bl imprimirMapa     // Imprimimos el mapa por consola  
            bl informarResultado
            bl pedirLetra
            bl procesarDatos 
            bal jugar
            pop {lr}
            bx lr
        .fnend
      
    /**
    *  Convierte un numero en ascii a su equivalente en decimal.
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
    *  Entrada r1: el numero elegido por el usuario.
    */
    cargarPalabra:
        .fnstart
            push {r0, r2, r3, r4, r5, r6, r7, lr}
            ldr r0, =inputUsuario  // r0 <- puntero a =inputUsuario

            ldr r2, =lemario       // r2 <- puntero =lemario

            mov r3, #1             // r3 <- #1: contador (de palabras)
            mov r4, #0             // r4 <- #0: i (indice) (de caracteres)

            cmp r1, #1
            beq cargarDesdeAca
       
        cicloCargarPalabra:
        
            cmp r3, r1
            beq cargarDesdeAca

            ldrb r5, [r2, r4]    // r5 <- inputUsuario[i]

            cmp r5, #','
            beq incrementarContadorCargarPalabra
            add r4, #1
            bal cicloCargarPalabra
        
        incrementarContadorCargarPalabra:
            add r3, #1
            add r4, #1
            bal cicloCargarPalabra
          
        cargarDesdeAca:
        
            ldr r6, =palabraOculta    // r6 <- puntero palabraOculta 
            mov r7, #0                // r7 <- contador j
            ldr r8, =palabraActual    // r6 <- puntero palabraOculta
            mov r9, #'_'

            //add r12, r7, r1
            //cmp r12, #1
            //beq restarI
          
            subCiclo:          
                add r4, #1           // i++
                ldrb r5, [r2, r4]    // r5 <- inputUsuario[i]

                cmp r5, #','
                beq finCicloCargarPalabra

                strb r5, [r6, r7]    // r5 -> palabraOculta[j]
                strb r9, [r8, r7]
                add r7, #1           // r7 <- j++

                bal subCiclo         // Siguiente iteracion
          
            finCicloCargarPalabra:
                pop {r0, r2, r3, r4, r5, r6, r7, lr}
                bx lr
        .fnend
    
    /**
    *  Solicita al usuario que ingrese un numero y carga la palabra correspondiente a la eleccion.
    */
    elegirPalabra:
        .fnstart
            push {r0, r1, r2, r3, lr}  // Protegemos registros.
            
            mov r10, #1      // r10 <- true (#1)
            
            cicloSeleccionarPalabra:
              
                // Le pedimos al usuario que ingrese un numero
                ldr r1, =solicitudNumero       // Entrada1 borrarEImprimir
                ldr r2, =lenSolicitudNumero    // Entrada2 borrarEImprimir
                bl borrarEImprimir              // Imprime el mensaje en consola
                
                bl leerDatos      // Registramos el input del usuario (actualiza =inputUsuario)
                
                ldr r0, =inputUsuario   // r0 <- puntero a inputUsuario 
                bl asciiADecim          // r1 <- el equivalente en numero de lo ingresado en ascii
                
                cmp r1, #1                    // Compara r1 con #1
                blt cicloSeleccionarPalabra   // Si es menor, volvemos a intentar
                
                cmp r1, #20                   // Compara r1 con #20
                bgt cicloSeleccionarPalabra   // Si es mayor, volvemos a intentar
                
                bal finCicloSeleccionarPalabra  // Si esta dentro del rango, estamos ok para continuar
            
            finCicloSeleccionarPalabra:
              bl cargarPalabra    // Cargamos la palabra en =palabraOculta
              bl actualizarPalabraActualEnMapa  // Actualizamos los "_____" en el mapa.
              pop {r0, r1, r2, r3, lr}  // Restauramos registros
              bx lr                     // Salimos de la subrutina
        .fnend

	.global main
	main:

		bl elegirPalabra

		cicloWhile:
			bl jugar

			ldr r0, =run
			ldr r1, [r0]

			cmp r1, #1
			beq cicloWhile	// Si run == True -> entrar al while otra vez

	fin:
		mov r7, #1
		swi 0
