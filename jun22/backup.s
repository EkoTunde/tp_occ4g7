/* DEFINICION DE DATOS DEL PROGRAMA */
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

    letrasRestantes: .asciz "Quedan letras por adivinar!"
    lenLetrasRestantes = . - letrasRestantes

    msjJuegoPerdido: .asciz "Que lastima, perdiste! :("
    lenMsjJuegoPerdido = . - msjJuegoPerdido
    
    msjJuegoGanado: .asciz "Felicitaciones, ganaste!"
    lenMsjJuegoGanado = . - msjJuegoGanado

    msjPorFavorNoRepitasLetras: .asciz "Esa letra ya fue usada"
    lenMsjPorFavorNoRepitasLetras = . - msjPorFavorNoRepitasLetras

    solicitudNumero: .asciz "Por favor, ingresa un numero entre 1 y 20: "
    lenSolicitudNumero = . - solicitudNumero

    solicitudLetra: .asciz "Por favor, ingresa una letra minuscula o arriesga la palabra: "
    lenSolicitudLetra = . - solicitudLetra

    cadenaVidas: .asciz "vidas: 7"
    lenCadenaVidas = . - cadenaVidas

    ganado: .byte 0

    repitioLetra: .byte 0

    indicePrimeraLetraUsadaEnMapa: .word 213    // El primer espacio disponible en el mapa para escribir una letra usada

    indicePalabraActual: .word 882  // Indice donde empezar a escribir la palabra actual acertada por el usuario -> "e _ e _ _ n _ e"

    numeroPalabraElegida: .word 0

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

