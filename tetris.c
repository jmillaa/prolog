/*Autores: Jorge Milla Hernandez y Alvaro Fincias*/
/*  
           _____          _            _       
          |_   _|   ___  | |_   _ __  (_)  ___ 
            | |    / _ \ | __| | '__| | | / __|
            | |   |  __/ | |_  | |    | | \__ \
            |_|    \___|  \__| |_|    |_| |___/

            Autores: Jorge Milla Hernandez Y Alvaro Fincias
            Usando el algoritmo A estrella                       
*/

/*La Heuristica que hemos pensado para resolver el juego del tetris aplicando el algoritmo de A estrella es la siguiente:
    Creemos que lo mas importante es minimizar el numero de huecos en blanco por debajo de la altura de la pieza mas elevada. 
    Ademas, vamos a preferir una colocacion de las piezas en el tablero que sea de menor altura ya que de esta forma estaremos
    mas alejados del limite superior del tablero y mas vivos en el juego. Creo que es mejor darle mas importancia a lo de los huecos
    en blanco, por lo que le daremos mas prioridad, multiplicandola por una constante para aumentar el valor rapidamente.
    
    Cuando acabe el codigo tengop que dar mas informacion sobre el proceso, que no se me olvide) */


#include <stdio.h>
#include <stdlib.h>
#include <string.h> 


//Constantes
#define FILAS 4
#define COLUMNAS 5

//Tipos de datos

//Nodo
typedef struct Nodo{
    int tablero[FILAS][COLUMNAS];
    int g; //Costo acumulado
    int h; //Coste de la Heuristica desde el nodo al final
    int f; // Es la suma de g(n) + h(n)
    int piezaActual; 
    int orientacion; // Orientación actual de la pieza
    int columna; // Columna donde se coloca la pieza
    struct Nodo* sig; //Apunta al siguiente nodo en la cola de prioridad
} Nodo;

//Cola
typedef struct ColaPrioridad{
    Nodo* cabeza;
} ColaPrioridad;

//Prototipos de la funcion
void iniciarTablero(int tablero[FILAS][COLUMNAS]);
void imprimeTablero(int tablero[FILAS][COLUMNAS]);
void colocarPieza(int tablero[FILAS][COLUMNAS], int pieza[3][3], int fila, int columna);
int puedoColocarPieza(int tablero[FILAS][COLUMNAS], int pieza[3][3], int fila, int columna);
int calcularOffsetPieza(int pieza[3][3]);
int calcular_fila_para_colocar(int tablero[FILAS][COLUMNAS], int pieza[3][3], int columna);
int cuentaHuecos(int tablero[FILAS][COLUMNAS]);
int cuentaAltura(int tablero[FILAS][COLUMNAS]);
int indiceFilaAlta(int tablero[FILAS][COLUMNAS]);
void inicializarCola(ColaPrioridad* cola);
Nodo* crearNodo(int tablero[FILAS][COLUMNAS], int g, int h, int piezaActual, int orientacion, int columna);
void insertarEnCola(ColaPrioridad* cola, Nodo* nuevo);
Nodo* extraerNodoCola(ColaPrioridad* cola);
int estaVacia(ColaPrioridad* cola);
void ejecutarAEstrella(int tablero[FILAS][COLUMNAS], int secuencia[4][4][3][3], int num_piezas);





