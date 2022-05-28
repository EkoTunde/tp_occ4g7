package pseudo;

import java.util.Scanner;

class Pseudo {

    // imprimir: imprime una linea de .asciz
    private static void imprimir(int etiquetaDireccionMemoria, int tamanoCadena) {
        String direcciones = "direcciones de memoria";
        String sub = direcciones.substring(
                etiquetaDireccionMemoria,
                etiquetaDireccionMemoria + tamanoCadena);
        System.out.println(sub);
    }

    // imprimir mapa: ciclo que llama a imprimir

    private static void imprimirMapa() {
        // .data
        // matriz: .ascii "0123...51"
        // .ascii "0123...51"
        // ldr r1, =matriz

        int tamanoCadena = 52;
        int dirMem = 0; // ldr r1, =matriz
        int contador = 0;
        int cantidadFilas = 14;
        while (contador < cantidadFilas) {
            imprimir(dirMem, tamanoCadena);
            contador++;
            dirMem += 52;
        }
    }

    private static void imprimirAciertos() {
        /*
         * .data
         * tamanoCadena: .byte 52
         * matrizAciertos: .ascii "0123...51" // (x5)
         * .ascii "0123...51"
         */
        int tamanoCadena = 52; // ldr r2, [tamanoCadena]
        int dirMem = 0; // ldr r1, =matrizAciertos
        int contador = 0;
        int cantidadFilas = 5;
        while (contador < cantidadFilas) {
            imprimir(dirMem, tamanoCadena);
            contador++;
            dirMem += 52;
        }
    }

    // imprimir feedback
    void imprimir() {

    }

    // imprimir estado juego
    // imprimir vidas
    // imprimir info: feedback, estado juego, vidas
    private static void imprimirInfo() {
        // Todo
    }

    private static void escanearLetra() {
        // Imprimir la instrucción
        System.out.println("Instrucción al usuario: ");
        // Reciba el input de usuario
        Scanner scanner = new Scanner("Ingresá una letra");
        // Retorne lo primero que encuentre
        String input = scanner.next();
    }

    public static void main(String[] args) {
        System.out.println("Hola");
    }

}