# Ahorcado

## 💾 Datos
* cantiVidas: 7 vidas
* palabtasSecretas: lista de palabras para jugar
* palabraAdivinar: ir completando con los casos que se adivina
* preguntasSecretas: lista de preguntas
* x: posCuerda -> es una coordenada x
* y: posCuerda -> es una coordenada y

## ✅ Acciones
* mostrarMapa
* mostarUnaPalabra: se muestra con @ ------
* arriesgarLetra(letra)
* arriesgarPalabra(palabra)
* aciertaPreguntaSecreata (num) // Segunda parte
* juegoTerminado
* juegoGanado
* aciertaDisparo(x, y) -> 3ra parte: se utiliza solo cuando el jugador perdió. 'x' e 'y' es la coordenada donde "dispara"

## Funciones
* palabraAleatoria: elige una palabra aleatoria de un lemario.

* ✅imprimir: imprime una linea de .asciz
* imprimir mapa: ciclo que llama a imprimir
* imprimir los aciertos: ciclo que llama a imprimir
* imprimir feedback
* imprimir estado juego
* imprimir vidas
* imprimir info: feedback, estado juego, vidas

* imprimirOpciones: imprime opcion de arriesgar letra o palabra

* escanearOpcion: si es 1, escanearLetra; si es 2, escanearPalabra
* escanearLetra: imprima la instruccion y devuelva lo que ingresó el usuario (1 byte)
* esAciertoLetra: retorna si una letra es parte de la palabra secreta
* buscar y reemplezar letras acertadas en indices [fila][columna]
* restarUnaVida: al contador de vidas lo disminuye de a 1.
* actualizarAhorcado: actualiza la matriz del ahorcado
* actulizarInfo: 



* escanearPalabra: imprima la instruccion y devuelva lo que ingresó el usuario (1 byte por cada caracter que tiene nuestra palabra secreta)
* ✅tamanoCadena: retorna cantidad de caracteres de nuestra. IMPLEMENTADO EN CLASE (COPIAR)
* esAciertoPalabra: comparar con la palabra secreta.