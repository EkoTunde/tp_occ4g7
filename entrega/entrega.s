
/* Definicion de datos */
.data
    feedback: .asciz "Quedan x letras por adivinar."
    vidas: .byte 7
    msjArriesgarLetra:          .asciz "Por favor, ingrese la letra que desea arriegar: "
    letraElegida:               .asciz " \n"
    plantillaEscanear: .ascii "Esta es la plantilla para escanear"
    solicitudNumero: .ascii "Por favor, ingrese un número entre 0 y 9, inclusive: "
	vida0: .ascii "0" // IGNORENME

    inputUsuario: .asciz "                                        "
    palabraSecreta: .asciz "holanda"
    ganado: .byte 0
    letrasUsadas: .asciz "                           "
    /*pregunta1: acasñdasda
    respuestaEsperada1: sdklajdlkajsd
    respuestaUsuario*/

    lemario: .asciz ""


    /* Definicion de datos */
    /*              000000000011111111112222222222333333333344444444445555          */
    /*              012345678901234567890123456789012345678901234567890123          */
    mapa:   .asciz "╔══════════════════════════════════════════════════╗\n" // 00 
            .asciz "║     *** EL JUEGO DEL AHORCADO - ORGA 1 ***       ║\n" // 01
            .asciz "╠══════════════════════════════════════════════════╣\n" // 02
            .asciz "║                                                  ║\n" // 03
            .asciz "║                                                  ║\n" // 04
            .asciz "║          ┌────────────┐                          ║\n" // 05
            .asciz "║          │            │                          ║\n" // 06
            .asciz "║          │            o                          ║\n" // 07
            .asciz "║          │           /│\                         ║\n" // 08
            .asciz "║          │            │                          ║\n" // 09
            .asciz "║          │           / \                         ║\n" // 10
            .asciz "║          │                                       ║\n" // 11
            .asciz "║          │                                       ║\n" // 12
            .asciz "║          │                                       ║\n" // 13
            .asciz "║  ┌───────────────────────────────────────────┐   ║\n" // 14
            .asciz "║  │                                           │   ║\n" // 15
            .asciz "║  │                                           │   ║\n" // 16
            .asciz "║  │                                           │   ║\n" // 17
            .asciz "║  └───────────────────────────────────────────┘   ║\n" // 18
            .asciz "╚══════════════════════════════════════════════════╝\n" // 19
            longitud =.- mapa
    
    msjLetrasRestantes: .asciz "quedan x letras por adivinar!\n"
    msjJuegoTermino: .asciz "Game Over"
    msjVidasRestantes: .asciz "vida: 0"

    /* 
    ╔════════════════════════════════════════════════╗
    ║ INDICES DE LAS PARTES DEL CUERPO DEL AHORCADO: ║
    ╠════════════════════════════════════════════════╣
    ║ CABEZA  -> [7][23]                             ║
    ║ PECHO   -> [8][23]                             ║
    ║ ABDOMEN -> [9]][23]                            ║
    ║ BZO IZQ -> [8][22]                             ║
    ║ BZO DER -> [8][24]                             ║
    ║ PIE IZQ -> [10][22]                            ║
    ║ PIE DER -> [10][24]                            ║
    ╚════════════════════════════════════════════════╝
    */
   
    /*
    matrizAciertos: .asciz "+-------------------------------------------+      |\n"
                        .asciz "|                                           |      |\n"
                        .asciz "|    @a@@us                                 |      |\n"
                        .asciz "|                                           |      |\n"
                        .asciz "+-------------------------------------------+      |\n"
                        longitudMatrizAciertos=.-matrizAciertos
    */
    enter: .ascii "\n"

    cls: .asciz "\x1b[H\x1b[2J" //una manera de borrar la pantalla usando ansi escape codes
    lencls = .-cls

    


//----------------------------------------------------------
.text             @ Defincion de codigo del programa
//----------------------------------------------------------

//----------------------------------------------------------
clearScreen:
      .fnstart
        push {r0, r1, r2, r7, lr}
        mov r0, #1
        ldr r1, =cls
        ldr r2, =lencls
        mov r7, #4
        swi #0
        pop {r0, r1, r2, r7, lr}
        bx lr //salimos de la funcion mifuncion
      .fnend

