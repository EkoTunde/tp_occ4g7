
@ Declaramos las constantes, reservando el espacio en memoria
.data
    @Todo


@ Declaramos nuestro código del programa
.text
    @Todo

    @ Donde empieza nuestro programa
    .global main
    main:
        @Todo


    @ Para manejar el fin del programa
    fin:
        mov r7, #1
        swi 0
