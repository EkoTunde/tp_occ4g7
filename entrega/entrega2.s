/* Definicion de datos */
/***************************** Defincion de datos *********************************/
.data
    mapa: .asciz "___________________________________________________|\n                                                   |\n     *** EL JUEGO DEL AHORCADO - ORGA 1 ***        |\n___________________________________________________|\n                                                   |\n                                                   |\n          +------------+                           |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n +-------------------------------------------+     |\n |                                           |     |\n |                                           |     |\n |                                           |     |\n +-------------------------------------------+     |\n"

    longitud = . - mapa
    /*
      
    00___________________________________________________|\n
    01                                                   |\n
    02    *** EL JUEGO DEL AHORCADO - ORGA 1 ***         |\n
    03___________________________________________________|\n
    04                                                |\n
    05                                                |\n
    06        +------------+                           |\n
    07        |            |                           |\n
    08        |            o                           |\n
    09        |           /|\\                          |\n
    10        |            |                           |\n
    11        |           / \\                          |\n
    12        |                                        |\n
            |                                        |\n
            |                                        |\n
    +-------------------------------------------+     |\n
    |                                           |     |\n
    |    _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _    |     |\n
    |                                           |     |\n
    +-------------------------------------------+     |\n
    */

    enter: .ascii "\n"

    cls: .asciz "\x1b[H\x1b[2J" //una manera de borrar la pantalla usando ansi escape codes
    lencls = .-cls

    saltoLinea: .ascii "\n"

    vidas: .word 7
    inputUsuario: .asciz "                    "
    lenInputUsuario = . - inputUsuario

    palabra: .ascii "computador"
    letrasUsadas: .ascii "                           "


/*********************** Defincion de codigo del programa **************************/
/* Defincion de codigo del programa */
.text             


/------------------------------------------------------------------------------------
    /**
    *   Imprime una cadena de caracteres ASCIZ y luego imprime un salto de linea
    *   ---------------------------------------------------------------
    *   Entrada r1: puntero al string que queremos imprimir
    *   Entrada r2: longitud de lo que queremos imprimir
    */
    imprimir:
        .fnstart
            push {r0, r7, lr}   // Protegemos los registros
            
            mov r7, #4          // La función de swi que necesitamos para imprimir
            mov r0, #1          // Indicamos a SWI que sera una cadena
            swi 0               // SWI, Software interrupt
            
            pop {r0, r7, lr}    // Restauramos los registros
            bx lr               // Salimos de la funcion
        .fnend

/------------------------------------------------------------------------------------
    /**
    *   Imprime una cadena de caracteres ASCIZ y luego imprime un salto de linea.
    *   -------------------------------------------------------------------------
    *   Entrada r1: puntero al string que queremos imprimir
    *   Entrada r2: longitud de lo que queremos imprimir
    */
    imprimirLinea:
        .fnstart
            push {lr}               // Protegemos los registros

            bl imprimir             // Imprimimos las string a la que apunta r1

            push {r1, r2}           // Protegemos los parametros del procedimiento
            ldr r1, =saltoLinea     // r1 <- puntero a saltoLinea (el saldto de linea)
            mov r2, #1              // r2 <- 1, la longitud del salto de linea
            bl imprimir             // Imprimimos el salto del linea
            pop {r1, r2}            // Restauramos los parametros del procedimiento

            pop {lr}                // Restqauramos los registros
            bx lr                   // Salimos de la funcion
        .fnend

/------------------------------------------------------------------------------------
    /**
    *   Imprime una cadena de caracteres ASCIZ
    *   ---------------------------------------------------------------
    *   Entrada r1: puntero al string que queremos imprimir
    *   Entrada r2: longitud de lo que queremos imprimir
    */
    imprimirString:
        .fnstart
            push {lr}
            push {r1}
            push {r2} 
            bl clearScreen
            pop {r2}
            pop {r1}
            mov r7, #4      // Salida por pantalla  
            mov r0, #1      // Indicamos a SWI que sera una cadena           
            swi 0           // SWI, Software interrupt
            pop {lr}        // Restauramos los registros
            bx lr           //salimos de la funcion mifuncion
        .fnend

/------------------------------------------------------------------------------------
    /**
    *   Limpia la pantalla de la consola.
    */
    clearScreen:
        .fnstart
            mov r0, #1
            ldr r1, =cls
            ldr r2, =lencls
            mov r7, #4
            swi #0

            bx lr //salimos de la funcion clearScreen:
        .fnend