//----------------------------------------------------------


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

    
    
    // Entrada r0: el numero a convertir
    // Salida r1: el valor en ascii
    asciiANum:
        /*.fnstart
            push {lr}
            ldr r1, =plantillaEscanear
            ldrb r2, [r1]
            sub r2, #48
            pop {lr}
            bx lr
        .fnend
        */

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

    // Actualiza el asciz que empieza en =letraElegida
    // con la letra elegida por el usuario
    escanearLetra:
        .fnstart
            push {r0, r1, r2, r7, lr}   // Protegemos los registros
            ldr r1, =msjArriesgarLetra  // Mensaje al usuario
            bl imprimirAsciz            // Imprime la solicitud al usuario
            mov r7, #3                  // Función escanear input del usuario
            mov r0, #0                  // EL búfer
            mov r2, #1                  // Con cuánto me quedo del input
            ldr r1, =letraElegida       // Donde se guarda el resultado
            swi 0                       // SWI, Software interrupt
            pop {r0, r1, r2, r7, lr}    // Quitamos la protección de los registros
            bx lr                       // Volvemos
        .fnend

    // imprime cuadrante de matriz de palabra a adivinar
	// Entrada r1 -> dirección de memoria
	imprimirAciertos:
		.fnstart
            push {r1, r2, lr} // Protegemos los registros
            ldr r1, =matrizAciertos
            ldr r2, =longitudMatrizAciertos
            bl imprimir
            pop {r1, r2, lr}
            bx lr
		.fnend
    
    // 
    
    //----------------------------------------------------------
    imprimirString:
        .fnstart
            //Parametros inputs:
            //r1=puntero al string que queremos imprimir
            //r2=longitud de lo que queremos imprimir
            push {lr}
            push {r1}
            push {r2} 
            bl clearScreen
            pop {r2}
            pop {r1}
            mov r7, #4 // Salida por pantalla  
            mov r0, #1      // Indicamos a SWI que sera una cadena           
            swi 0    // SWI, Software interrup
            pop {lr}
            bx lr //salimos de la funcion mifuncion
        .fnend


    // ! ↓↓↓↓ DE ACA PARA ABAJO LO HICIMOS EL 04/06 ↓↓↓↓

/******** INI MISMO LARGO CADENAS *******************************************************************/
    /**
    *   Entrada r0: puntero cadena1
    *   Entrada r1: puntero cadena2
    *   -----------------------------------------
    *   Salida r2: 1 (true) o 0 (false) si son iguales o no
    */
    mismoLargoCadenas:
      .fnstart
        push {r0, r1, lr}

        push {r0, r1}
        mov r1, r0      // temporalmente guardo direc cadena1 en r1
        bl largoCadena  // r1 la direc, devuelve largo en r0
        mov r2, r0      // r2 <-- largo cadena1 (que estaba en r0, ahí la dejó largoCadena)
        pop {r0, r1}

        push {r0}
        bl largoCadena // r1 tiene la direccion memoria de cadena2 - r1 la direc, devuelve largo en r0
        mov r3, r0     // r3 <-- largo cadena2 (que estaba en r0, ahí la dejó largoCadena)
        pop {r0}

        // r2: largo cadena1, r3: largo cadena2

        cmp r2, r3

        mov r2, #0
        beq tieneMismoLargo
        bal noTienenMismoLargo

        tieneMismoLargo:
          mov r2, #1
          bal finMismoLargoCadena

        noTienenMismoLargo:
          mov r2, #0
          bal finMismoLargoCadena

        finMismoLargoCadena:
          pop {r0, r1, lr}
          bx lr
      .fnend
    
    
    
    
/******** FIN MISMO LARGO CADENAS *******************************************************************/


/******** INI CADENAS SON IGUALES *******************************************************************/
    /**
    *   Entrada r0: puntero cadena1
    *   Entrada r1: puntero cadena2
    *   -----------------------------------------
    *   Salida r2: 1 (true) o 0 (false) si son iguales o no
    */
    cadenasSonIguales:
        .fnstart
            push {r0, r1, r3, r4, r5, r6, lr}
            mov r3, #0          // r3 <-- 0 Inicializamos el contador

            push {r0, r1, lr}
            bl largoCadena      // r0 <-- largo cadena (Entrada r1: dir mem cadena, Salida r0: su largo)
            mov r6, r0          // r6 <-- r0 porque ahi esta el largo de la cadena
            push {r0, r1, lr}

            whileContMenorLargo:
                cmp r3, r6          // Comparamos el contador con el largo
                beq lasCadenasSonIguales

                // Agarrar el valor actual de cadena1
                ldr r4, [r0, r3]    // r4 es el caracater de cadena1 en el indice r3
                ldr r5, [r1, r3]    // r5 es el caracater de cadena2 en el indice r3

                cmp r4, r5          // Comparamos r4:cadena1[r3] con r5:cadena2[r3]
                bne lasCadenasNoSonIguales // Tenemos que devolver false si no son iguales (BNE)

                add r3, #1          // r3 <-- r3 + 1 (incrementar el contador)
                bal whileContMenorLargo // Siguiente iteracion

            lasCadenasNoSonIguales:
                mov r2, #0
                bal finCadenasSonIguales

            lasCadenasSonIguales:
                mov r2, #1
                bal finCadenasSonIguales

            finCadenasSonIguales:
                pop {r0, r1, r3, r4, r5, r6, lr}    // Devolvemos los valores originales a los registros
                bx lr
            
        .fnend

