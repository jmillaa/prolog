/*****************************************************************************

		Copyright (c) My Company

 Project:  TETRISV2
 FileName: TETRISV2.PRO
 Purpose: No description
 Written by: Visual Prolog
 Comments:
******************************************************************************/

include "tetrisv2.inc"

domains
  ancho=integer
  tipo=integer
  centro=integer
  orientacion=integer					/*             X                             */
  postab=integer

  ficha=f(tipo,orientacion,postab)     /* Solo depende de la posicion x XXX  que es la del punto medio las del tipo 0 */

  juego=tipo*			       /* Es la secuencia de fichas a colocar */
  solucion=ficha*		       /* Es la solucion que que se genera para colocar las fichas en el tablero */
  
  filatab=postab*                      /* filatab tiene en el primer elemento la fila y en el resto los elementos de la fila
                                          4 0 0 0 0 0
                                          3 0 0 0 0 0 
                                          2 0 0 1 0 0
                                          1 0 1 1 1 0. El suelo seria [0,1,2,1,0]*/
  suelo=postab*
  tabla=filatab*
  tablero=tab(suelo,tabla)
  contador=integer
  tamanho=integer
  
  
predicates

  vacia(tablero)
  pinta(tablero)
  pintafila(filatab)
  escribelista(filatab)
  
  escribesol(solucion)
  
  backtrack(juego,tablero,solucion,solucion)
  
  regla(tablero,tipo,orientacion,postab,tablero)
  
  mete(ficha,tablero,tablero)
  
  cambia_fila(tabla,suelo,postab,postab,ancho,tabla,suelo)
  
  concatena(suelo,suelo,suelo)
  
  modifica(filatab,suelo,postab,postab,ancho,filatab,suelo)
  
  obtiene_fila(postab,suelo,postab,postab)
  
  extrae_fila(filatab,tabla,postab,postab)
  
  recalcula_suelo(suelo,postab,postab,tabla,suelo)
  
  recorrefila(postab,filatab,suelo,suelo)
  
  mayor(postab,postab,postab)
  
  filallena(filatab)
  
  quitafilas(tabla,postab,postab,tabla)
  
  renumera(tabla,postab,postab,tabla)
  
  anhade(tabla,postab,postab,tabla)
  
  recorta(tabla,postab,suelo,tabla,suelo)
  
  limpia_filas(tabla,suelo,suelo,tabla)  
  
  tetris()

clauses
/* Extrae la Fila dada por el tercer parametro */
     
  extrae_fila(Fila,Tabla,Indice,Indice):-
      Tabla=[H|_],
      Fila=H.
      
  extrae_fila(Fila,[_|T],Cont,Fila_obj):-
      ContN=Cont-1,
      extrae_fila(Fila,T,ContN,Fila_obj).
     
/* El predicado permite obtener la fila de apoyo Numfila, a partir del suelos, con un contador con un limite */     
     
  obtiene_fila(Numfila,[H|_],Contador,Contador):-
     Numfila=H.
  
  obtiene_fila(Numfila,[_|T],Contador_int,Posicion):-
     ContadorN=Contador_int+1,
     obtiene_fila(Numfila,T,ContadorN,Posicion).
     
/* Recalcula el suelo nos dice por donde van los indices del suelo */

/* Ha llegado arriba del todo por lo que el suelo está calculado */     
  recalcula_suelo(Suelo_in,Contador,Limite,_,Suelo_out):-
     Contador<Limite,
     Suelo_out=Suelo_in.
     
  recalcula_suelo(Suelo_in,Contador,Limite,Tabla,Suelo_out):-
     extrae_fila(Fila,Tabla,4,Contador),
     Fila=[Numero|Resto],
     recorrefila(Numero,Resto,Suelo_in,Suelo_int),
     Contadorn=Contador-1,
     recalcula_suelo(Suelo_int,Contadorn,Limite,Tabla,Suelo_out).
     
/* Vamos a recorrer la fila recalculando el suelo */

  recorrefila(_,[],_,[]).
     