/------------------------------------------------------------------------------------
    /**
    *   Imprime el mapa por consola
    */
    imprimirMapa:
        .fnstart
            push {r1, r2, lr}   // Protegemos los registros
            ldr r1, =mapa       // r1 <- puntero =mapa
            ldr r2, =longitud   // r2 <- longitud de la cadena =mapa
            bl imprimirString   // Imprime el mapa con los parametros r1 y r2
            pop {r1, r2, lr}    // Restauramos los registros
            bx lr               // Salimos de la funcion
        .fnstart

/------------------------------------------------------------------------------------
    /**
    *   Devuelve si quedan vidas (1, true) o no (0, false)
    *   ---------------------------------------------------------------
    *   Salida r2: 1 por true, 0 por false.
    */
    quedanVidas:
        .fnstart
            push {r0, r1, r2, lr}
            ldr r1, =vidas  // r1 <- puntero de =vidas
            ldr r2, [r1]    // r2 <- vidas
            cmp r2, #0      // Comparo las vidas con 0
            beq noQuedanVidas
            bal siQuedanVidas

            // Retornamos 1 (true) en r2
            siQuedanVidas:
                mov r2, #1
                bal finQuedanVidas

            // Retornamos 0 (false) en r2
            noQuedanVidas:
                mov r2, #0
                bal finQuedanVidas

            finQuedanVidas:
                pop {r0, r1, r2, lr}
                bx lr
        .fnend

/------------------------------------------------------------------------------------
    /**
    *   Actualiza el string al que apunta =inputUsuario 
    *   con lo que el usuario haya ingresado por consola.
    */
    leerDatos:
        .fnstart
            push {r0, r1, r2, r7, lr}   // Protegemos los registros
            mov r7, #3                  // Función escanear input del usuario
            mov r0, #0                  // EL búfer
            mov r2, #40                 // Con cuánto me quedo del input
            ldr r1, =inputUsuario       // Donde se guarda el resultado
            swi 0                       // SWI, Software interrupt
            pop {r0, r1, r2, r7, lr}    // Restauramos los registros
            bx lr                       // Salimos de la funcion
            
            // Verificar si el sistema guarda un nul al final del input del usuario (max 40)
            // SI NO ES ASI -> reemplazar el primer espacio con un nul
        .fnend

/------------------------------------------------------------------------------------
    /**
    *   Calcula cual es la longitud de una cadena asicz
    *   --------------------------------------------
    *   Entrada r1: puntero a la cadena
    *   --------------------------------------------
    *   Salida r2: numero longitud de la cadena
    */
    longitudCadena:
        .fnstart
            push {r0, r1, r3, lr}  // Protegemos los registros
            
            mov r3, #0x0            // Caracter nulo
            mov r2, #0              // r2 <- contador en cero, donde se almacena el resultado del procedimiento
            bal cicloLongitudCadena    // Iniciamos el ciclo

            cicloLongitudCadena:
                ldrb r0, [r1]           // r0 <- caracter al que apunta r1
                cmp r3, r0              // r0 es el caracter nul?
                beq finLongitudCadena   // Sí -> fin
                add r2, #1              // Incremento contador
                add r1, #1              // Incremento puntero
                bal cicloLongitudCadena // Siguiente iteracion

            finLongitudCadena:
                pop {r0, r1, r3, lr}    // Restauramos los registros
                bx lr                   // Salimos de la funcion
        .fnend


/------------------------------------------------------------------------------------
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

/------------------------------------------------------------------------------------
    /**
    *   Calcula si dos cadenas tienen los mismos caracteres de principio a fin.
    *   ---------------------------------------------------
    *   Entrada r0: puntero cadena1
    *   Entrada r1: puntero cadena2
    *   ---------------------------------------------------
    *   Salida r2: 1 (true) o 0 (false) si son iguales o no
    */
    cadenasSonIguales:
        .fnstart
            push {r0, r1, r3, r4, r5, r6, lr}
            
            mov r3, #0          // r3 <-- 0 Inicializamos el contador

            bl longitudCadena   // r2 <-- longitud cadena (Entrada r1: puntero cadena, Salida r2: su longitud)
            mov r6, r2          // r6 <-- r2 (porque ahi esta el longitud de la cadena)

            whileContMenorLongitud:
                cmp r3, r6                  // Comparamos el contador con el longitud
                beq lasCadenasSonIguales    // Si contador (r3) == longitud (r6) -> no se interrumpio el ciclo -> las cadenas son iguales

                // Agarrar el valor actual de cadena1
                ldr r4, [r0, r3]    // r4 es el caracater de cadena1 en el indice r3
                ldr r5, [r1, r3]    // r5 es el caracater de cadena2 en el indice r3

                cmp r4, r5                  // Comparamos r4 (cadena1[r3]) con r5 (cadena2[r3])
                bne lasCadenasNoSonIguales  // Si r4 != r5 -> devolver false

                add r3, #1              // r3 <-- r3++ (incrementar el contador)
                bal whileContMenorLargo // Siguiente iteracion

            lasCadenasNoSonIguales:
                mov r2, #0                  // r2 <- 0 (false)
                bal finCadenasSonIguales    // Para terminar el procedimiento

            lasCadenasSonIguales:
                mov r2, #1                  // r2 <- 1 (true)
                bal finCadenasSonIguales    // Para terminar el procedimiento

            finCadenasSonIguales:
                pop {r0, r1, r3, r4, r5, r6, lr}    // Restauramos los registros
                bx lr                               // Salimos de la función
            
        .fnend