/******** FIN CADENAS SON IGUALES *******************************************************************/
    

/******** INI QUITAR VIDAS **************************************************************************/
    /**
    *   Entrada r1: cantidad de vidas a restar
    */
    quitarVidas:
        @todo: vidas--
        @todo - BRIAN
/******** FIN QUITAR VIDAS **************************************************************************/


/******** INI REEMPLAZAR LETRA EN MATRIZ ************************************************************/
    /**
    *   Reemplaza el caracter de la matriz en los indices indicados, por el caracter indicado.
    *   offset = puntero + (fila x cant_columnas x tamaño_bytes) + (columna x tamaño_bytes)
    *   --------------------------------------------------------------------------------------
    *   Entrada r0: puntero de la matriz
    *   Entrada r1: puntero al ascii de reemplazo
    *   Entrada r2: numero de fila
    *   Entrada r3: numero de columna
    *   Entrada r4: numero cantidad de columnas
    */
    reemplazarLetraEnMatriz:
        .fnstart
            push {r0, r1, r2, r3, r4, r5, lr}
            mul r5, r2, r4      // r5 <-- r2 x r4 : fila x cant_columnas
            add r5, r3          // r5 <-- r5 + r3 : r5 + numero de columna
            ldrb r1, [r1]       // r1 <-- dato apuntado por r1 (caracter ascii)
			strb r1, [r0, r5]   // Cargamos en direccion r0+r4 lo que esta en r1
			pop {r0, r1, r2, r3, r4, r5, lr}
			bx lr
        .fnend
/******** FIN REEMPLAZAR LETRA EN MATRIZ ************************************************************/


/******** INI REVELAR LETRA EN MAPA *****************************************************************/
    /**
    *   Revela la letra en el mapa.
    */
    revelarLetra:
        .fnstart
            //push {r0, r1, r2, r3, r4, r5, lr}

            ldr r0, =mapa
            ldr r1, =palabraSecreta
            ldr r2, =inputUsuario

            mov r3, #0      // r3 <-- #0 : Contador en 0

            ldrb r4, [r2]   // r4 <-- dato apuntado por r2 (=inputUsuario)

            bal cicloRevelarLetra   // Iniciamos el ciclo

            cicloRevelarLetra:
                ldrb r5, [r1, r3]   // r5 <-- el caracter de "palabraSecreta" al que apunta r1+r3

                cmp r5, #0          // Compara con caracter nulo
                beq finCicloRevelarLetra    // Si es nulo termina de iterar, no hay mas letras en la "palabraSecreta"

                add r3, #1  // Sino, incrementamos el contador
                
                cmp r4, r5          // Comparamos r4 (letra arriesgada) con r5 (caracter actual)
                beq agregarLetraAlMapa  // Si son iguales, agregamos la letra en el mapa
                bal cicloRevelarLetra   // Sino, pasamos a la siguiente iteracion.    
            
            agregarLetraAlMapa:
                push {r0, r1, r2, r3, r4, lr}   // Guardamos los registros con sus valores actuales al momento, porque vamos a setear la comparacion
                // r0 <-- puntero del mapa
                // r3 <-- columna : ya se encuentra el contador
                ldr r1, =inputUsuario   // r1 <-- puntero de lo ingresado por el usuario
                mov r2, #16             // r2 <-- #16 : fila 16 es donde se escriben las letras develadas de la palabra
                mov r4, #53             // r4 <-- #53 : cantidad de columnas
                bl reemplazarLetraEnMatriz      // Reemplazamos
                pop {r0, r1, r2, r3, r4, lr}    // Restauramos los valores de los registros guardados
                bal cicloRevelarLetra

            finCicloRevelarLetra:
                pop {r0, r1, r2, r3, r4, r5, lr}
                bx lr
        .fnend
