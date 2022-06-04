.data
 /* Definicion de datos */
mapa: .asciz "___________________________________________________|\n                                                   |\n     *** EL JUEGO DEL AHORCADO - ORGA 1 ***        |\n___________________________________________________|\n                                                   |\n                                                   |\n          +------------+                           |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n +-------------------------------------------+     |\n |                                           |     |\n |                                           |     |\n |                                           |     |\n +-------------------------------------------+     |\n"

longitud = . - mapa
/*
___________________________________________________|\n
                                                   |\n
     *** EL JUEGO DEL AHORCADO - ORGA 1 ***        |\n
___________________________________________________|\n
                                                   |\n
                                                   |\n
          +------------+                           |\n
          |            |                           |\n
          |            o                           |\n
          |           /|\\                          |\n
          |            |                           |\n
          |           / \\                          |\n
          |                                        |\n
          |                                        |\n
          |                                        |\n
 +-------------------------------------------+     |\n
 |                                           |     |\n
 |    _ _ _ _ _ _ _ _ _ _ _ _ _ _            |     |\n
 |                                           |     |\n
 +-------------------------------------------+     |\n
*/

enter: .ascii "\n"

cls: .asciz "\x1b[H\x1b[2J" //una manera de borrar la pantalla usando ansi escape codes
lencls = .-cls

//----------------------------------------------------------
.text             @ Defincion de codigo del programa
//----------------------------------------------------------



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

.global main        @ global, visible en todo el programa
main:
    //imprimo el mapa para empezar
    ldr r2, =longitud //Tamaño de la cadena
    ldr r1, =mapa   //Cargamos en r1 la direccion del mensaje
    bl imprimirString

    mov r7, #1    // Salida al sistema
    swi 0
    