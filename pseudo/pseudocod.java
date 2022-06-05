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

    /* MATI */
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

    /* BRA */
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

    /* ESTA HECHA EN CLASE */
    int tamanoCadena(int dirMem) {
        return 0;
    }

    /* JUAN */
    // imprimir feedback
    void imprimirFeedback() {
        /*
         * .data
         * feedback: .asciz "Quedan 5 letras por adivinar."
         */
        int dirMem = 0; // ldr r1, =feedback
        int tamanoCadena = tamanoCadena(dirMem);
        imprimir(dirMem, tamanoCadena);
    }

    /**
     * MATI
     *
     * Lo que está en ascii lo retorna en un numero
     */
    int convertirANum(char caracter) {
        return caracter - 30;
    }

    /* BRA */
    int escanearOpcion() {
        Scanner sc = new Scanner("Ingresá 1 para arriesgar letra, 2 para arriesgar palabra");
        char input = sc.next().toCharArray()[0];
        sc.close();
        int num = convertirANum(input);
        return num;
    }

    /* JUAN */
    char escanearLetra() {
        // .data
        // escanerLetra: .byte "a"
        Scanner sc = new Scanner("Ingrese una letra");
        char input = sc.next().toCharArray()[0];
        int dirMem = 0; // ldrb r1, =escanerLetra
        int tamanoEscanear = 1;
        sc.close();
        return input;
    }

    void escanearPalabra() {
        Scanner sc = new Scanner("Ingresá 1 para arriesgar letras, 2 para arriesgar palabra");
        char input = sc.next().toCharArray()[0];
        sc.close();
        // return input;
    }

    public static final int OPCION_JUGAR = 1;
    public static final int OPCION_ARRIESGAR_LETRA = 1;
    public static final int OPCION_ARRIESGAR_PALABRA = 2;
    public static final int OPCION_SALIR = 3;
    public static final String abc = "abcdefghijklmnopqrstuvwxyz";
    static int vidas, opcionSelecMenuPpal, opcionSelecJuego;
    static boolean salir, jugando, jugadorGano, jugadorAcerto;
    static String palabraSecreta = "JuanCruz";
    static String palabraSecretaActual = palabraSecreta;
    static Scanner sc;
    static String letrasArriesgadas = "";

    static String[] menuPrincipal = new String[] {
            "Bienvenido al juego del ahorcado. Seleccione una opción para continuar.",
            "1. Jugar",
            "2. Salir"
    };
    static String[] menuJuego = new String[] {
            "¿Qué desea hacer a continuación?",
            "1. Arriesgar letra",
            "2. Arriesgar palabra",
            "3. Salir",
    };
    static String[] mapaAhorcado = new String[] {
            "┌──────────────────────────────────────────────────┐", // 0
            "│ *** EL JUEGO DEL AHORCADO - ORGA 1 - GRUPO 7 *** │", // 1
            "├──────────────────────────────────────────────────┤", // 2
            "│                                                  │", // 3
            "│  +----------+                                    │", // 4
            "│  |          |                                    │", // 5
            "│  |          1                                    │", // 6
            "│  |         425                                   │", // 7
            "│  |          3                                    │", // 8
            "│  |         6 7                                   │", // 9
            "│  |                                               │", // 10
            "│  ┴                                               │", // 11
            "│                                                  │", // 12
            "│  +--------------------------------------------+  │", // 13
            "│  |                                            |  │", // 14
            "│  | 9 |  │", // 15
            "│  |                                            |  │", // 16
            "│  +--------------------------------------------+  │" // 17
    };

    static void run() {
        sc = new Scanner(System.in);
        salir = jugando = jugadorGano = jugadorAcerto = false;
        opcionSelecMenuPpal = opcionSelecJuego = 0;
        vidas = 7;
        while (!salir) {
            if (!jugando) {
                mostrarMenuPpal();
                if (opcionSelecMenuPpal == OPCION_JUGAR) {
                    jugando = true;
                    vidas = 7;
                } else
                    salir = true;
            } else {
                mostrarMapa();
                if (vidas == 0) {
                    informarJuegoTermino();
                    jugando = false;
                } else {
                    mostrarOpcionesJuego();
                    if (opcionSelecJuego == OPCION_ARRIESGAR_LETRA) {
                        arriesgarLetra();
                        if (!jugadorAcerto)
                            --vidas;
                    } else if (opcionSelecJuego == OPCION_ARRIESGAR_PALABRA) {
                        arriesgarPalabra();
                        jugadorGano = jugadorAcerto;
                        vidas = 0;
                    } else {
                        salir = true;
                    }

                }
                actualizarData();
            }
        }
        System.out.println("¡Gracias por jugar!");
        sc.close();
    }

    static void actualizarData() {
        palabraSecretaActual = "";
        for (String s : palabraSecreta.split("")) {
            if (letrasArriesgadas.contains(s))
                palabraSecretaActual += s;
            else
                palabraSecretaActual += "_";
        }
    }

    static boolean chequearPalabra(String palabraIngresada) {
        if (palabraIngresada.length() == 0)
            throw new IllegalArgumentException("La palabra ingresada no puede ser vacía");
        return palabraIngresada.equals(palabraSecreta);
    }

    static void arriesgarPalabra() {
        System.out.print("Ingrese una palabra");
        boolean reintentar = true;
        while (reintentar) {
            try {
                if (sc.hasNextLine()) {
                    String palabra = sc.nextLine().toLowerCase();
                    jugadorAcerto = chequearPalabra(palabra);
                    reintentar = !reintentar;
                }
            } catch (IllegalArgumentException e) {
                System.out.println("La palabra ingresada no es válida.");
                reintentar = true;
            }
        }
    }

    static boolean chequearLetra(String letra) {
        if (letra.length() != 1 || !abc.contains(letra)) {
            throw new IllegalArgumentException("El dato " + "\"" + letra + "\"" + " ingresado no es una letra válida");
        }
        return palabraSecreta.contains(letra);
    }

    static void arriesgarLetra() {
        System.out.print("Ingrese una letra: ");
        boolean reintentar = true;
        while (reintentar) {
            try {
                if (sc.hasNextLine()) {
                    String letra = sc.nextLine().toLowerCase();
                    letrasArriesgadas += letra;
                    if (chequearLetra(letra)) {

                    } else {
                        --vidas;
                    }
                    reintentar = false;
                }
            } catch (IllegalArgumentException e) {
                e.printStackTrace();
                System.out.println("La letra ingresada no es válida.");
                reintentar = true;
            }
        }
    }

    static void mostrarOpcionesJuego() {
        for (String s : menuJuego)
            System.out.println(s);
        boolean usuarioSeleccionoAlgo = false;
        while (!usuarioSeleccionoAlgo) {
            if (sc.hasNextLine()) {
                String input = sc.nextLine();
                usuarioSeleccionoAlgo = true;
                if (input.equals("1"))
                    opcionSelecJuego = OPCION_ARRIESGAR_LETRA;
                else if (input.equals("2"))
                    opcionSelecJuego = OPCION_ARRIESGAR_PALABRA;
                else if (input.equals("3"))
                    salir = true;
                else {
                    usuarioSeleccionoAlgo = false;
                    System.out.println("Ingrese una opción válida");
                }
            }
        }

    }

    private static void informarJuegoTermino() {
        System.out.println("¡Juego terminado!");
    }

    static void mostrarMenuPpal() {
        for (String s : menuPrincipal)
            System.out.println(s);
        boolean usuarioSeleccionoAlgo = false;
        while (!usuarioSeleccionoAlgo) {
            if (sc.hasNextLine()) {
                String input = sc.nextLine();
                usuarioSeleccionoAlgo = true;
                if (input.equals("1")) {
                    opcionSelecMenuPpal = OPCION_JUGAR;
                } else if (input.equals("2")) {
                    opcionSelecMenuPpal = OPCION_SALIR;
                } else {
                    usuarioSeleccionoAlgo = false;
                    System.out.println("Ingrese una opción válida");
                }
            }
        }
    }

    private static String palabraMapa() {
        String temp = "";
        for (int i = 0; i < 42; i++) {
            if (i < palabraSecretaActual.length()) {
                temp += palabraSecretaActual.charAt(i);
            } else {
                temp += " ";
            }
        }
        return temp;
    }

    private static void mostrarMapa() {
        for (int i = 0; i < mapaAhorcado.length; i++) {
            String s = mapaAhorcado[i];
            if (i == 15) {
                System.out.println(s.replace("9", palabraMapa()));
            }

            else if (i == 6) {
                if (vidas <= 6)
                    System.out.println(s.replace("1", "o"));
                else
                    System.out.println(s.replace("1", " "));
            }

            else if (i == 7) {

                if (vidas <= 5)
                    System.out.println(s.replace("2", "|"));
                else
                    System.out.println(s.replace("2", " "));

                if (vidas <= 3)
                    System.out.println(s.replace("4", "/"));
                else
                    System.out.println(s.replace("4", " "));

                if (vidas <= 2)
                    System.out.println(s.replace("5", "\\"));
                else
                    System.out.println(s.replace("5", " "));

            }

            else if (i == 8) {

                if (vidas <= 4)
                    System.out.println(s.replace("3", "|"));
                else
                    System.out.println(s.replace("3", " "));

            }

            else if (i == 9) {
                if (vidas <= 1)
                    System.out.println(s.replace("6", "/"));
                else
                    System.out.println(s.replace("6", " "));

                if (vidas == 0)
                    System.out.println(s.replace("7", "\\"));
                else
                    System.out.println(s.replace("7", " "));
            }

            else
                System.out.println(s);
        }
    }

    public static void main(String[] args) {
        run();
    }

}
