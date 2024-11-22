#include <stdio.h>
#include <stdlib.h>

//Constantes
#define FILAS 4
#define COLUMNAS 5

//Prototipos de la funcion
void iniciarTablero(int tablero[FILAS][COLUMNAS]);
void imprimeTablero(int tablero[FILAS][COLUMNAS]);
void colocarPieza(int tablero[FILAS][COLUMNAS], int pieza[3][3], int fila, int columna);
int puedoColocarPieza(int tablero[FILAS][COLUMNAS], int pieza[3][3], int fila, int columna);
int calcularOffsetPieza(int pieza[3][3]);
int calcular_fila_para_colocar(int tablero[FILAS][COLUMNAS], int pieza[3][3], int columna);
int cuentaHuecos(int tablero[FILAS][COLUMNAS]);



int main (){
    int tablero[FILAS][COLUMNAS];
    iniciarTablero(tablero);
    imprimeTablero(tablero);

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
    int pieza2[1][3][3] = {
        //=====================
        // Orientación unica   
        //   0 0 0
        //   0 1 1
        //   0 1 1
        //=====================
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
    int i;
    int huecos, altura;

    for (i = 0; i<4 ; i++){
        colocarPieza(tablero, pieza1[i], 0, 0);
        printf("\n" "Tablero despues de colocacion" "\n");
        imprimeTablero(tablero);
        huecos = cuentaHuecos
        iniciarTablero(tablero);
    }

    colocarPieza(tablero, pieza2[0], 0, 0);
        printf("\n" "Tablero despues de colocacion" "\n");
        imprimeTablero(tablero);
        iniciarTablero(tablero);

    for (i = 0; i<4 ; i++){
        colocarPieza(tablero, pieza3[i], 0, 0);
        printf("\n" "Tablero despues de colocacion" "\n");
        imprimeTablero(tablero);
        iniciarTablero(tablero);
    }
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
    
    return 0; //Si el tablero esta vacio devuelve altura 0
}

int cuentaHuecos(int tablero[FILAS][COLUMNAS]){
    int i,j;
    int contadorHuecos = 0;

    for (i=0; i<FILAS; i++){
        for (j=0; j<COLUMNAS; j++){
            if(tablero[i][j] == 0){
               contadorHuecos++;
            }
        }
    }
    return contadorHuecos; // Devolvemos el contador de huecos
}