/* Vamos iterando si hay un 0 esa posicion de suelo se queda como está */
     
  recorrefila(Numero,[0|Cola],[S|Resto],Suelo_out):-
     recorrefila(Numero,Cola,Resto,Queda),
     Suelo_out=[S|Queda].
     	
/* Cuando hay un 1. El suelo temporalmente es la fila */
     
  recorrefila(Numero,[H|T],[S_in|Resto],Suelo_out):-         
      recorrefila(Numero,T,Resto,Queda),
      H=1,
      mayor(S_in,Numero,S_out),                                 /* Ya esta detectad el suelo por arriba del 1 que se ha encontrado */
      Suelo_out=[S_out|Queda].
      
/* Para cuando el suelo está por encima, necesita un predicado que determine el mayor de dos cantidades */
      
  mayor(A,B,Mayor):-
      A>B,
      Mayor=A.
      
  mayor(_,M,M).
   
/* Determina si una fila esta llena de 1's */
   
  filallena([]).
  
  filallena([1|Cola]):-
  	filallena(Cola).
  	
/* Quita las filas que están llenas de unos */
  
  quitafilas([],Contador_in,Contador_out,Tabla_out):-
     Contador_out=Contador_in,
     Tabla_out=[],!. 
     
  quitafilas([HTabla|TTabla],Contador_in,Contador_out,Tabla_out):- 
     HTabla=[_|Numeros],    
     not(filallena(Numeros)),
     quitafilas(TTabla,Contador_in,Contador_out,Tabla_int),
     Tabla_out=[HTabla|Tabla_int].
     
  quitafilas([H|Tabla_in],Contador_in,Contador_out,Tabla_out):-  /* Es para el caso que la fila de la cabeza está llena de 1's */
     H=[_|Numeros],
     filallena(Numeros),
     Contador_int=Contador_in-1,
     quitafilas(Tabla_in,Contador_int,Contador_out,Tabla_int),
     Tabla_out=Tabla_int.


/* Sirve para renumerar las que han quedado tras eliminar */
     
  renumera(Tabla,Contador,Limite,Tabla):-
     Contador=Limite.
     
  renumera([Fila|Resto],Contador,Limite,Tabla_out):-   
     Contadorn=Contador+1,     
     renumera(Resto,Contadorn,Limite,Tabla_int),
     Fila=[_|TF],
     NuevaFila=4-(Contadorn+1),
     Filan=[NuevaFila|TF],
     Tabla_out=[Filan|Tabla_int].


/* Sirve para añadir tantas filas como haya eliminado */     
  anhade(Tabla_int,Contador,Limite,Tabla_out):-
     Contador>=Limite,
     Tabla_out=Tabla_int.

  anhade(Tabla_in,Contador,Limite,Tabla_out):-
     Contadorn=Contador + 1,
     FILAN=[Contadorn,0,0,0,0,0],
     Tabla_int=[FILAN|Tabla_in],
     anhade(Tabla_int,Contadorn,Limite,Tabla_out).


/*Sirve para limpiar las filas que están llenas de 1's */
  limpia_filas(Tabla_in,_,Suelo_out,Tabla_out):-
     quitafilas(Tabla_in,4,Quedan,Tabla_int),  /* 4 maximo de filas */
     Quedan<4,                  /* Es para el caso de que se haya quitado alguna fila */
     recorta(Tabla_int,Quedan,[0,0,0,0,0],Tabla_out,Suelo_out).

  limpia_filas(Tabla,Suelo,Suelo,Tabla).
  
  recorta(Tabla_entrada,Restantes,Suelo_entrada,Tabla_out,Suelo_out):-
     /* Renumera las que quedan */
     renumera(Tabla_entrada,0,Restantes,Tabla_semi),
     /* Añade las nuevas vacias */
     anhade(Tabla_semi,Restantes,4,Tabla_out),
     recalcula_suelo(Suelo_entrada,4,1,Tabla_out,Suelo_out).

/* A Continuación se generan los predicados que modifican el tablero con filas de un tamaño en una posicion */
     
