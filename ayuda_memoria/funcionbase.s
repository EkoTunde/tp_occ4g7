/*********************** INI <NOMBRE PROCEDIMIENTO> ********************************/
    /**
    *   <Lo que hace la funcion>
    *   ---------------------------------------------------------------
    *   Entrada <nro-registro>: <descripcion>
    *   Entrada <nro-registro>: <descripcion>
    *   ---------------------------------------------------------------
    *   Salida <nro-registro>: <descripcion>
    */
    nombreFuncion:
        .fnstart
            push {<registros>}
            // Codigo del procedimiento
            pop {<registros>}
            bx lr
        .fnend
/*********************** FIN <NOMBRE PROCEDIMIENTO> ********************************/