/------------------------------------------------------------------------------------
    /**
    *   Disminuye la cantidad de vidas indicadas.
    *   -----------------------------------------
    *   Entrada r1: cantidad de vidas a restar
    */
    quitarVidas:
        @todo: vidas--
        @todo - BRIAN

/------------------------------------------------------------------------------------
    /**
    *   Actualiza la parte del mapa que muestra las 
    *   letras reveladas de la palabra secreta.
    */
    revelarPalabraSecreta:
        @todo - JUAN

/------------------------------------------------------------------------------------
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
                // Poner un 1 en =ganado
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

/------------------------------------------------------------------------------------
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

/------------------------------------------------------------------------------------
    /**
    *   Determina si la letra elegida pertenece a la 
    *   palabra oculta y, si es así, actualiza el mapa.
    */
    procesarDatos:
        .fnstart
            push {r1, r2, lr}
            
            ldr r1, =inputUsuario   // r1 <- puntero del input del usuario
            bl longitudCadena       // r2 <- longitud =inputUsuario
            mov r4, #1              // r4 <- 1
            cmp r2, r4              // Comparamos r2 (longitud) con r4 (1)
            blt jugar               // Si el input es menor a 1 (cadena vacia), vamos a la siguiente iteracion (para el usuario no paso nada)
            bgt arriesgarPalabra    // Si es mayor que 1, intento arriesgar palabra
            bal arriesgarLetra      // Si es 1, intento arriesgar una letra

            finProcesarDatos:
                pop {r1, r2, lr}
                bx lr
        .fnend

/------------------------------------------------------------------------------------
    /**
    *   Prepara el mapa para la palabra elegida.
    */
    prepararMapa:
        nop

/------------------------------------------------------------------------------------
    /**
    *   Elige una palabra del lemario.
    */
    elegirPalabra:
        nop

/------------------------------------------------------------------------------------
    /**
    *   Imprime en pantalla el estado del juego, 
    *   registra el input del usuario y altera 
    *   los estados del juego segun esto.
    */
    jugar:
        .fnstart
            push {r1, lr}           // Protegemos los registros

            bl quedanVidas              // Ejecutamos quedanVidas, retorna en r2: 1 (true) o 0 (false )
            cmp r2, #0                  // Si es 0 (false)
            beq preguntaAproximativa    // Le damos al usuario la pregunta aproximativa

            bl imprimirMapa     // Imprimimos el mapa por consola
            bl leerDatos        // Registramos el input del usuario
            bl procesarDatos    // Procesamos los datos del usuario

            /* TOMAR EL INPUT DEL USUARIO */
            bl leerDatos            // El SO guarda a partir de =inputUsuario (dir mem) el input
            ldr r1, =inputUsuario   // r1 <-- colocamos esa direccion
            bl largoCadena          // r0 <-- largo cadena de [=inputUsuario]
            cmp r0, #1              // Comparamos r0 (largo) con #1
            blt finJugar            // Si el input es "" (cadena vacia), vamos a la siguiente iteracion (para el usuario no paso nada)
            bgt arriesgarPalabra    // Si es mayor que 1, intento arriesgar palabra
            bal arriesgarLetra      // 
            finJugar:
                pop {r1, lr}            // Restauramos los registros
                bx lr                   // Volvemos a donde sea que nos llamaron
        .fnend

/------------------------------------------------------------------------------------
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

/------------------------------------------------------------------------------------
    .global main        @ global, visible en todo el programa
    main:
        bl cicloWhile
        /*
        //imprimo el mapa para empezar
        ldr r2, =longitud //Tamaño de la cadena
        ldr r1, =mapa   //Cargamos en r1 la direccion del mensaje
        bl imprimirString
        */

/------------------------------------------------------------------------------------
    fin:
        mov r7, #1    // Salida al sistema
        swi 0