/* FILAS DE 3 */
  /* Centradas en el 2 */
  modifica([A1,A2,A3,A4,A5],[_,_,_,S4,S5],Fila,2,3,Salida,Suelo_out):-
     A1=0,
     A2=0,
     A3=0,
     S1n=Fila,
     S2n=Fila,
     S3n=Fila,
     Salida=[1,1,1,A4,A5],
     Suelo_out=[S1n,S2n,S3n,S4,S5].

     /* TODO 
        Completar la implementacion de la regla para la columna 3*/


  /* Centradas en el 4 */   
  modifica([A1,A2,A3,A4,A5],[S1,S2,_,_,_],Fila,4,3,Salida,Suelo_out):-
     A3=0,
     A4=0,
     A5=0,
     S3n=Fila,
     S4n=Fila,
     S5n=Fila,
     Salida=[A1,A2,1,1,1],
     Suelo_out=[S1,S2,S3n,S4n,S5n].
     
/* FILAS de 2 */
  /* Centradas en el 1 */
  modifica([A1,A2,A3,A4,A5],[_,_,S3,S4,S5],Fila,1,2,Salida,Suelo_out):-
     A1=0,
     A2=0,
     S1n=Fila,
     S2n=Fila,
     Salida=[1,1,A3,A4,A5],
     Suelo_out=[S1n,S2n,S3,S4,S5].
  

     /* TODO 
        Completar la implementacion de las reglas para varias de las columnas */


     
/* FILAS de 1 */
  /* Centradas en el 1 */
  modifica([A1,A2,A3,A4,A5],[S1,S2,S3,S4,S5],_,1,1,Salida,Suelo_out):-
     A1=0,
     Salida=[1,A2,A3,A4,A5],
     S1n=S1+1,
     Suelo_out=[S1n,S2,S3,S4,S5].
  
  /* Centradas en el 2 */      
  modifica([A1,A2,A3,A4,A5],[S1,S2,S3,S4,S5],_,2,1,Salida,Suelo_out):-
     A2=0,
     Salida=[A1,1,A3,A4,A5],
     S2n=S2+1,
     Suelo_out=[S1,S2n,S3,S4,S5].
     
     /* TODO 
        Completar la implementacion de las reglas para varias de las columnas */



     
/* A PARTIR DE AQUI VIENEN LAS INTRODUCCIONES DE LAS FICHAS */
/*  TIPO   1. LA T invertida*/

/*        X  */
/* Ficha XXX*/
/* Orientacion 0 */     
  mete(f(1,0,Columna),Tablero_in,Tablero_out):-  /*es una T.-->1  con la base horizontal --> 0 centrada en el pivote --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     /* Predicado que determina el nivel del suelo */
     /* afectados(Suelo_in,1,0,Columna,Suelo_partida),*/    /* ANCHO 3*/ /* Suelo_out Son los afectados para colocar una filita de tres */

     /*inserta en la fila x columna y long z*/
     /* Fila se obtiene del suelo_out. Es la fila, elemento de suelo, que está definido en la columna */
     /* CAMBIO obtiene_fila(Fila,Suelo_partida,1,Columna),*/
     Columna>1,Columna<5,
     /* Fila se obtiene del suelo_out*/  
     /* Tiene que analizar 2 columnas: Columna0 --> Fila0 Columna --> Fila1  y Columna2=Columna+1  --> Fila2
        Filan1=Fila1+1 y Filan2=Fila2+1
        y hay que verificar que Filan2<=Filan1+1. 3<=2+1 por ejemplo cabe */
     Columna0=Columna-1,
     Columna1=Columna+1,
     obtiene_fila(Fila0,Suelo_in,1,Columna0),           
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
          
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     Fila0n=Fila0+1,
     
     Fila0n<=Fila1n,
     Fila2n<=Fila1n,
     
     Filan=Fila1n,
     Filan<4,
     
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,3,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna,1,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).