int main (){
    int tablero[FILAS][COLUMNAS];
    iniciarTablero(tablero);

    //Definimos las piezas 
    //Va a ser una matriz tridimensional, el primer indice es las orientaciones y los otros dos la dimension de la pieza
    //int pieza1[Numero de Orientaciones][Tamanyo de la pieza][Tamanyo de la pieza]
    // Pieza T
    int pieza1[4][3][3] = {
        //=====================
        // Orientación 0    
        //  0 0 0
        //  0 1 0
        //  1 1 1
        //=====================
        {{0, 0, 0}, {0, 1, 0}, {1, 1, 1}},  
        //=====================
        // Orientación 1    
        //  0 1 0
        //  0 1 1
        //  0 1 0
        //=====================
        {{0, 1, 0}, {0, 1, 1}, {0, 1, 0}}, 
        //=====================
        // Orientación 2    
        //  0 0 0
        //  1 1 1
        //  0 1 0
        //=====================
        {{0, 0, 0}, {1, 1, 1}, {0, 1, 0}}, 
        //=====================
        // Orientación 3    
        //  0 1 0
        //  1 1 0
        //  0 1 0
        //=====================
        {{0, 1, 0}, {1, 1, 0}, {0, 1, 0}}  
    };

    //Pieza Cuadrado
    int pieza2[4][3][3] = {
        //=====================
        // Orientación unica   
        //   0 0 0
        //   0 1 1
        //   0 1 1
        //=====================
        {{0,0,0}, {0, 1, 1}, {0, 1, 1}},  
        {{0,0,0}, {0, 1, 1}, {0, 1, 1}},  
        {{0,0,0}, {0, 1, 1}, {0, 1, 1}},  
        {{0,0,0}, {0, 1, 1}, {0, 1, 1}},  
    };
    // Pieza L
    int pieza3[4][3][3] = {
        //=====================
        // Orientación 0    
        //  0 0 0
        //  0 0 1
        //  1 1 1
        //=====================
        {{0, 0, 0}, {0, 0, 1}, {1, 1, 1}},  
        //=====================
        // Orientación 1    
        //  1 0 0
        //  1 0 0
        //  1 1 0
        //=====================
        {{1, 0, 0}, {1, 0, 0}, {1, 1, 0}}, 
        //=====================
        // Orientación 2    
        //  0 0 0
        //  1 1 1
        //  1 0 0
        //=====================
        {{0, 0, 0}, {1, 1, 1}, {1, 0, 0}}, 
        //=====================
        // Orientación 3    
        //  0 1 1
        //  0 0 1
        //  0 0 1
        //=====================
        {{0, 1, 1}, {0, 0, 1}, {0, 0, 1}}  
    };

    //Aqui deberia ir la implementacion del resto de fichas pero como
    //No voy sobrado de tiempo, de momento me voy a centrar en las que 
    //Usaremos en la secuencia de 1,2,3,3
    // Secuencia de piezas (1, 2, 3, 3)
    int secuencia[4][4][3][3];
    memcpy(secuencia[0], pieza1, sizeof(pieza1));
    memcpy(secuencia[1], pieza2, sizeof(pieza2));
    memcpy(secuencia[2], pieza3, sizeof(pieza3));
    memcpy(secuencia[3], pieza3, sizeof(pieza3));

    int num_piezas = 4;

    printf("Tablero inicial:\n");
    imprimeTablero(tablero);

    // Ejecutar A*
    printf("\nEjecutando algoritmo A*...\n");
    ejecutarAEstrella(tablero, secuencia, num_piezas);

    return 0;
}

void iniciarTablero(int tablero[FILAS][COLUMNAS]){
    int i, j;

    for (i=0; i<FILAS; i++){
        for (j=0; j<COLUMNAS; j++){
            tablero[i][j] = 0;
        } 
    }
}

void imprimeTablero(int tablero[FILAS][COLUMNAS]){
    int i, j;

    for (i=0; i<FILAS; i++){
        for (j=0; j<COLUMNAS; j++){
            printf("%d ", tablero[i][j]);
        } 
        printf("\n");
    }
}

void colocarPieza(int tablero[FILAS][COLUMNAS], int pieza[3][3], int fila, int columna){
    int i, j, nuevaFila, nuevColumna;
    int offset;

    // Calcular la fila más baja donde se puede colocar la pieza
    fila = calcular_fila_para_colocar(tablero, pieza, columna);

    offset = calcularOffsetPieza(pieza);

    if(puedoColocarPieza(tablero, pieza, fila, columna)){
        for (i=0; i<3; i++){
            for (j=0; j<3; j++){
                if (pieza[i][j] == 1){
                    nuevaFila = fila + i;
                    nuevColumna = columna + j - offset;
                    tablero[nuevaFila][nuevColumna] = 1;
                }   
            }
        }
    }
}