/******** FIN REVELAR LETRA EN MAPA *****************************************************************/


/******** INI REVELAR PALABRA SECRETA ***************************************************************/
    /**
    *   Actualiza la parte del mapa que muestra las letras reveladas de la palabra secreta.
    */
    revelarPalabraSecreta:
        @todo - JUAN
/******** FIN REVELAR PALABRA SECRETA ***************************************************************/


/******** INI ARRIESGAR PALABRA *********************************************************************/
    /**
    *   Compara si la palabra arriesgada por el usuario es igual a la secreta.
    *   Si no acertó:
    *           - Ganado = false
    *           - Vidas = 0
    *           - Revela la palabra secreta
    *   Si acertó:
    *           - Ganado = true
    *   ----------------------------------------------------------------------
    *   Entrada r1: puntero al input del usuario
    */
    arriesgarPalabra:
        .fnstart
            push {r0, r1, r2, lr}
            
            ldr r0, =palabraSecreta     // r0 <-- direccion memoria de =palabraSecreta
            bl cadenasSonIguales        // r2 <-- true/false si las cadenas son iguales

            cmp r2, #0                  // Compara r2 con 0
            beq noAcertoPalabra         // Si es 0, no acerto
            bal acertoPalabra           // Sino, acerto

            // Si acertó
            acertoPalabra:
                // Gano juego, setear los estados
                // Poner en =ganado un 1
                ldr r1, =ganado         // r1 <-- direccion memoria de =ganado
                mov r2, #1              // r2 <-- 1 (true)
                strb r2, [r1]           // guarda en r1 el valor de r2
                bal finAcertoPalabra    // Saltamos al final del procedimiento


            // Si no acertó
            noAcertoPalabra:
                ldr r1, =ganado         // r1 <-- direccion memoria de =ganado
                mov r2, #0              // r2 <-- 0 (false)
                strb r2, [r1]           // guarda en r1 el valor de r2
                
                /* FUNCION DE DISPARAR PARA GANAR */
                bl dispararParaGanar

                bal finAcertoPalabra    // Saltamos al final del procedimiento

            finAcertoPalabra:
                bl revelarPalabraSecreta    // revela la palabra secreta actualizando matrizAciertos
                mov r1, #7                  // r1 <-- vidas a restar
                bl quitarVidas              // Resta las vidas
                pop {r0, r1, r2, lr}
                bal finJugar
        .fnend
/******** FIN ARRIESGAR PALABRA *********************************************************************/


/******** INI CADENA CONTIENE LETRA *****************************************************************/
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
            push {r0, r1, r3, r4, lr}   // Protegemos los registros que vamos a usar
            mov r2, #0                  // Inicializamos contador en 0
            ldrb r1, [r1]               // r1 <-- la letra: primer byte de lo que apunta el puntero que estaba en r1
            bal cicloCadenaContieneLetra
            cicloCadenaContieneLetra: 
                ldrb r3, [r0, r2]               // r3 <-- letra actual de la cadena - Byte que que apunta el puntero r0 + r2 (contador)
                cmp r3, #0                      // r3 es el caracter nulo?
                beq letraNoEstaEnCadena         // Si lo es, la letra no esta en la cadena
                cmp r3, r1                      // r3 es igual que la letra que esta en r1?
                beq letraSiEstaEnCadena         // Si lo es, la letra esta en la cadena
                add r2, #1                      // Si no lo es, incrementamos el contador
                bal cicloCadenaContieneLetra    // Volvemos a iterar

            letraNoEstaEnCadena:
                mov r2, #0                  // r2 <-- 0 (false)
                bal finCadenaContieneLetra  // Salimos del procedimiento 

            letraSiEstaEnCadena:
                mov r2, #1                  // r2 <-- 1 (true)
                bal finCadenaContieneLetra  // Salimos del procedimiento 
                
            finCadenaContieneLetra:
                pop {r0, r1, r3, r4, lr}
                bx lr
        .fnend
/******** FIN CADENA CONTIENE LETRA *****************************************************************/


/******** INI AGREGAR ACIERTO AL MAPA ***************************************************************/
    /**
    *   Agrega la letra acertada al mapa.
    *   ---------------------------------
    *   Entrada r0: puntero al string con la letra
    */
    agregarAciertoAlMapa:
        @todo - JUAN
/******** FIN AGREGAR ACIERTO AL MAPA ***************************************************************/