/* DEFINICION DEL CODIGO DEL PROGRAMA */
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

            mov r7, #4      // La funcion de swi que necesitamos para imprimir
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
            push {r1, r2, lr}
            ldr r1, =cls
            ldr r2, =lencls
            bl imprimir
            pop {r1, r2, lr}
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
    *   Imprime el mapa por consola con todos los datos actualizados.
    */
    imprimirMapa:
        .fnstart
            push {r1, r2, lr}
            ldr r1, =mapa
            ldr r2, =lenMapa
            bl borrarEImprimir  // Recibe en r1 puntero de cadena y en r2 la longitud de la misma
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

            mov r1, #0      // i: contador para ciclar

            cicloQuedanLetrasPorAdivinar:
                ldrb r3, [r0, r1]    // r3 <- palabraActual[i]

                cmp r3, #00
                beq noQuedanLetrasPorAdivinar // Si palabraActual[i] == nul terminamos de iterar la cadena

                cmp r3, #0x20
                beq noQuedanLetrasPorAdivinar   // Si palabraActual[i] ==  ' ' tambien terminamos de iterar la cadena

                cmp r3, #'_'
                beq siQuedanLetrasPorAdivinar   // Si palabraActual[i] ==  '_' tambien terminamos de iterar la cadena

                add r1, #1  // i++
                bal cicloQuedanLetrasPorAdivinar

            siQuedanLetrasPorAdivinar:
                mov r2, #1  // r2 <- 1 para retornar true
                bal finQuedanLetrasPorAdivinar

            noQuedanLetrasPorAdivinar:
                mov r2, #0  // r2 <- 0 para retornar false          

            finQuedanLetrasPorAdivinar:
                pop {r0, r1, r3, lr}
                bx lr
        .fnend
    
    /**
    *   Agrega al mapa la letra que ingreso el usuario en la siguiente 
    *   posicion disponible para la lista en pantalla de letras usadas.
    */
    agregarLetraUsadaAlMapa:
        .fnstart
            push {r0, r1, r2, r3, r4}

            ldr r0, =inputUsuario
            ldr r1, =indicePrimeraLetraUsadaEnMapa
            ldr r2, =mapa

            ldrb r3, [r0]       // r3 <- la letra que ingreso el usuario
            ldr r4, [r1]       // r4 <- indice: lugar disponible en mapa para agregar la letra (indicePrimeraLetraUsadaEnMapa)

            strb r3, [r2, r4]   // mapa[indice] = letra

            add r4, #2          // indice += 2
            str r4, [r1]        // indicePrimeraLetraUsadaEnMapa = indice

            pop {r0, r1, r2, r3, r4}
            bx lr
        .fnend
    
    /**
    *   Intenta agregar la letra que ingreso el usuario a la lista de letras usadas.
    *   ----------------------------------------------------------------------------
    *   Salida r0: 1 (true) si se agrego a la lista, 0 (false) en caso contrario.
    */
    guardarLetraUsada:
        .fnstart
            push {r1, r3, r4, lr}

            ldr r0, =inputUsuario
            ldr r1, =letrasUsadas

            ldrb r2, [r0]          // r2 <- letra: la letra que ingreso el usuario

            mov r3, #0              // r3 <- i: indice/contador para ciclar

            cicloGuardarLetraUsada:
                ldrb r4, [r1, r3]    // r4 <- letrasUsadas[i]

                cmp r4, r2
                beq noAgregarLetraALista // Si letrasUsadas[i] == letra -> ya esta en la 'lista', podemos salir

                cmp r4, #' '
                beq agregarLetraALista  // Si letrasUsadas[i] == ' ' -> hay espacio disponible para agregar

                add r3, #1                  // i++
                bal cicloGuardarLetraUsada  // siguiente iteracion

            noAgregarLetraALista:
                // Encender flag repitioLetra
                ldr r0, =repitioLetra
                mov r1, #1
                strb r1, [r0]

                mov r0, #0  // r0 <- para retornar false
                bal finGuardarLetraUsada

            agregarLetraALista:
                bl agregarLetraUsadaAlMapa
                strb r2, [r1, r3]   // r2 (letra del usuario) -> letrasUsadas[r3]
                mov r0, #1          // r0 <- para retornar true

            finGuardarLetraUsada:
                pop {r1, r3, r4, lr}
                bx lr
        .fnend
    
    /**
    *   Imprime por consola el mensaje que indica
    *   que quedan letras restantes por adivinar.
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
    *   Reemplaza el caracter de la matriz en los indices indicados, por el caracter indicado.
    *   offset = puntero + (fila x cant_columnas x tamanio_bytes) + (columna x tamanio_bytes)
    *   --------------------------------------------------------------------------------------
    *   Entrada r0: puntero de la matriz
    *   Entrada r1: ascii de reemplazo (byte)
    *   Entrada r2: numero de fila
    *   Entrada r3: numero de columna
    *   Entrada r4: numero cantidad de columnas
    */
    reemplazarLetraEnMatriz:
        .fnstart
            push {r0, r1, r2, r3, r4, r5}

            mul r5, r2, r4      // r5 <-- r2 x r4 : fila * cantidad columnas
            add r5, r3          // r5 <-- r5 + r3 : r5 + numero de columna
            strb r1, [r0, r5]   // matriz[fila][columna] = ascii de reemplazo

            pop {r0, r1, r2, r3, r4, r5}
            bx lr
        .fnend
    
    /**
    *   Actualiza el mapa para representar el estado actual de la palabra actual,
    *   es decir, las letras descubiertas y las ocultas representadas por '_'.
    */
    actualizarPalabraActualEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, r5, r6, lr}

            ldr r0, =mapa
            mov r2, #17     // numero de fila
            mov r3, #8      // r3 <- numeroColumna: contador para ir incrementando los indices del mapa, inicia en 8.
            mov r4, #53     // numero cantidad de columnas

            ldr r5, =palabraActual
            mov r6, #0      // r6 <- i (indice): contador para ciclar palabraActual

            cicloActualizarPalabraActualEnMapa:
                ldrb r1, [r5, r6]   // r1 <- palabraActual[i]

                cmp r1, #00
                beq finActualizarPalabraActualEnMapa    // palabraActual[i] == nul -> no quedan caracteres para actualizar

                bl reemplazarLetraEnMatriz

                add r3, #2      // numeroColumna += 2 (Incremento de a 2 para dejar un espacio entre las letras/guiones)
                add r6, #1      // i++
                bal cicloActualizarPalabraActualEnMapa // siguiente iteracion

            finActualizarPalabraActualEnMapa:
                pop {r0, r1, r2, r3, r4, r5, r6, lr}
                bx lr
        .fnend

    /**
    *   Copia el contenido de la primera cadena en la segunda.
    *   Precaucion: ambas cadenas deben tener el mismo espacio reservado 
    *   en memoria para evitar pisar espacios por fuera de la cadena2.
    *   ----------------------------------------------------------------
    *   Entrada r0: puntero a cadena1, que tiene el contenido a copiar
    *   Entrada r1: punteor a cadena2, que recibira el nuevo contenido
    */
    copiarCadenas:
        .fnstart
            push {r0, r1, r2, r3}

            mov r2, #0  // r2 <- i (indice): contador para ciclar

            cicloCopiarCadenas:
                ldrb r3, [r0, r2]       // cadena1[i]

                cmp r3, #00
                beq finCopiarCadenas    // Si cadena1[i] == nul -> no quedan caracteres por copiar

                strb r3, [r1, r2]       // cadena2[i] = cadena1[i]

                add r2, #1              // i++
                bal cicloCopiarCadenas  // siguiente iteracion

            finCopiarCadenas:
                pop {r0, r1, r2, r3}
                bx lr
        .fnend

    /**
    *   Copia el contenido de palabraOculta en palabraActual.
    */
    revelarPalabraOculta:
        .fnstart
            push {r0, r1, lr}

            ldr r0, =palabraOculta  // Entrada r0: palabra a copiar
            ldr r1, =palabraActual  // Entrada r1: palabra que recibe contenido
            bl copiarCadenas

            pop {r0, r1, lr}
            bx lr
        .fnend

    /**
    *   Imprime por consola el mensaje que
    *   indica que el usuario gano el juego.
    */
    imprimirMsjJuegoGanado:
        .fnstart
            bl revelarPalabraOculta
            bl actualizarPalabraActualEnMapa
            bl imprimirMapa
            ldr r1, =msjJuegoGanado
            ldr r2, =lenMsjJuegoGanado
            bl imprimirLinea
            bal fin
        .fnend
    
    /**
    *   Reemplaza los '_' por '@' de la palabraActual para
    *   representar los caracteres que el usuario no pudo adivinar.
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
                beq finEncriptarLetrasNoEncontradas // Si palabraActual[i] == nul -> terminamos de ciclar la palabraActual
                
                cmp r2, #'_'
                bne sigCicloEncriptarNoEncontradas  // Si palabraActual[i] != '_' -> siguiente iteracion

                strb r9, [r0, r1]                    // palabraActual[i] = '@'

            sigCicloEncriptarNoEncontradas:
                add r1, #1                              // i++
                bal cicloEncriptarLetrasNoEncontradas   // siguiente iteracion
            
            finEncriptarLetrasNoEncontradas:
                pop {r0, r1, r2, r9, lr}
                bx lr
        .fnend
    
    /**
    *   Imprime por consola el mensaje que
    *   indica que el usuario perdio el juego.
    */
    imprimirMsjJuegoPerdido:
        .fnstart
            push {r1, r2, lr}
            bl encriptarLetrasNoEncontradas
            bl actualizarPalabraActualEnMapa
            bl imprimirMapa
            ldr r1, =msjJuegoPerdido
            ldr r2, =lenMsjJuegoPerdido
            bl imprimirLinea
            pop {r1, r2, lr}
            bx lr
        .fnend

    /**
    *  Convierte un numero decimal a su equivalente en ASCII
    *  -----------------------------------------------------
    *  Entrada r0: un numero decimal
    *  -----------------------------------------------------
    *  Salida r1: el numero en ASCII
    */
    unidadDecimalToAscii:
        .fnstart
            push {r0, lr}
            add r1, r0, #0x30
            pop {r0, lr}
            bx lr
        .fnend
    
    /**
    *   Actualiza el mensaje que indica la cantidad de
    *   vidas restantes con el valor actual de la misma.
    */
    actualizarMsjVidas:
        .fnstart
            push {r0, r1, r2, r3, lr}      

            ldr r0, =vidas
            ldrb r0, [r0]           // r0 <- vidas
            bl unidadDecimalToAscii // r1 <- asciiDelNum <- unidadDecimalToAscii(r0: num decimal), 0 <= num <= 9

            ldr r2, =cadenaVidas
            mov r3, #7              // r3 <- i: 7 es la parte de cadenaVidas donde esta el numero de vidas restantes
            strb r1, [r2, r3]       // cadenaVidas[7] = asciiDelNum
            
            pop {r0, r1, r2, r3, lr}
            bx lr
        .fnend
    
    /**
    *   Reemplaza en la matriz del mapa el caracter indicado si las vidas 
    *   restantes son menos que las necesarias para dibujar un espacio.
    *   -----------------------------------------------------------------------
    *   Entrada r0: vidas restantes
    *   Entrada r1: vidas necesarias para dibujar un espacio
    *   Entrada r2: caracter ASCII que representa la parte del cuerpo a dibujar
    *   Entrada r3: numero de fila
    *   Entrada r4: numero de columna
    */
    actualizarParteEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, lr}

            cmp r0, r1
            bne usarCaracterEnParte // Si vidasRestantes != vidasNecesarias -> dibujamos el caracter ASCII

            mov r1, #' '
            bal finActualizarParteEnMapa

            usarCaracterEnParte:
                mov r1, r2      // r1: ascii de reemplazo (.byte)

            finActualizarParteEnMapa:
                ldr r0, =mapa   // r0: puntero de la matriz
                mov r2, r3      // r2: numero de fila
                mov r3, r4      // r3: numero de columna
                mov r4, #53     // r4: numero cantidad de columnas
                bl reemplazarLetraEnMatriz  // reemplazarLetraEnMatriz(r0, r1, r2, r3, r4)
                pop {r0, r1, r2, r3, r4, lr}
                bx lr
       .fnend

    /**
    *   Actualiza en el mapa el caracter correspondiente 
    *   en el lugar de la cabeza: si vidas >= 7, dibujar 'o'.
    *   -----------------------------------------------------
    *   Entrada r0: numero de vidas restantes
    */
    actualizarCabezaEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, lr}
            mov r1, #7      // r1 <- vidas necesarias para dibujar ' '
            mov r2, #'o'    // r2 <- cabeza
            mov r3, #8      // r3 <- numero de fila
            mov r3, #23     // r4 <- numero de columna
            bl actualizarParteEnMapa
            pop {r0, r1, r2, r3, r4, lr}
            bx lr
       .fnend      

    /**
    *   Actualiza en el mapa el caracter correspondiente 
    *   en el lugar del pecho: si vidas >= 6, dibujar '|'.
    *   -----------------------------------------------------
    *   Entrada r0: numero de vidas restantes
    */
    actualizarPechoEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, lr}
            mov r1, #6      // r1 <- vidas necesarias para dibujar ' '
            mov r2, #'|'    // r2 <- pecho
            mov r3, #9      // r3 <- numero de fila
            mov r3, #23     // r4 <- numero de columna
            bl actualizarParteEnMapa
            pop {r0, r1, r2, r3, r4, lr}
            bx lr
       .fnend
    
    /**
    *   Actualiza en el mapa el caracter correspondiente 
    *   en el lugar del abdomen: si vidas >= 3, dibujar '|'.
    *   -----------------------------------------------------
    *   Entrada r0: numero de vidas restantes
    */
    actualizarAbdomenEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, lr}
            mov r1, #5      // r1 <- vidas necesarias para dibujar ' '
            mov r2, #'|'    // r2 <- abdomen
            mov r3, #10     // r3 <- numero de fila
            mov r3, #23     // r4 <- numero de columna
            bl actualizarParteEnMapa
            pop {r0, r1, r2, r3, r4, lr}
            bx lr
       .fnend   

    /**
    *   Actualiza en el mapa el caracter correspondiente 
    *   en el lugar de la pierna izquierda: si vidas >= 2, dibujar '/'.
    *   -----------------------------------------------------
    *   Entrada r0: numero de vidas
    */
    actualizarPiernaIzqEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, lr}
            mov r1, #4      // r1 <- vidas necesarias para dibujar ' '
            mov r2, #'/'    // r2 <- pierna izquierda
            mov r3, #11     // r3 <- numero de fila
            mov r3, #22     // r4 <- numero de columna
            bl actualizarParteEnMapa
            pop {r0, r1, r2, r3, r4, lr}
            bx lr
       .fnend

    /**
    *   Actualiza en el mapa el caracter correspondiente 
    *   en el lugar de la pierna derecha: si vidas >= 1, dibujar '\\'.
    *   -----------------------------------------------------
    *   Entrada r0: numero de vidas
    */
    actualizarPiernaDerEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, lr}
            mov r1, #3      // r1 <- vidas necesarias para dibujar ' '
            mov r2, #'\\'   // r2 <- pierna derecha
            mov r3, #11     // r3 <- numero de fila
            mov r3, #24     // r4 <- numero de columna
            bl actualizarParteEnMapa
            pop {r0, r1, r2, r3, r4, lr}
            bx lr
       .fnend
    
    /**
    *   Actualiza en el mapa el caracter correspondiente 
    *   en el lugar del brazo izquierdo: si vidas >= 5, dibujar '/'.
    *   -----------------------------------------------------
    *   Entrada r0: numero de vidas restantes
    */
    actualizarBrazoIzqEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, lr}
            mov r1, #2      // r1 <- vidas necesarias para dibujar ' '
            mov r2, #'/'    // r2 <- brazo izquierdo
            mov r3, #9      // r3 <- numero de fila
            mov r3, #22     // r4 <- numero de columna
            bl actualizarParteEnMapa
            pop {r0, r1, r2, r3, r4, lr}
            bx lr
       .fnend
    /**/
    
    /**
    *   Actualiza en el mapa el caracter correspondiente 
    *   en el lugar del brazo derecho: si vidas >= 4, dibujar '\\'.
    *   -----------------------------------------------------
    *   Entrada r0: numero de vidas restantes
    */
    actualizarBrazoDerEnMapa:
        .fnstart
            push {r0, r1, r2, r3, r4, lr}
            mov r1, #1      // r1 <- vidas necesarias para dibujar ' '
            mov r2, #'\\'   // r2 <- brazo derecho
            mov r3, #9      // r3 <- numero de fila
            mov r3, #24     // r4 <- numero de columna
            bl actualizarParteEnMapa
            pop {r0, r1, r2, r3, r4, lr}
            bx lr
        .fnend   
    /**/
    
    /**
    *   Actualiza la persona en el mapa, dibujando las partes
    *   correspondientes segun el numero de vidas restantes.
    */
    actualizarPersonaEnMapa:
        .fnstart
            push {r0, r1, lr}

            ldr r1, =vidas
            ldrb r0, [r1]   // r0 <- vidas restantes

            /* Todas estas subrutinas reciben las vidas en r0 */
            bl actualizarCabezaEnMapa
            bl actualizarPechoEnMapa
            bl actualizarAbdomenEnMapa
            bl actualizarPiernaIzqEnMapa
            bl actualizarPiernaDerEnMapa
            bl actualizarBrazoIzqEnMapa
            bl actualizarBrazoDerEnMapa

            pop {r0, r1, lr}
            bx lr
        .fnend

    /**
    *   Imprime el estado del juego por consola.
    */
    informarEstado:
        .fnstart
            push {r0, r1, r2, lr}

            bl quedanLetrasPorAdivinar  // r2 <- si quedan letras o no (true o false)
            cmp r2, #0
            beq juegoGanado             // Si r2 == false -> no quedan letras por adivinar -> usuario gano

            ldr r0, =vidas
            ldrb r1, [r0]       // r1 <- vidas restantes
            cmp r1, #0
            ble juegoPerdido    // Si vidasRestantes <= 0 -> sin vidas -> usuario perdio

            bl actualizarMsjVidas   // Actualiza la cadena que luego se imprime para mostrar las vidas
            ldr r1, =cadenaVidas
            ldr r2, =lenCadenaVidas
            bl imprimirLinea        // Imprimir las vidas restantes

            ldr r0, =repitioLetra
            ldrb r1, [r0]           // r1 <- repitioLetra (true/false)
            cmp r1, #0
            beq finInformarEstado       // Si !repitioLetra -> podemos salir
            bal informarRepitioLetra    // Si repitioLetra -> informar que se repitio y despues salir

            juegoGanado:
                // Seteamos run = False para que el juego no se ejecute nuevamente.
                ldr r0, =run
                mov r1, #0      // r1 <- False
                strb r1, [r0]   // run = False
                bl imprimirMsjJuegoGanado
                bal finInformarEstado

            juegoPerdido:
                // Seteamos run = False para que el juego no se ejecute nuevamente.
                ldr r0, =run
                mov r1, #0      // r1 <- False
                strb r1, [r0]   // run = False
                bl imprimirMsjJuegoPerdido
                bal finInformarEstado

            informarRepitioLetra:
                ldr r1, =msjPorFavorNoRepitasLetras
                ldr r2, =lenMsjPorFavorNoRepitasLetras
                bl imprimirLinea

                // Apagamos el flag de repitioLetra
                ldr r0, =repitioLetra
                mov r1, #0
                strb r1, [r0]

            finInformarEstado:
                pop {r0, r1, r2, lr}
                bx lr

            // bl quedanLetrasPorAdivinar  // r2 <- si quedan letras o no (true o false)
            // cmp r2, #1                  // Quedan letras?
            // beq printLetrasRestantes    // Si -> imprimir letras restantes
            // bne printJuegoGanado        // No -> se gano el juego

            // ldr r1, =vidas
            // ldrb r1, [r1]   // r1 <- numero vidas restantes
            // cmp r1, #0
            // beq printJuegoPerdido

            // printLetrasRestantes:
            //     bl imprimirMsjLetrasRestantes
            //     bal finInformarEstado

            // printJuegoGanado:
            //     bl imprimirMsjJuegoGanado
            //     bal finInformarEstado

            // printJuegoPerdido:
            //     bl imprimirMsjJuegoPerdido
            //     bal finInformarEstado
            
            // finInformarEstado:
            //     bl actualizarMsjVidas
            //     ldr r1, =cadenaVidas
            //     ldr r2, =lenCadenaVidas
            //     bl imprimirLinea // Recibe r1: puntero cadena, r2: longitud
            //     pop {r0, r1, r2, lr}
            //     bx lr
      .fnend
    
    /**
    *   Actualiza el string al que apunta =inputUsuario 
    *   con lo que el usuario haya ingresado por consola.
    */
    leerDatos:
        .fnstart
            push {r0, r1, r2, r7, lr}
            mov r7, #3                  // Funcion escanear input del usuario
            mov r0, #0                  // El bufer
            ldr r2, =lenInputUsuario    // Longitud de la cadena del input
            ldr r1, =inputUsuario       // Donde se guarda el resultado
            swi 0
            pop {r0, r1, r2, r7, lr}
            bx lr
        .fnend
    
    /**
    *   True/false si la letra especificada esta presente en la cadena.
    *   ---------------------------------------------------------------
    *   Entrada r0: direccion memoria de la cadena
    *   Entrada r1: direccion memoria de la letra
    *   ---------------------------------------------------------------
    *   Salida r2: 1 o 0 (true/false)
    */
    cadenaContieneLetra:
        .fnstart
            push {r0, r1, r3, r4}
            mov r2, #0      // r2 <- contador para ciclar incia en 0
            ldrb r1, [r1]   // r1 <- la letra que ingreso el usuario: inputUsuario[0]
            
            cicloCadenaContieneLetra: 
                ldrb r3, [r0, r2]               // r3 <- cadena[i]

                cmp r3, #0
                beq letraNoEstaEnCadena         // Si cadena[i] == nul -> la letra NO esta en la cadena

                cmp r3, r1                      // r3 es igual que la letra que esta en r1?
                beq letraSiEstaEnCadena         // Si cadena[i] == letra -> la letra esta en la cadena

                add r2, #1                      // i++
                bal cicloCadenaContieneLetra    // siguiente iteracion

            letraSiEstaEnCadena:
                mov r2, #1  // r2 <-- 1 para retornar true
                bal finCadenaContieneLetra

            letraNoEstaEnCadena:
                mov r2, #0  // r2 <-- 0 para retornar false
             
            finCadenaContieneLetra:
                pop {r0, r1, r3, r4}
                bx lr
        .fnend
    
    /**
    *   Reemplazar la letra ingresada por el usuario en la 
    *   palabra actual a mostrar, las veces que sea necesario.
    */
    agregarLetraAPalabraActual:
        .fnstart
            push {r0, r1, r2, r3, r4, r5}

            ldr r0, =palabraOculta
            ldr r1, =inputUsuario

            ldr r2, =palabraActual

            ldrb r3, [r1]   // r3 <- letra

            mov r4, #0      // r4 <- i: contador para iterar, empieza en 0

            cicloAgregarLetraAPalabra:
                ldrb r5, [r0, r4]    // r5 <- palabraOculta[i]

                cmp r5, #00
                beq finAgregarLetraAPalabraActual   // Si palabraOculta[i] == nul -> terminamos de iterar palabraActual

                cmp r5, r3
                bne sigCicloAgregarLetraAPalabra    // Si palabraOculta[i] != letra -> siguiente iteracion

                strb r3, [r2, r4]                   // else -> palabraActual[indice] = letra
             
            sigCicloAgregarLetraAPalabra:
                add r4, #1  // i++
                bal cicloAgregarLetraAPalabra

            finAgregarLetraAPalabraActual:
                pop {r0, r1, r2, r3, r4, r5}
                bx lr
        .fnend

    /**
    *   Resta una vida al contador de vidas restantes en =vidas.
    */
    quitarVida:
        .fnstart
            push {r0, r1, r2}

            ldr r0, =vidas
            ldrb r1, [r0]   // r1 <- vidas
            sub r2, r1, #1  // r2 = vidas - 1
            strb r2, [r0]   // vidas = r2

            pop {r0, r1, r2}
            bx lr
        .fnend

    /**
    *   Devuelve 1 (true) o 0 (false) si lo que ingreso
    *   el usuario es la palabra oculta.
    *   -----------------------------------------------
    *   Salida r0: 1 (true) o 0 (false)
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
                beq siUsuarioAcertoPalabra  // Si palabraOculta[i] == nul -> iteramos hasta el final y no hubo diferencias, acerto

                cmp r3, #' '
                beq siUsuarioAcertoPalabra  // Si palabraOculta[i] == ' ' -> iteramos hasta el final y no hubo diferencias, acerto

                ldrb r4, [r1, r2]    // r4 <- inputUsuario[i]

                cmp r3, r4
                bne noUsuarioAcertoPalabra  // Si palabraOculta[i] != inputUsuario[i] -> no acerto

                add r2, #1  // i++
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
  
    /**
    *   Determina que tipo de dato ingreso el usuario (letra o palabra)
    *   y altera los estados del juego en funcion de si el dato ingresado
    *   es correcto o no.
    */
    procesarDatos:
        .fnstart
            push {r0, r1, r2, lr}

            ldr r0, =inputUsuario

            ldrb r1, [r0, #1]           // r1 <- inputUsuario[1]
            cmp r1, #'\n'
            beq usuarioArriesgoLetra    // Si inputUsuario[1] == '\n' -> El usuario ingreso una letra

            usuarioArriesgoPalabra:
                bl usuarioAcertoPalabra // r0 <- 1 o 0 (true/false) si acerto la palabra
                cmp r0, #1
                bne palabraIncorrecta // Si no acerto
                bal finProcesarDatos

            palabraIncorrecta:
                // Quitar vidas
                ldr r1, =vidas
                strb r0, [r1]   // vidas = 0

                // Setear run = False
                ldr r1, =run
                strb r0, [r1]   // run = 0 (False)

                // // Informar al usuario que perdio
                // bl imprimirMsjJuegoPerdido
                // Volver
                bal finProcesarDatos

            usuarioArriesgoLetra:
                ldr r0, =palabraActual
                ldr r1, =inputUsuario
                bl cadenaContieneLetra      // r2 <- cadenaContieneLetra(r0:palabraActual, r1:letra): true/false
                cmp r2, #1
                beq encenderFlagRepitioLetra        // Si la letra ya estaba adivinada -> salimos

                ldr r0, =palabraOculta
                ldr r1, =inputUsuario
                bl cadenaContieneLetra      // r2 <- cadenaContieneLetra(r0:cadena, r1:letra): true/false
                cmp r2, #1
                bne usuarioNoAcertoLetra    // Si no acerto la letra no la agregamos a la palabra actual

                // Verificamos si la letra ya estaba adivinada
                bl agregarLetraAPalabraActual
                bal finProcesarDatos

            encenderFlagRepitioLetra:
                // Encender flag repitioLetra
                ldr r0, =repitioLetra
                mov r1, #1
                strb r1, [r0]
                bal finProcesarDatos

            usuarioNoAcertoLetra:
                bl guardarLetraUsada    // r0 <- si la pudo agregar o no (porque ya estaba presente)
                cmp r0, #0
                beq finProcesarDatos    // Si !laPudoAgregar -> ya estaba la letra, salimos de la subrutina
                bl quitarVida           // restar una vida porque no acerto la letra

            finProcesarDatos:
                pop {r0, r1, r2, lr}
                bx lr
        .fnend

    /**
    *   Imprime por consola la solictud al usuario de ingresar
    *   una letra minuscula o la palabra si desea adivinar, 
    *   lee lo ingresado y vuelve a solicitar si lo que ingreso
    *   no es valido.
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
                ldrb r1, [r0]           // inputUsuario[0]
                
                cmp r1, #'a'
                blt cicloPedirLetra     // Si inputUsuario[0] < 'a' -> volver a pedir
                
                cmp r1, #'z'
                bgt cicloPedirLetra     // Si inputUsuario[0] < 'z' -> volver a pedir
                
            finCicloPedirLetra:
                pop {r0, r1, r2, lr}
                bx lr
        .fnend

    /**
    *   TODO
    */
    preguntaAproximativa:
        .fnstart
            push {lr}
            // si emboca -> vidas++
            // si no emboca
            nop
            pop {lr}
            bx lr
        .fnend

    /**
    *   TODO
    */
    disparo:
        .fnstart
        push {lr}
        // si le pifia -> run = False
        nop
        pop {lr}
        bx lr
        .fnend

    /**
    *   Inicia la parte del juego en que se le dan al usuario
    *   las ultimas chances para evitar perder el juego.
    */
    jugarUltimasChances:
        .fnstart
        push {r0, lr}

        bl preguntaAproximativa

        ldr r0, =vidas
        ldrb r0, [r0]   // r0 <- vidasRestantes

        // Si vidasRestantes > 0 -> que continue el juego, sin pasar por disparo
        cmp r0, #0 
        bgt finJugarUltimasChances  

        // else -> damos la ultima oportunidad
        bl disparo

        finJugarUltimasChances:
            pop {r0, lr}
            bx lr
        .fnend

    /**
    *   Ejecuta la cadena de subrutinas que componen el juego.
    */
    jugar:
        .fnstart
            push {r0, lr}

            // ejecutar cadena de comandos:
            bl imprimirMapa
            bl informarEstado

            ldr r0, =vidas
            ldrb r0, [r0]   // r0 <- vidas restantes

            // Si vidasRestantes <= 0 -> 
            cmp r0, #0 
            bgt inputOutput
            
            // else -> ofrecemos las ultimas chances (pregunta aprox y disparo)
            bl jugarUltimasChances
            bal finJugar

            inputOutput:
                bl pedirLetra
                bl procesarDatos
                bl actualizarPalabraActualEnMapa
                bl actualizarPersonaEnMapa

            finJugar:
                pop {r0, lr}
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
            push {r0, r1, r2, r3, r4, r5, r6}
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
                pop {r0, r1, r2, r3, r4, r5, r6}
                bx lr
        .fnend
    
    /**
    *   Solicita al usuario que ingrese un numero en el 
    *   rango [1, 20], y reintenta si lo ingresado esta fuera.
    */
    elegirNumero:
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
                
                ldr r0, =numeroPalabraElegida
                str r1, [r0]

                // Si esta dentro del rango [1, 20] podemos salir
                pop {r0, r1, r2, lr}
                bx lr
        .fnend
    

.global main
main:

    bl elegirNumero
    ldr r0, =numeroPalabraElegida
    ldr r1, [r0]                        // r1 <- numero (word) que ingreso el usuario
    bl cargarPalabra                    // Cargamos la palabra en =palabraOculta <- cargarPalabra(r1: numero)
    bl actualizarPalabraActualEnMapa    // Actualizamos los "_____" en el mapa.
  
    cicloWhile:
        bl jugar
    
        ldr r0, =run
        ldrb r1, [r0]    // r1 <- run (true/false)
    
        cmp r1, #1
        beq cicloWhile  // Si run == True -> entrar al while otra vez

fin:
    mov r7, #1
    swi 0