//Funcion que me calcula la distancia entre la columna llena de 0 y la columna en la que empieza la pieza
int calcularOffsetPieza(int pieza[3][3]){
    int i, j;

    for (i=0;i<3;i++){
        for (j=0; j<3; j++){
            if (pieza[j][i] == 1){
                return i; //Aqui estoy devolviendo el indice de la primera columna de la pieza que tiene parte de la pieza
            }
        }
    }
    return 0;
}

//Con esta funcion veo si puedo colocar la pieza y si entra en los limites del tablero.
int puedoColocarPieza(int tablero[FILAS][COLUMNAS], int pieza[3][3], int fila, int columna){
    int offset;
    int i, j;
    int filaNueva, ColumnaNueva;
    offset = calcularOffsetPieza(pieza);

    for (i=0;i<3; i++){
        for(j = 0; j<3; j++){
            if(pieza[i][j] == 1){
                filaNueva = fila + i;
                ColumnaNueva = columna + j - offset;
                if(filaNueva >= FILAS || filaNueva < 0 || ColumnaNueva >= COLUMNAS || ColumnaNueva < 0 ){
                    return 0; //Fuera de los limites del tablero 
                }
                if(tablero[filaNueva][ColumnaNueva] == 1){
                    return 0; //ya hay otra pieza en esa posicion
                }

            }
        }
    }

    return 1; //Se puede insertar la pieza
}

int calcular_fila_para_colocar(int tablero[FILAS][COLUMNAS], int pieza[3][3], int columna) {
    for (int fila = 0; fila < FILAS; fila++) {
        if (!puedoColocarPieza(tablero, pieza, fila, columna)) {
            // Si no se puede colocar en esta fila, devolvemos la fila anterior
            return fila - 1;
        }
    }
    // Si no hay colisión, la pieza puede colocarse en la última fila
    return FILAS - 1;
}

int cuentaAltura(int tablero[FILAS][COLUMNAS]){
    int i,j;
    for (i=0; i<FILAS; i++){
        for (j=0; j<COLUMNAS; j++){
            if(tablero[i][j] == 1){
                return FILAS-i;
            }
        }
    }
    
    return 0; //Si el tablero esta vacio devuelve altura 0
}

int cuentaHuecos(int tablero[FILAS][COLUMNAS]){
    int i,j;
    int contadorHuecos = 0;
    int filas;
    filas = indiceFilaAlta(tablero); //Aqui tengo guardado el valor del inidice de la fila de mas altura, por lo que mirare el numero de huecos en blanco por debajo de esta altura

    for (i=FILAS-1; i>filas; i--){
        for (j=0; j<COLUMNAS; j++){
            if(tablero[i][j] == 0){
               contadorHuecos++;
            }
        }
    }
    return contadorHuecos; // Devolvemos el contador de huecos
}

int indiceFilaAlta(int tablero[FILAS][COLUMNAS]){
    int i, j;

    for (i=0; i<FILAS; i++)
        for(j=0; j<COLUMNAS; j++){
            if (tablero[i][j] == 1){
                return i;
            }
        }
    return 0;
}

//Funcion que va a verificar mi heuristica

int verificarHeuristica(int tablero[FILAS][COLUMNAS]){
    int i,j;
    int altura, huecos;

    altura = cuentaAltura(tablero);
    huecos = cuentaAltura(tablero);

    return huecos * 20 + altura; //Le doy mas impoartancia a que no haya huecos
}


// Inicializa una cola vacía
void inicializarCola(ColaPrioridad* cola) {
    cola->cabeza = NULL; 
}

//Creamos un nodo con los datos iniciales