/******** INI AGREGAR LETRAS USADA ******************************************************************/
    /**
    *   Agrega la letra usada al string de letras usadas
    *   ------------------------------------------------
    *   Entrada r0: puntero al string con las letras usadas
    *   Entrada r1: puntero al string con la letra para agregar
    */
    agregarLetraUsada:
        @todo - JUAN
/******** FIN AGREGAR LETRAS USADA ******************************************************************/


/******** INI ARRIESGAR LETRA ***********************************************************************/
    /**
    *   Procesa la funcionalidad del usuario arriesgando una letra.
    *   -----------------------------------------------------------
    *   Entrada r1: puntero al string del input del usuario
    */
    arriesgarLetra:
        .fnstart
            push {r0, r1, r2, lr}

            /* CONSULTAR */
            // Si la letra ya se uso:
            // 1) Le decimos que ya se uso
            // 2) finArriesgarLetra para avanzar a la siguiente iteracion
            /* CONSULTAR */
            
            bl agregarLetraUsada    // Agregar la letra a las letras usadas

            ldr r0, =palabraSecreta     // Poner en r0 la direc palabra secreta
            bl cadenaContieneLetra      // r2 <-- true/false si la letra esta en la palabra secreta

            cmp r2, #0                  // Comparamos r2 con 0
            beq noAcertoLetra
            bal siAcertoLetra
            

            // Si acerto
            siAcertoLetra:
                // Actualizar el mapa
                mov r0, r1                  // r0 <-- r1: esta puntero del input usuario (param del procedimiento)
                bl agregarAciertoAlMapa     // Se agrega al mapa
                bal finArriesgarLetra
            
            // Si no acertó
            noAcertoLetra:
                // Bajar una vida
                mov r1, #1              // La cantidad de vidas a restar
                bl quitarVidas          // Resta la cantidad de vidas que haya en r1
                // Si no quedan vidas: pregunta aproximativa
                // Codigo para chequear si quedan vidas
                bl preguntaAproximativa
                // Si acierta la respuesta -> vidas += 1


                // Codigo para chequear si quedan vidas
                // Si quedan 0 vidas
                bl dispararParaGanar

                bal finArriesgarLetra

            finArriesgarLetra:
                pop {r0, r1, r2, lr}
                bal finJugar
        .fnend
/******** FIN AGREGAR LETRAS USADA ******************************************************************/


/******** INI LEER DATOS ****************************************************************************/
    /**
    *   Actualiza el string al que apunta =inputUsuario con lo que el usuario haya ingresado por consola.
    */
    leerDatos:
        .fnstart
            push {r0, r1, r2, r7, lr}
            mov r7, #3                    // Función escanear input del usuario
            mov r0, #0                    // EL búfer
            mov r2, #40                   // Con cuánto me quedo del input
            ldr r1, =inputUsuario         // Donde se guarda el resultado
            swi 0
            pop {r0, r1, r2, r7, lr}
            // Verificar si el sistema guarda un nul al final del input del usuario (max 40)
            // SI NO ES ASI -> reemplazar el primer espacio con un nul
            bx lr
        .fnend
/******** FIN LEER DATOS ****************************************************************************/


/******** INI PROCESAR DATOS ************************************************************************/
    /**
    *   Determina si la letra elegida pertenece a la palabra oculta y si es así actualizar el mapa a imprimir.
    */
    procesarDatos:
        .fnstart
            push {lr}
            
            ldr r1, =inputUsuario   // r1 <-- puntero del input del usuario
            bl largoCadena          // r0 <-- largo cadena del string al que apunta =inputUsuario
            cmp r0, #1              // Comparamos r0 (largo) con #1
            blt finProcesarDatos    // Si el input es menor a 1 (cadena vacia), vamos a la siguiente iteracion (para el usuario no paso nada)
            bgt arriesgarPalabra    // Si es mayor que 1, intento arriesgar palabra
            bal arriesgarLetra      // Si es 1, intento arriesgar una letra

            finProcesarDatos:
                pop {lr}
                bx lr
        .fnend
/******** FIN PROCESAR DATOS ************************************************************************/


/******** INI DISPARAR PARA GANAR *******************************************************************/
    /**
    *   Procesa el modo de juego, donde el usuario puede salvarse si no le quedan vidas.
    */
    dispararParaGanar:
        @todo - MATI
        // Usuario tiene que ingresar coordenas x e y

        // imprimir el texto "Ingresá una coordena x"
        // Escanar el input y guardar el resultado en un r

        // imprimir el texto "Ingresá una coordena y"
        // Escanar el input y guardar el resultado en otro r
        
        // Utilizar x e y como indices fila y columna en la matriz "mapa"
        // Si coincide con x=7 e y=14 le emboco
        // imprime "Diste en el blanco! Ganaste el juego.
        // bal fin
        
        // Si no coincide ganado = false
        // imprime "Te equivocaste. Perdiste el juego."
        // bal fin
