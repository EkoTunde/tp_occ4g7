.data

coordenadaX: .word 0
coordenadaY: .word 0

ingresarX: .asciz "Ingrese la coordenada x para el disparo: \n"
ingresarY: .asciz "Ingrese la coordenada y para el disparo: \n"


@Imprime un mensaje indicando que se ingrese la coordenada X del disparo.
imprimirPedidoX:
.fnstart
   mov r7, #4              @Tipo de interrupcion  = lectura por teclado
   mov r0, #1              @Salida de cadena
   mov r2, #43            @Tamaño de la cadena, 
   ldr r1, = ingresarX
   swi 0
   bx lr
.fnend

@Imprime un mensaje indicando que se ingrese la coordenada Y del disparo.
imprimirPedidoY:
.fnstart
   mov r7, #4             @Tipo de interrupcion = lectura por teclado
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