Nodo* crearNodo(int tablero[FILAS][COLUMNAS], int g, int h, int piezaActual, int orientacion, int columna){
    Nodo* nuevo = (Nodo*)malloc(sizeof(Nodo));
    if (!nuevo){ //Si no se ha creado bien el nodo damos error
        perror("Error al asignar memoria para un nodo");
        exit(EXIT_FAILURE);
    }

    memcpy(nuevo->tablero, tablero, sizeof(int) * FILAS * COLUMNAS);
    nuevo->g = g;
    nuevo->h = h;
    nuevo->f = g + h;
    nuevo->piezaActual = piezaActual;
    nuevo->orientacion = orientacion;
    nuevo->columna = columna;
    nuevo->sig = NULL;
    return nuevo; //Devuelvo el nodo al final, ya rellenado con información
}

//Insertamos un nodo en la cola de prioridad
void insertarEnCola(ColaPrioridad* cola, Nodo* nuevo){
    if (cola->cabeza == NULL || nuevo->f < cola->cabeza->f ){
        //Lo inserto en la cabeza si el nodo tiene una f menor que lo que ya hay, o si la cola esta vacia yes yes yes :)
        nuevo->sig = cola->cabeza;
        cola->cabeza = nuevo;
    }
    else{  
        Nodo* actual = cola->cabeza;
        //Recorro todos los nodos hasta encontrar su posicion en la que lo inserto
        while(actual->sig != NULL && actual->sig->f <= nuevo->f){
            actual = actual->sig;
        }
        nuevo->sig = actual->sig;
        actual->sig = nuevo;
    }
}

//Funcion para extraer un nodo de la cola
Nodo* extraerNodoCola(ColaPrioridad* cola){
    if (cola->cabeza == NULL){
        return NULL;
    }
    Nodo* nodo = cola->cabeza;
    cola->cabeza = cola->cabeza->sig;
    nodo->sig = NULL;
    return nodo;
}

// Funcio que verifica si la cola está vacía
int estaVacia(ColaPrioridad* cola) {
    return cola->cabeza == NULL;
}

void ejecutarAEstrella(int tablero[FILAS][COLUMNAS], int secuencia[4][4][3][3], int num_piezas) {
    ColaPrioridad cola;
    inicializarCola(&cola);

    // Crear nodo inicial
    Nodo* inicial = crearNodo(tablero, 0, verificarHeuristica(tablero), 0, 0, 0);
    insertarEnCola(&cola, inicial);

    while (!estaVacia(&cola)) {
        Nodo* actual = extraerNodoCola(&cola);

        // Si hemos colocado todas las piezas, imprimimos el tablero final y terminamos
        if (actual->piezaActual == num_piezas) {
            printf("Solución encontrada:\n");
            imprimeTablero(actual->tablero);
            free(actual);
            return;
        }

        // Iterar sobre todas las orientaciones y columnas posibles para la pieza actual
        for (int orientacion = 0; orientacion < 4; orientacion++) {
            for (int columna = 0; columna < COLUMNAS; columna++) {
                // Crear una copia del tablero actual
                int nuevoTablero[FILAS][COLUMNAS];
                memcpy(nuevoTablero, actual->tablero, sizeof(nuevoTablero));

                // Calcular la fila donde colocar la pieza
                int fila = calcular_fila_para_colocar(nuevoTablero, secuencia[actual->piezaActual][orientacion], columna);

                // Si es posible colocar la pieza, crear un nuevo nodo
                if (puedoColocarPieza(nuevoTablero, secuencia[actual->piezaActual][orientacion], fila, columna)) {
                    colocarPieza(nuevoTablero, secuencia[actual->piezaActual][orientacion], fila, columna);

                    // Calcular costos
                    int nuevoG = actual->g + 1; // Costo acumulado aumenta por 1 (movimiento simple)
                    int nuevoH = verificarHeuristica(nuevoTablero); // Recalcular heurística
                    Nodo* nuevoNodo = crearNodo(nuevoTablero, nuevoG, nuevoH, actual->piezaActual + 1, orientacion, columna);

                    // Insertar en la cola de prioridad
                    insertarEnCola(&cola, nuevoNodo);
                }
            }
        }

        // Liberar memoria del nodo actual
        free(actual);
    }

    // Si llegamos aquí, no hay solución
    printf("No se encontró una solución.\n");
}