/*       X  */
/*       XX */
/* Ficha X  */
/* Orientacion 1 */     
mete(f(1,1,Columna),Tablero_in,Tablero_out):-  /*es una T.-->1  con la base horizontal --> 0 centrada en el pivote --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     /* Predicado que determina el nivel del suelo */
     /* afectados(Suelo_in,1,1,Columna,Suelo_partida), NO ESTABA DEFINIDO */    /* ANCHO 1*/ /* Suelo_out Son los afectados para colocar una fila de 1, 1 de 2 y 1 de 1 */
   
     /*inserta en la fila x columna y long z*/
     Columna>1,Columna<=5,

     /* Fila se obtiene del suelo_out*/  
     /* Tiene que analizar 2 columnas: Columna --> Fila1  y Columna2=Columna+1  --> Fila2
        Filan1=Fila1+1 y Filan2=Fila2+1
        y hay que verificar que Filan2<=Filan1+1. 3<=2+1 por ejemplo cabe */ 
     Columna1=Columna+1,       
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
          
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     
     Fila2n<=Fila1n+1,
     
     Filan=Fila1n,
     Filan<3,
     
     /* */
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,1,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna,2,Tabla_int2,Suelo_int2),
     Fila3=Fila22+1,
     cambia_fila(Tabla_int2,Suelo_int2,Fila3,Columna,1,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).

/*       XXX  */
/* Ficha  X */
/* Orientacion 2 */     
  mete(f(1,2,Columna),Tablero_in,Tablero_out):-  /*es una T.-->1  con la base horizontal --> 0 centrada en la columna --> 3*/


     /* TODO 
        Completar la implementacion de la regla */



/*        X  */
/*       XX  */
/* Ficha  X  */
/* Orientacion 3 */     
mete(f(1,3,Columna),Tablero_in,Tablero_out):-  /*es una T.-->1  con la base horizontal --> 0 centrada en pivote --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     /* Predicado que determina el nivel del suelo */

     /* TODO 
        Completar la implementacion de la regla */



/*  TIPO   2. CUADRADO */     
/*               */
/*       XX      */
/* Ficha XX     */
/* Orientacion CUalquiera*/     
mete(f(2,_,Columna),Tablero_in,Tablero_out):-  /*es un cuadrado.-->1  con la base horizontal --> 0 centrada en la esquina izqd --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     /* Predicado que determina el nivel del suelo */
     /* afectados(Suelo_in,2,_,Columna,Suelo_partida), NO ESTABA DEFINIDO */   /* ANCHO 1*/ /* Suelo_out Son los afectados para colocar una fila de 1, 1 de 2 y 1 de 1 */
     Columna>=1,Columna<5,

     /*inserta en la fila x columna y long z*/
     
          /* Fila se obtiene del suelo_out*/  
     /* Tiene que analizar 2 columnas: Columna --> Fila1  y Columna2=Columna+1  --> Fila2
        Filan1=Fila1+1 y Filan2=Fila2+1
        y hay que verificar que Filan2<=Filan1. 3<=2+1 por ejemplo cabe */ 
     Columna1=Columna+1,       
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
          
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     
     Fila2n<=Fila1n,
     
     Filan=Fila1n,
     Filan<4,

     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,2,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna,2,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).

