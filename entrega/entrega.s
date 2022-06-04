
@ Declaramos las constantes, reservando el espacio en memoria
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


     /* Definicion de datos */
    mapa:   .asciz "___________________________________________________|\n"
            .asciz "                                                   |\n"
            .asciz "     *** EL JUEGO DEL AHORCADO - ORGA 1 ***        |\n"
            .asciz "___________________________________________________|\n"
            .asciz "                                                   |\n"
            .asciz "                                                   |\n"
            .asciz "          +------------+                           |\n"
            .asciz "          |                                        |\n"
            .asciz "          |                                        |\n"
            .asciz "          |                                        |\n"
            .asciz "          |                                        |\n"
            .asciz "          |                                        |\n"
            .asciz "          |                                        |\n"
            .asciz "          |                                        |\n"
            .asciz "          |                                        |\n"
            .asciz " +-------------------------------------------+     |\n"
            .asciz " |                                           |     |\n"
            .asciz " |                                           |     |\n"
            .asciz " |                                           |     |\n"
            .asciz " +-------------------------------------------+     |\n"
            longitud =.- mapa
   
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

    


@ Declaramos nuestro código del programa
.text
          .fnend
//----------------------------------------------------------
clearScreen:
      .fnstart
      mov r0, #1
      ldr r1, =cls
      ldr r2, =lencls
      mov r7, #4
      swi #0

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
    
    // ! ↓↓↓↓ DE ACA PARA ABAJO LO HICIMOS EL 04/06 ↓↓↓↓
    // r0 <-- direc memoria cadena1
    // r1 <-- direc memoria cadena2
    // Salida r2: si son iguales (1: true, 0: false)
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
    
    // Entrada r0: dirección memoria cadena1
    // Entrada r1: dirección memoria cadena2
    // Salida r2: si son iguales, 1 (true), 0 (false)
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

    // Entrada r1: cantidad de vidas a restar
    quitarVidas:
        @todo: vidas--
        @todo - BRIAN
    
    // Actualiza la "matrizAciertos"
    revelarPalabraSecreta:
        @todo - JUAN
    
    // Compara si la palabra arriesgada por el usuario es igual a la secreta
    // Si no acerto:
    //         * Ganado -> false
    //         * Vidas = 0
    //         * Revela la palabra secreta
    // Si acerto: ganado es true
    // Entrada r1: la direccion memoria del input del usuario
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

    // Entrada r0: direccion memoria de la cadena
    // Entrada r1: direccion memoria de la letra
    // Salida r2: 1 o 0 (true/false)
    cadenaContieneLetra:
        @ todo - JUAN

    // Agrega la letra acertada al mapa
    // Entrada r0: el puntero al string con la letra
    agregarAciertoAlMapa:
        @todo - JUAN

    // Agrega la letra usada al stack de letras usadas
    // Entrada r0: el puntero de la letra
    agregarLetraUsada:
        @todo - JUAN

    // Entrada r1: la dir mem del input del usuario
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


    // Actualiza el asciz que empieza en =inputUsuario
    // con la letra elegida por el usuario
    escanear:
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


    // Se encarga del modo de juego para salvarse si no quedan vidas
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

    // Le hace al usuario una pregunta de aproximacion para restaurarle vida(s)
    preguntaAproximativa:
        @todo - BRIAN
        // Imprime una pregunta aleatoria
        // Si la respuesta es similar
        // vidas += 1

        // si la respuesta es incorrecta
        // vidas = 0.

    // Imprime todo en pantalla, recopila el input del usuario
    // y altera los estados del juego para la proxima iteracion
    jugar:
        .fnstart
            push {r1, lr}           // Protegemos los registros
            
            /* INI IMPRIMIMOS TODO */
            bl imprimirMapa
            bl imprimirAciertos
            bl feedback
            /* FIN IMPRIMIMOS TODO */            

            /* TOMAR EL INPUT DEL USUARIO */
            bl escanear             // El SO guarda a partir de =inputUsuario (dir mem) el input
            ldr r1, =inputUsuario   // r1 <-- colocamos esa direccion
            bl largoCadena          // r0 <-- largo cadena de [=inputUsuario]
            cmp r0, #1              // Comparamos r0 (largo) con #1
            blt finJugar            // Si el input es "" (cadena vacia), vamos a la siguiente iteracion (para el usuario no paso nada)
            bgt arriegarPalabra     // Si es mayor que 1, intento arriesgar palabra
            bal arriesgarLetra      // 
            finJugar:
                pop {r1, lr}            // Quitamos protección
                bx lr                   // Volvemos a donde sea que nos llamaron
        .fnend

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

    @ Donde empieza nuestro programa
    .global main
    main:
        bl cicloWhile


    @ Para manejar el fin del programa
    fin:
        mov r7, #1  // Instrucción para salir del programa
        swi 0       // Interrumpimos para terminas
