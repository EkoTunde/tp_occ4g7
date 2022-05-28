.data

VAR1: .WORD 5
VAR2: .WORD 6

VECTOR1: .WORD 9,2,3,5,8 /* 4 bytes x cada digito * 5 cant_dig/
                       
-----------------------------
@recorrido de un vector

MOV r1,#0
MOV r2,#5
LDR r3, =vector1 // obtengo el puntero en donde esta direc de memoria
                 // del vector

etqCiclo:
  CMP r1,r2
  BEQ fin://salta cuando el r1 llega a 5
  LDR R4,[R3] @obtengo el elemento
  ADD r3,#4 // aumento el registro en 4 bytes con #4 para avanzar a la 
            // siguiente posicion del vector

  ADD r1,#1 // aumento el contador del ciclo
  BAL etqCiclo

Fin:
  /* fin del programa*/
--------------------------------------------------------------------
@quiero obtener el valor de la coordenada matriz[3][2]
.data 
  matriz: .word 2,5,1
	  .word 3,4,8
	  .word 4,9,7
	  .word 0,3,5
          .word 0,2,5
.text
.global main:
	mov r0,#3 @fila
        mov r1,#2 @col

	mov r2,#3 @cant de colum, o elementos
	ldr r3, =matriz  @direccion del comienzo de la matriz

	mov r4,#1 @filas a saltear
	mul r4,r0,r2 @r4=r0*r4 
	mul r4,#4 @.word @36

	mov r5,#1 
	mul r5,r1,#4 @.word 

	add r3,r4
	add r3,r5

	ldr r6,[r3] @obtengo el elemento de la matriz [3][2]

	mov r7,#1 @interrupcion



   