/*TIPO 3. ELE  */
/*             */
/*         X   */
/* Ficha XXX   */    
mete(f(3,0,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 0 centrada en la mitad de Largo --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     /* Predicado que determina el nivel del suelo */
     /* afectados(Suelo_in,3,0,Columna,Suelo_partida),  NO ESTABA DEFINIDO*/  /* ANCHO 1*/ /* Suelo_out Son los afectados para colocar una fila de 3, y 1 de 1 */
     Columna>1,Columna<5,
     /* Fila se obtiene del suelo_out*/  
     /* Tiene que analizar 2 columnas: Columna0 --> Fila0 Columna --> Fila1  y Columna2=Columna+1  --> Fila2
        Filan1=Fila1+1 y Filan2=Fila2+1
        y hay que verificar que Filan2<=Filan1+1. 3<=2+1 por ejemplo cabe */
     Columna0=Columna-1,
     Columna1=Columna+1,
     obtiene_fila(Fila0,Suelo_in,1,Columna0),           
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
          
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     Fila0n=Fila0+1,
     
     Fila0n<=Fila1n,
     Fila2n<=Fila1n,
     
     Filan=Fila1n,
     Filan<4,

     /* inserta en la fila x columna y long z*/
     /* Fila se obtiene del suelo_out*/
     obtiene_fila(Fila,Suelo_in,1,Columna),
     Filan=Fila+1,Filan<4,
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,3,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     Columnan=Columna+1,

     /* TODO 
        Completar la implementacion de la regla */


     
/*FICHA ELE    */
/*       X     */
/*       X     */
/* Ficha XX    */     
mete(f(3,1,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 1 centrada en la columna --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     /* Predicado que determina el nivel del suelo */
     /* afectados(Suelo_in,3,1,Columna,Suelo_partida), NO ESTABA DEFINIDO*/   /* ANCHO 1*/ /* Suelo_out Son los afectados para colocar una fila de 3, y 1 de 1 */
     Columna>=1,Columna<5,
          /* Fila se obtiene del suelo_out*/  
     /* Tiene que analizar 2 columnas: Columna --> Fila1  y Columna2=Columna+1  --> Fila2
        Filan1=Fila1+1 y Filan2=Fila2+1
        y hay que verificar que Filan2<=Filan1. 3<=2+1 por ejemplo cabe */
     Columna1=Columna+1,        
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
          
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     
     Fila2n<=Fila1n,
     
     Filan=Fila1n,
     Filan<3,

     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,2,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna,1,Tabla_preint,Suelo_preint),
     Fila3=Fila22+1,
     cambia_fila(Tabla_preint,Suelo_preint,Fila3,Columna,1,Tabla_preout,Suelo_preout),

     /* TODO 
        Completar la implementacion de la regla */


     
/*FICHA ELE    */
/*             */
/*       XXX   */
/* Ficha X     */     
mete(f(3,2,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 1 centrada en la columna --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     /* Predicado que determina el nivel del suelo */
     /* afectados(Suelo_in,3,2,Columna,Suelo_partida), NO ESTABA DEFINIDO*/   /* ANCHO 1*/ /* Suelo_out Son los afectados para colocar una fila de 3, y 1 de 1 */
     Columna>1,Columna<5,
     /* Fila se obtiene del suelo_out*/  
     /* Tiene que analizar 2 columnas: Columna0 --> Fila0 Columna --> Fila1  y Columna2=Columna+1  --> Fila2
        Filan1=Fila1+1 y Filan2=Fila2+1
        y hay que verificar que Filan2<=Filan1+1. 3<=2+1 por ejemplo cabe */
     Columna0=Columna-1,
     Columna1=Columna+1,
     obtiene_fila(Fila0,Suelo_in,1,Columna0),           
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
          
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     Fila0n=Fila0+1,
     
     Fila1n<=Fila0n+1,
     Fila2n<=Fila0n+1,
     
     /* TODO 
     Completar la implementacion de la regla */



/*FICHA ELE   */
/*       XX   */
/*        X   */
/* Ficha  X   */
/* Orientacion CUalquiera*/     
mete(f(3,3,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 1 centrada en la columna --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     /* Predicado que determina el nivel del suelo */
     /* afectados(Suelo_in,3,3,Columna,Suelo_partida), NO ESTABA DEFINIDO*/   /* ANCHO 1*/ /* Suelo_out Son los afectados para colocar una fila de 3, y 1 de 1 */
     Columna>1,Columna<=5,
     /*inserta en la fila x columna y long z*/

     /* Fila se obtiene del suelo_out*/  
     /* Tiene que analizar 2 columnas: Columna --> Fila1  y Columna2=Columna-1  --> Fila2
        Filan1=Fila1+1 y Filan2=Fila2+1
        y hay que verificar que Filan2<=Filan1+1. 3<=2+1 por ejemplo cabe */  
     Columna0=Columna-1,      
     obtiene_fila(Fila1,Suelo_in,1,Columna0),
     obtiene_fila(Fila2,Suelo_in,1,Columna),

     /* TODO 
        Completar la implementacion de la regla */
        
        
        
/*FICHA ELE_INV*/
/*             */
/*       X     */
/* Ficha XXX   */     
mete(f(4,0,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 0 centrada en la mitad palo largo --> 3*/

/* En esta zona faltan todas las reglas de la implementación de este tipo de ficha. Serían las cuatro orientaciones */

     
/*  FIN DE LAS FICHAS  */
     
  cambia_fila([],S,_,_,_,[],S).
  
  cambia_fila([H|T],Suelo_in,Fila,Columna,Ancho,Tabla_out,Suelo_out):-
     H=[FilaH|Resto],
     Fila=FilaH,
/*     write(Fila,'\t',FilaH,'\t',Columna,'\t',Ancho,'\n'),*/
     modifica(Resto,Suelo_in,Fila,Columna,Ancho,Resto_out,Suelo_out),
     H_out=[FilaH|Resto_out],
     Tabla_out=[H_out|T].
     
  cambia_fila([H|T],Suelo_in,Fila,Columna,Ancho,Tabla_out,Suelo_out):-
     /*NO es esta fila */ /*No se producen cambios en el Suelo*/
     cambia_fila(T,Suelo_in,Fila,Columna,Ancho,Tabla_int,Suelo_out),
     Tabla_out=[H|Tabla_int].
     
/* Predicados de inicialización e impresion de resultados */
     
  vacia(Tablero):-     
     Suelo=[0,0,0,0,0],
     Filastab=[[4, 0, 0, 0, 0, 0],
               [3, 0, 0, 0, 0, 0],
               [2, 0, 0, 0, 0, 0],
               [1, 0, 0, 0, 0, 0]],
     Tablero=tab(Suelo,Filastab).
     
  pinta(tab(_,[])).
     
  pinta(tab(Suelo,Tablero)):-
     Tablero=[H|T],
     pintafila(H),
     write('\n'),
     pinta(tab(Suelo,T)).
     
  escribelista([]).
  
  escribelista([H|T]):-
  	write(H,'\t'),
  	escribelista(T).
     
  pintafila([H|T]):-
     write("Fila: ",H,'\t'),
     escribelista(T).

/* Predicado para describir las soluciones de como se colocan las fichas */     
  escribesol([]).
  
  escribesol([H|T]):-
     escribesol(T),
     write(H,'\n').
     
/* Empiezan las reglas de colocacion */
/* Columna 1*/ 
  regla(Tab_in,Ficha,0,1,Tab_int):-  /*Está claro es el tablero, el tipo de ficha, su orientación, la columna y el resultado intermedio */
     mete(f(Ficha,0,1),Tab_in,Tab_int).

  regla(Tab_in,Ficha,1,1,Tab_int):-
     mete(f(Ficha,1,1),Tab_in,Tab_int).
  /* TODO TODO TODO */
/* Columna 2*/
  regla(Tab_in,Ficha,0,2,Tab_int):-
     mete(f(Ficha,0,2),Tab_in,Tab_int).

  /* TODO TODO TODO */

/* Columna 3*/
  regla(Tab_in,Ficha,0,3,Tab_int):-
     mete(f(Ficha,0,3),Tab_in,Tab_int).
  /* TODO TODO TODO */
  /* Faltan columnas!*/


/*     
  regla(Tab_in,Ficha,_,_,_):-
    write("Backtrack....",'\t'),write("Ficha: ",'\t'),write(Ficha,'\n'),pinta(Tab_in),write('\n'),fail.
*/
/* Código de backtrack */

  backtrack([],Tablero,Solucion,Solucion):-
     pinta(Tablero),
     escribesol(Solucion).
     
/* TODO 

  Es evidente que se necesita implementar la parte recursiva */

  tetris():-
  
     vacia(T),
     backtrack([1,2,3,3],T,[],Solucion_Final),
     write(Solucion_Final,'\n').
    
     

goal

  tetris().