/******** INI DISPARAR PARA GANAR *******************************************************************/


/******** INI PREGUNTA APROXIMATIVA *****************************************************************/
    /**
    *   Le hace al usuario una pregunta de aproximacion para restaurarle vida(s)
    */
    preguntaAproximativa:
        @todo - BRIAN
        // Imprime una pregunta aleatoria
        // Si la respuesta es similar
        // vidas += 1

        // si la respuesta es incorrecta
        // vidas = 0.
/******** FIN PREGUNTA APROXIMATIVA *****************************************************************/


/******** INI IMPRIMIR MAPA *************************************************************************/
    /**
    *   Imprime el mapa por consola
    */
    imprimirMapa:
        .fnstart
            push {r1, r2, lr}
            ldr r1, =mapa       // Cargamos en r1 la direccion del mensaje
            ldr r2, =longitud   // Tamaño de la cadena
            bl imprimirString   // Imprime el mapa
            pop {r1, r2, lr}
            bx lr               // Vuelve
        .fnstart
/******** FIN IMPRIMIR MAPA *************************************************************************/


/******** INI JUGAR *********************************************************************************/
    /**
    *   Imprime en pantalla el estado del juego, 
    *   registra el input del usuario y altera 
    *   los estados del juego segun esto.
    */
    jugar:
        .fnstart
            push {r1, lr}           // Protegemos los registros

            ldr r0, =vidas
            ldrb r0, [r0]
            cmp r0, #0
            beq preguntaAproximativa


            bl imprimirMapa     // Imprimimos el mapa por consola
            bl leerDatos        // Registramos el input del usuario
            bl procesarDatos    // 

            /* TOMAR EL INPUT DEL USUARIO */
            bl leerDatos            // El SO guarda a partir de =inputUsuario (dir mem) el input
            ldr r1, =inputUsuario   // r1 <-- colocamos esa direccion
            bl largoCadena          // r0 <-- largo cadena de [=inputUsuario]
            cmp r0, #1              // Comparamos r0 (largo) con #1
            blt finJugar            // Si el input es "" (cadena vacia), vamos a la siguiente iteracion (para el usuario no paso nada)
            bgt arriesgarPalabra     // Si es mayor que 1, intento arriesgar palabra
            bal arriesgarLetra      // 
            finJugar:
                pop {r1, lr}            // Quitamos protección
                bx lr                   // Volvemos a donde sea que nos llamaron
        .fnend
/******** FIN JUGAR *********************************************************************************/


/******** INI CICLO WHILE ***************************************************************************/
    // Es el ciclo general del programa
    // Acá dentro, se decide si salir, o continuar
    cicloWhile:
        .fnstart
            push {r1, lr}       // Protegemos registros porque los usuamos
            ldrb r1, =salir     // r1 <-- la direccion de =salir
            ldr r1, [r1]        // r1 <-- true: 1 o false: 0 (el contenido desde =salir)
            cmp r1, #1          // Si r1 es 1 (true)
            beq fin             // Hay que salir
            bl jugar            // Hay que jugar
            pop {r1, lr}        // Quitamos proteccion
            bal cicloWhile
        .fnend
/******** FIN CICLO WHILE ***************************************************************************/


/******** INI MAIN **********************************************************************************/
    @ Donde empieza nuestro programa
    .global main
    main:
        bl jugar
/******** INI MAIN **********************************************************************************/


/******** INI FIN ***********************************************************************************/
    @ Para manejar el fin del programa
    fin:
        mov r7, #1  // Instrucción para salir del programa
        swi 0       // Interrumpimos para terminas
/******** FIN FIN ***********************************************************************************/



// palabraOculta: "holanda"
// letrasUsadas: "abcde"
// palabraActual: "_______"
// mapa

//"holanda"
//"___a__a"

// String input = "a";
// for (int i = 0; i < palabraOculta.length; i++) {
//      if (palabraOculta[i] == input) {
//          palabraActual[i] = input;
//      } 
// }


//      ACTUALIZAR LETRAS DEVELADAS EN EL MAPA
//     int indice = 0;
//     for (int i = 0; i < palabraActual.length; i+=2) {
//          mapa[indice] = palabraActual[i];
//          indice += 2;
//     } 
//
//
//
//
