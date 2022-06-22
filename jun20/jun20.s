/*** INICIO DEFINICION DE DATOS DEL PROGRAMA ***/
.data

    run: .byte 1    // bool para controlar la ejecucion del programa

    mapa: .asciz "___________________________________________________|\n                                                   |\n     *** EL JUEGO DEL AHORCADO - ORGA 1 ***        |\n___________________________________________________|\n                                                   |\n                                                   |\n          +------------+                           |\n          |            |                           |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n +-------------------------------------------+     |\n |                                           |     |\n |                                           |     |\n |                                           |     |\n +-------------------------------------------+     |\n"
    lenMapa = . - mapa

    enter: .ascii "\n"
    
    cls: .asciz "\x1b[H\x1b[2J" //una manera de borrar la pantalla usando ansi escape codes
    lencls = .-cls
    
    inputUsuario: .asciz "                  "   // Espacio reservado para lo que ingrese el usuario por consola
    lenInputUsuario = . - inputUsuario

    palabraOculta: .asciz "            "    // Donde ira la palabra oculta una vez elegida
    palabraActual: .asciz "            "    // Se reemplazaran ' ' por '_' por cada letra de la palabraOculta una vez elegida
    letrasUsadas: .asciz "                          "   // Donde iran las letras usadas por el usuario
    
    vidas: .byte 7  // Vidas iniciales
    
    /* INI Mensajes al usuario */
    letrasRestantes: .asciz "Quedan letras por adivinar!"
    lenLetrasRestantes = . - letrasRestantes
    
    juegoPerdido: .asciz "Que lastima, perdiste! :("
    lenJuegoPerdido = . - juegoPerdido
    
    juegoGanado: .asciz "Felicitaciones, ganaste!"
    lenJuegoGanado = . - juegoGanado

    porFavorNoRepitasLetras: .asciz "Esa letra ya fue usada"
    lenPorFavorNoRepitasLetras = . - porFavorNoRepitasLetras

    solicitudNumero: .asciz "Por favor, ingresá un número entre 1 y 20: "
    lenSolicitudNumero = . - solicitudNumero
  
    solicitudLetra: .asciz "Por favor, ingresá una letra minúscula o arriesgá la palabra: "
    lenSolicitudLetra = . - solicitudLetra
    /* FIN Mensajes al usuario */
    
    cadenaVidas: .asciz "vidas: 7"
    lenCadenaVidas = . - cadenaVidas
    
    ganado: .byte 0
    
    indicePrimeraLetraUsadaEnMapa: .byte 213    // El primer espacio disponible en el mapa para escribir una letra usada
    
    indicePalabraActual: .word 882  // Indice donde empezar a escribir la palabra actual acertada por el usuario -> "e _ e _ _ n _ e"
    
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
           



/*** FIN DEFINICION DE DATOS DEL PROGRAMA ***/

