#include <stdio.h>
#include <stdlib.h>

//Constantes
#define FILAS 4
#define COLUMNAS 5

//Prototipos de la funcion
void iniciarTablero(int tablero[FILAS][COLUMNAS]);
void imprimeTablero(int tablero[FILAS][COLUMNAS]);
void colocarPieza(int tablero[FILAS][COLUMNAS], int pieza[3][3], int fila, int columna);


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
        //  1 1 0
        //=====================
        {{0, 1, 0}, {0, 1, 1}, {0, 1, 0}}, 
        //=====================
        // Orientación 2    
        //  0 1 0
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

    colocarPieza(tablero, pieza1[0], 1, 2);
    printf("\n" "Tablero despues de colocacion" "\n");
    imprimeTablero(tablero);


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
    int i, j;

    for (i=0; i<3; i++){
        for (j=0; j<3; j++){
            if (pieza[i][j] == 1){
                tablero[fila+i][columna+j] = 1;
            }
        }
    }
}