/*** INICIO DEFINICION DEL CODIGO DEL PROGRAMA ***/
.text

    /**
    *   Imprime una cadena de caracteres ASCIZ 
    *   utilizando interrupciones.
    *   ------------------------------------------
    *   Entrada r1: puntero a la cadena a imprimir
    *   Entrada r2: longitud de la cadena
    */
    imprimir:
        .fnstart
            push {r0, r7}   // Protegemos los registros

            mov r7, #4      // La función de SWI que necesitamos para imprimir
            mov r0, #1      // Indicamos a SWI que sera una cadena
            swi 0           // SWI, Software interrupt

            pop {r0, r7}    // Restauramos los registros
            bx lr           // Salimos de la funcion
        .fnend
    
    /**
    *   Imprime una cadena de caracteres ASCIZ utilizando
    *   interrupciones y luego imprime un salto de linea.
    *   ---------------------------------------------------
    *   Entrada r1: puntero a la cadena a imprimir
    *   Entrada r2: longitud de la cadena
    */
    imprimirLinea:
        .fnstart
            push {r1, r2, lr}
            bl imprimir         // Imprimimos la cadena a la que apunta r1

            ldr r1, =enter      // r1 <- puntero a enter: '\n'
            mov r2, #1          // r2 <- 1 es lo que mide '\n'
            bl imprimir         // Imprimimos el salto del linea

            pop {r1, r2, lr}
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
    *   Imprime una cadena de caracteres ASCIZ 
    *   despues de borrar el contenido de la pantalla.
    *   ----------------------------------------------
    *   Entrada r1: puntero a la cadena a imprimir
    *   Entrada r2: longitud de la cadena
    */
    borrarEImprimir:
        .fnstart
            push {lr}

            // Protegemos y restauramos registros mientras hacemos el clearScreen
            push {r1, r2}
            bl clearScreen
            pop {r1, r2}

            bl imprimir
            pop {lr}
            bx lr
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
    *   Convierte un numero en ascii a su equivalente en decimal.
    *   ---------------------------------------------------------
    *   Entrada r0: puntero a la cadena.
    *   ---------------------------------------------------------
    *   Salida r1: el numero en decimal.
    */
    asciiADecim:
        .fnstart
            push {r0, r2, r3, r4}

            ldrb r1, [r0]       // r1 <- inputUsuario[0]: primerCaracter
            sub r1, r1, #0x30   // inputUsuario[0] - 0x30
            mov r2, #1          // r2 <- indice i: empieza en 1
            mov r10, #10
            
            cicloAsciiADecim:
                ldrb r3, [r0, r2]      // r3 <- inputUsuario[r2]

                cmp r3, #00
                beq finAsciiADecim      // Si inputUsuario[r2] == nul -> terminamos
                cmp r3, #' '
                beq finAsciiADecim      // Si inputUsuario[r2] == ' ' -> terminamos
                cmp r3, #'\n'
                beq finAsciiADecim      // Si inputUsuario[r2] == '\n' -> terminamos

                sub r3, r3, #0x30      // r3 <- el equivalente al caracter en numero

                mul r4, r1, r10        // r4 = r1 x 10

                add r4, r3             // r4 += r3
                mov r1, r4             // r1 <- el resultado que esta en r4

                add r2, #1             // i++
                bal cicloAsciiADecim   // Siguiente iteracion
            
            finAsciiADecim:
                pop {r0, r2, r3, r4}
                bx lr
        .fnend
    
    /**
    *   Carga la palabra del lemario, en la posicion que se corresponde
    *   con el numero que ingreso el usuario, en =palabraOculta y coloca 
    *   un '_' por cada caracter de palabraOculta en palabraActual.
    *   ----------------------------------------------------------------
    *   Entrada r1: el numero elegido por el usuario.
    */
    cargarPalabra:
        .fnstart
            push {r0, r1, r2, r3, r4, r5, r6, lr}
            ldr r0, =inputUsuario
            ldr r2, =lemario

            mov r3, #0  // r3 <- i: contador de caracteres para ciclar el lemario
            mov r4, #1  // r4 <- j: contador de palabras, inicia en 1

            // Si la palabra elegida es la primera, directamente cargamos las letras
            cmp r1, #1
            beq cicloCargarLetras
            // Sino, vamos al ciclo

            // Buscamos la palabra dentro del lemario.
            cicloBuscarPalabra:
                cmp r4, r1
                beq cicloCargarLetras    // Si i == numeroElegido -> cargamos las letras

                ldrb r5, [r2, r3]    // r5 <- inputUsuario[i]

                cmp r5, #','
                bne incrementarI    // Si inputUsuario[i] != ',' -> solo incrementamos i

            // Si inputUsuario[i] == ',' -> incrementamos j
            // porque termino una palabra, y el siguiente 
            // caracter pertenece a otra palabra
            incrementarJ:
                add r4, #1  // j++

            incrementarI:
                add r3, #1  // i++
                bal cicloBuscarPalabra

            cicloCargarLetras:
                ldr r0, =palabraOculta
                ldr r1, =palabraActual
                mov r4, #0                // r7 <- j: contador para ciclar las posiciones de palabraOculta y palabraActual
                mov r5, #'_'

                subCicloCargarLetras:
                    add r3, #1                  // i++
                    ldrb r6, [r2, r3]           // r6 <- lemario[i]

                    cmp r6, #','
                    beq finCargarPalabra        // si lemario[i] == ',' -> la palabra termino, podemos salir

                    strb r6, [r0, r4]           // palabraOculta[j] = inputUsuario[i]
                    strb r5, [r1, r4]           // palabraActual[j] = '_'

                    add r4, #1                  // j++
                    bal subCicloCargarLetras    // Siguiente iteracion

            finCargarPalabra:
                pop {r0, r1, r2, r3, r4, r5, r6, lr}
                bx lr
        .fnend
    
    /**
    *   Solicita al usuario que ingrese un numero en el 
    *   rango [1, 20], y reintenta si lo ingresado esta fuera.
    */
    elegirPalabra:
        .fnstart
            push {r0, r1, r2, lr}  // Protegemos registros.

            cicloSeleccionarPalabra:
                // Le pedimos al usuario que ingrese un numero
                ldr r1, =solicitudNumero    // Entrada1 borrarEImprimir
                ldr r2, =lenSolicitudNumero // Entrada2 borrarEImprimir
                bl borrarEImprimir          // Imprime el mensaje en consola

                bl leerDatos      // Registramos el input del usuario (actualiza =inputUsuario)

                ldr r0, =inputUsuario
                bl asciiADecim          // r1 <- num <- asciiADecim("num")

                cmp r1, #1 
                blt cicloSeleccionarPalabra   // Si num < 1 -> volvemos a intentar

                cmp r1, #20 
                bgt cicloSeleccionarPalabra   // Si num > 20 -> volvemos a intentar

                // Si esta dentro del rango [1, 20] podemos salir
                pop {r0, r1, r2, lr}
                bx lr
        .fnend
    
.global main
main:

    bl elegirPalabra
    bl cargarPalabra                  // Cargamos la palabra en =palabraOculta
    bl actualizarPalabraActualEnMapa  // Actualizamos los "_____" en el mapa.

    cicloWhile:
        bl jugar

        ldr r0, =run
        ldr r1, [r0]    // r1 <- run (true/false)

        cmp r1, #1
        beq cicloWhile  // Si run == True -> entrar al while otra vez

fin:
    mov r7, #1
    swi 0
