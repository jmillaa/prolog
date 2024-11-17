/*****************************************************************************

		Copyright (c) My Company

 Project:  TETRISV2
 FileName: TETRISV2.PRO
 Purpose: No description
 Written by: Visual Prolog
 Comments:
******************************************************************************/

include "tetrisv2.inc"

/***********************************************
            DOMINIOS 
************************************************/

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

  probar_orientaciones(integer, tablero, integer, list, list, list)

  probar_columnas(integer, tablero, integer, integer, list, list, list)
  
  backtrack(juego,tablero,solucion,solucion)
  
  regla(tablero,tipo,orientacion,postab,tablero)
  
  mete(ficha,tablero,tablero)
  
  cambia_fila(tabla,suelo,postab,postab,ancho,tabla,suelo)
  
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

/* Ha llegado arriba del todo por lo que el suelo est� calculado */     
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
     
/* Vamos iterando si hay un 0 esa posicion de suelo se queda como esta */
     
  recorrefila(Numero,[0|Cola],[S|Resto],Suelo_out):-
     recorrefila(Numero,Cola,Resto,Queda),
     Suelo_out=[S|Queda].
     	
/* Cuando hay un 1. El suelo temporalmente es la fila */
     
  recorrefila(Numero,[H|T],[S_in|Resto],Suelo_out):-         
      recorrefila(Numero,T,Resto,Queda),
      H=1,
      mayor(S_in,Numero,S_out),                                 /* Ya esta detectad el suelo por arriba del 1 que se ha encontrado */
      Suelo_out=[S_out|Queda].
      
/* Para cuando el suelo est� por encima, necesita un predicado que determine el mayor de dos cantidades */
      
  mayor(A,B,Mayor):-
      A>B,
      Mayor=A.
      
  mayor(_,M,M).
   
/* Determina si una fila esta llena de 1's */
   
  filallena([]).
  
  filallena([1|Cola]):-
  	filallena(Cola).
  	
/* Quita las filas que est�n llenas de unos */
  
  quitafilas([],Contador_in,Contador_out,Tabla_out):-
     Contador_out=Contador_in,
     Tabla_out=[],!. 
     
  quitafilas([HTabla|TTabla],Contador_in,Contador_out,Tabla_out):- 
     HTabla=[_|Numeros],    
     not(filallena(Numeros)),
     quitafilas(TTabla,Contador_in,Contador_out,Tabla_int),
     Tabla_out=[HTabla|Tabla_int].
     
  quitafilas([H|Tabla_in],Contador_in,Contador_out,Tabla_out):-  /* Es para el caso que la fila de la cabeza est� llena de 1's */
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


/* Sirve para a�adir tantas filas como haya eliminado */     
  anhade(Tabla_int,Contador,Limite,Tabla_out):-
     Contador>=Limite,
     Tabla_out=Tabla_int.

  anhade(Tabla_in,Contador,Limite,Tabla_out):-
     Contadorn=Contador + 1,
     FILAN=[Contadorn,0,0,0,0,0],
     Tabla_int=[FILAN|Tabla_in],
     anhade(Tabla_int,Contadorn,Limite,Tabla_out).


/*Sirve para limpiar las filas que est�n llenas de 1's */
  limpia_filas(Tabla_in,_,Suelo_out,Tabla_out):-
     quitafilas(Tabla_in,4,Quedan,Tabla_int),  /* 4 maximo de filas */
     Quedan<4,                  /* Es para el caso de que se haya quitado alguna fila */
     recorta(Tabla_int,Quedan,[0,0,0,0,0],Tabla_out,Suelo_out).

  limpia_filas(Tabla,Suelo,Suelo,Tabla).
  
  recorta(Tabla_entrada,Restantes,Suelo_entrada,Tabla_out,Suelo_out):-
     /* Renumera las que quedan */
     renumera(Tabla_entrada,0,Restantes,Tabla_semi),
     /* A�ade las nuevas vacias */
     anhade(Tabla_semi,Restantes,4,Tabla_out),
     recalcula_suelo(Suelo_entrada,4,1,Tabla_out,Suelo_out).

/* A Continuaci�n se generan los predicados que modifican el tablero con filas de un tama�o en una posicion */
     
/* FILAS DE 3 */
  /* Centradas en la columna 2 */
  modifica([A1,A2,A3,A4,A5],[_,_,_,S4,S5],Fila,2,3,Salida,Suelo_out):-
     A1=0,
     A2=0,
     A3=0,
     S1n=Fila,
     S2n=Fila,
     S3n=Fila,
     Salida=[1,1,1,A4,A5],
     Suelo_out=[S1n,S2n,S3n,S4,S5].

     /* Centradas en la columna 3*/ %(Hecho)
   modifica([A1,A2,A3,A4,A5],[S1,_,_,_,S5],Fila,3,3,Salida,Suelo_out):-
      A2=0,
      A3=0,
      A4=0,
      S2n=Fila,
      S3n=Fila,
      S4n=Fila,
      Salida=[A1,1,1,1,A5],
      Suelo_out=[S1,S2n,S3n,S4n,S5].

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
     
/* FILAS de 2 */ %(Hecho)
  /* Centradas en la columna 1 */
  modifica([A1,A2,A3,A4,A5],[_,_,S3,S4,S5],Fila,1,2,Salida,Suelo_out):-
     A1=0,
     A2=0,
     S1n=Fila,
     S2n=Fila,
     Salida=[1,1,A3,A4,A5],
     Suelo_out=[S1n,S2n,S3,S4,S5].
  

   /* Centradas en la columna 2 */
  modifica([A1,A2,A3,A4,A5],[S1,_,_,S4,S5],Fila,2,2,Salida,Suelo_out):-
     A2=0,
     A3=0,
     S2n=Fila,
     S3n=Fila,
     Salida=[A1,1,1,A4,A5],
     Suelo_out=[S1,S2n,S3n,S4,S5].

   /* Centradas en la columna 3 */
  modifica([A1,A2,A3,A4,A5],[S1,S2,_,_,S5],Fila,3,2,Salida,Suelo_out):-
     A3=0,
     A4=0,
     S3n=Fila,
     S4n=Fila,
     Salida=[A1,A2,1,1,A5],
     Suelo_out=[S1,S2,S3n,S4n,S5].

      /* Centradas en la columna 4 */
  modifica([A1,A2,A3,A4,A5],[S1,S2,S3,_,_],Fila,4,2,Salida,Suelo_out):-
     A4=0,
     A5=0,
     S4n=Fila,
     S5n=Fila,
     Salida=[A1,A2,A3,1,1],
     Suelo_out=[S1,S2,S3,S4n,S5n].

     
/* FILAS de 1 */ %(Hecho)
  /* Centradas en la columna 1 */
  modifica([A1,A2,A3,A4,A5],[S1,S2,S3,S4,S5],_,1,1,Salida,Suelo_out):-
     A1=0,
     Salida=[1,A2,A3,A4,A5],
     S1n=S1+1,
     Suelo_out=[S1n,S2,S3,S4,S5].
  
  /* Centradas en la columna 2 */      
  modifica([A1,A2,A3,A4,A5],[S1,S2,S3,S4,S5],_,2,1,Salida,Suelo_out):-
     A2=0,
     Salida=[A1,1,A3,A4,A5],
     S2n=S2+1,
     Suelo_out=[S1,S2n,S3,S4,S5].

   /* Centradas en la columna 3 */      
  modifica([A1,A2,A3,A4,A5],[S1,S2,S3,S4,S5],_,3,1,Salida,Suelo_out):-
     A3=0,
     Salida=[A1,A2,1,A4,A5],
     S3n=S3+1,
     Suelo_out=[S1,S2,S3n,S4,S5].
     
   /* Centradas en la columna 4 */      
  modifica([A1,A2,A3,A4,A5],[S1,S2,S3,S4,S5],_,4,1,Salida,Suelo_out):-
     A4=0,
     Salida=[A1,A2,A3,1,A5],
     S4n=S4+1,
     Suelo_out=[S1,S2,S3,S4n,S5].

   /* Centradas en la columna 5 */      
  modifica([A1,A2,A3,A4,A5],[S1,S2,S3,S4,S5],_,5,1,Salida,Suelo_out):-
     A5=0,
     Salida=[A1,A2,A3,A4,1],
     S5n=S5+1,
     Suelo_out=[S1,S2,S3,S4,S5n].
     

     
/* A PARTIR DE AQUI VIENEN LAS INTRODUCCIONES DE LAS FICHAS */
/*  TIPO   1. LA T invertida*/

/*        X  */
/* Ficha XXX*/
/* Orientacion 0 */     
  mete(f(1, 0, Columna), Tablero_in, Tablero_out) :-
    Tablero_in = tab(Suelo_in, Tabla_in),

    % Verifica que la columna está en un rango válido para esta ficha (2, 3, o 4).
    Columna > 1, Columna < 5,

    % Define las columnas adyacentes a la columna central.
    Columna0 = Columna - 1,  % Columna a la izquierda
    Columna1 = Columna + 1,  % Columna a la derecha

    % Obtiene las filas actuales del suelo en cada una de estas columnas.
    obtiene_fila(Fila0, Suelo_in, 1, Columna0),           
    obtiene_fila(Fila1, Suelo_in, 1, Columna),
    obtiene_fila(Fila2, Suelo_in, 1, Columna1),

    % Calcula la fila donde se colocará la base de la ficha (fila más alta de las 3 columnas).
    Fila0n = Fila0 + 1,
    Fila1n = Fila1 + 1,
    Fila2n = Fila2 + 1,
    Fila0n <= Fila1n,
    Fila2n <= Fila1n,
    Filan = Fila1n,

    % Asegura que la ficha no se coloque en una fila superior a la máxima (ej., 4 en este caso).
    Filan < 4,

    % Inserta la base horizontal de la ficha "XXX" en la fila `Filan`, centrada en `Columna`.
    cambia_fila(Tabla_in, Suelo_in, Filan, Columna, 3, Tabla_int, Suelo_int),

    % Inserta el bloque superior "X" en la fila inmediatamente arriba (`Filan + 1`), en la columna central.
    Fila22 = Filan + 1,
    cambia_fila(Tabla_int, Suelo_int, Fila22, Columna, 1, Tabla_preout, Suelo_preout),

    % Limpia filas completas y actualiza el suelo después de la colocación.
    limpia_filas(Tabla_preout, Suelo_preout, Suelo_out, Tabla_out),
    Tablero_out = tab(Suelo_out, Tabla_out).

/*       XXX  */
/* Ficha  X */
/* Orientacion 2 */     
 mete(f(1,2,Columna), Tablero_in, Tablero_out) :-  /* es una T. --> 1  con la base horizontal --> 0 centrada en la columna --> 3 */
   % Metemos en Tablero_in el estado del suelo y la tabla actual 
   Tablero_in = tab(Suelo_in, Tabla_in),
   
   % Verificamos que la pieza entra dentro de los limites del tablero 
   Columna > 1, Columna < 5,

   % Definimos los extremos de la T en las columnas del tablon Columna0 Columna1 Columna2
   Columna0 = Columna - 1,
   Columna2 = Columna + 1,

   % Calculamos la altura de cada fila de las columnas 
   obtiene_fila(Fila0, Suelo_in, 1, Columna0),
   obtiene_fila(Fila1, Suelo_in, 1, Columna),
   obtiene_fila(Fila2, Suelo_in, 1, Columna2),

   % La pieza se va a colocar en una altura mas de la fila 
   Fila0n = Fila0 + 1,
   Fila1n = Fila1 + 1,
   Fila2n = Fila2 + 1,

   % Comprobamos que Fila1n es la más baja, y que Fila0n y Fila2n no son más de 1 unidad más altos que Fila1n.
   Fila1n < Fila0n,
   Fila1n < Fila2n,
   Fila0n <= Fila1n + 1,
   Fila2n <= Fila1n + 1,

   % En el caso de que las comprobaciones anteriores sean verdaderas se asigna Filan = Fila1n
   Filan = Fila1n,

   % Nos aseguramos de que la ficha no se coloque fuera del limite del tablero
   Filan < 4,

   % Insertamos la base de la T
   % Inserta la base vertical de la ficha "X" en la fila `Filan`, centrada en `Columna`.
   cambia_fila(Tabla_in, Suelo_in, Filan, Columna, 1, Tabla_int, Suelo_int),

   % Aumentamos la altura de la fila para insertar el resto de la figura
   FilanSig = Filan + 1,
   cambia_fila(Tabla_int, Suelo_int, FilanSig, Columna, 1, Tabla_preout, Suelo_preout),

   % Limpia filas completas y actualiza el suelo después de la colocación.
   limpia_filas(Tabla_preout, Suelo_preout, Suelo_out, Tabla_out),
   Tablero_out = tab(Suelo_out, Tabla_out).



/*       X  */
/*       XX */
/* Ficha X  */
/* Orientacion 1 */     
mete(f(1,1,Columna),Tablero_in,Tablero_out):-  /*es una T.-->1  con la base horizontal --> 0 centrada en el pivote --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
    
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

/*        X  */
/*       XX  */
/* Ficha  X  */
/* Orientacion 3 */     
mete(f(1,3,Columna),Tablero_in,Tablero_out):-  /*es una T.-->1  con la base horizontal --> 0 centrada en pivote --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
   
     Columna>1,Columna<=5,
     Columna1=Columna-1,       
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
          
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     
     Fila2n<=Fila1n+1,
     
     Filan=Fila1n,
     Filan<3,
     
     
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,1,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna1,2,Tabla_int2,Suelo_int2),
     Fila3=Fila22+1,
     cambia_fila(Tabla_int2,Suelo_int2,Fila3,Columna,1,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).



/*  TIPO   2. CUADRADO */     
/*               */
/*       XX      */
/* Ficha XX     */
/* Orientacion CUalquiera*/     
mete(f(2,_,Columna),Tablero_in,Tablero_out):-  /*es un cuadrado.-->1  con la base horizontal --> 0 centrada en la esquina izqd --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     %Validamos limites
     Columna>=1,Columna<5,
     %Calculamos la segunda columna afectada
     Columna1=Columna+1,       
     %Obtenemos alturas del suelo
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),

      %Modificamos las alturas para insertar          
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     
     
     %Verificamos que la altura de la columnna adyacente no sea superior que la de la base donde va a ir apoyada la pieza
     Fila2n<=Fila1n,
     
     %Asignamos la altura de la fila donde se va a insertar
     Filan=Fila1n,

     %Comprobamos el limite superior del tablero
     Filan<4,

     %Hacemos la insercion
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
     %Comprobamos limites 
     Columna>1,Columna<5,

     %Asignamos las columnas invliucradas en la pieza
     Columna0=Columna-1,
     Columna1=Columna+1,

     %Obtenemos las alturas
     obtiene_fila(Fila0,Suelo_in,1,Columna0),           
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
          
     %Cambiamos las alturas para introducir la pieza
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     Fila0n=Fila0+1,
     
     %Comprobamos si se puede meter o no
     Fila0n<=Fila1n,
     Fila2n<=Fila1n,
     %Asignamos la altura
     Filan=Fila1n,
     %Comprobamos limite de altura
     Filan<4,

     %Vamos con la insercion 
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,3,Tabla_int,Suelo_int),
     FilanSig = Filan + 1,
     cambia_fila(Tabla_int,Suelo_int,FilanSig,Columna1,1,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).

     
/*FICHA ELE    */
/*       X     */
/*       X     */
/* Ficha XX    */     
mete(f(3,1,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 1 centrada en la columna --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),

     %Calculamos los limites laterales
     Columna>=1,Columna<5,

     %Columna colindante
     Columna1=Columna+1,        
     
     %Obtenemos las alturas del suelo
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
     
     %Aumentamos en 1 las alturas de insercion
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     
     %Hacemos las comprobaciones
     Fila2n<=Fila1n,
     
     %Asignamos
     Filan=Fila1n,
     %Comprobacion de altura
     Filan<3,
     
     %Hacemos la insercion
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,2,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna,1,Tabla_preint,Suelo_preint),
     Fila3=Fila22+1,
     cambia_fila(Tabla_preint,Suelo_preint,Fila3,Columna,1,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).


/*FICHA ELE    */
/*             */
/*       XXX   */
/* Ficha X     */     
mete(f(3,2,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 1 centrada en la columna --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),

     %Comprobamos los limites de pista
     Columna>1,Columna<5,

     % Asiganmos las columnas colindantes
     Columna0=Columna-1,
     Columna1=Columna+1,

     %Obtenemos las alturas de las filas del suelo
     obtiene_fila(Fila0,Suelo_in,1,Columna0),           
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
     
     %Asignamos las nuevas alturas de insercion
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     Fila0n=Fila0+1,
     
     %Verificamos
     Fila1n<=Fila0n+1,
     Fila2n<=Fila0n+1,

     %Asignamos la altura
     Filan=Fila1n,
     %Comprobamos limite de altura
     Filan<4,

     %realizamos la insercion en el tablero
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna0,1,Tabla_int,Suelo_int),
     FilanSig = Filan + 1,
     cambia_fila(Tabla_int,Suelo_int,FilanSig,Columna0,3,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).



/*FICHA ELE   */
/*       XX   */
/*        X   */
/* Ficha  X   */
/* Orientacion CUalquiera*/     
mete(f(3,3,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 1 centrada en la columna --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     %calculamos los limites
     Columna>1,
     Columna<=5,
     %Asignamos la columna colindante
     Columna0=Columna-1,      
     %Sacamos las alturas del suelo
     obtiene_fila(Fila1,Suelo_in,1,Columna0),
     obtiene_fila(Fila2,Suelo_in,1,Columna),

     %Aumentamos las alturas en 1 para la insecion
     Fila1n = Fila1 + 1,
     Fila2n = Fila2 + 1,

     %Verificamos que quepa la pieza

     Fila1n >= Fila2n + 2,

     Filan = Fila2n,

     %Insertamos en el tablero
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,1,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna,1,Tabla_preint,Suelo_preint),
     Fila3=Fila22+1,
     cambia_fila(Tabla_preint,Suelo_preint,Fila3,Columna0,2,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).
        
        
        
/*FICHA ELE_INV*/
/*             */
/*       X     */
/* Ficha XXX   */   
% Orientacion 0  
mete(f(4,0,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 0 centrada en la mitad palo largo --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),
     %Comprobamos limites 
     Columna>1,Columna<5,

     %Asignamos las columnas invliucradas en la pieza
     Columna0=Columna-1,
     Columna1=Columna+1,

     %Obtenemos las alturas
     obtiene_fila(Fila0,Suelo_in,1,Columna0),           
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
         
     %Cambiamos las alturas para introducir la pieza
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     Fila0n=Fila0+1,
   
     %Comprobamos si se puede meter o no
     Fila0n<=Fila1n,
     Fila2n<=Fila1n,
     %Asignamos la altura
     Filan=Fila1n,
     %Comprobamos limite de altura
     Filan<4,

     %Vamos con la insercion 
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna0,3,Tabla_int,Suelo_int),
     FilanSig = Filan + 1,
     cambia_fila(Tabla_int,Suelo_int,FilanSig,Columna0,1,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).

     /*FICHA ELE_INV*/
     /*             */
     /* Ficha   X X */
     /*         X   */   
     /*         X   */
     % Orientacion 1  
mete(f(4,1,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 0 centrada en la mitad palo largo --> 3*/
    Tablero_in=tab(Suelo_in,Tabla_in),

     %Calculamos los limites laterales
     Columna>=1,Columna<5,

     %Columna colindante
     Columna1=Columna+1,        
     
     %Obtenemos las alturas del suelo
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
     
     %Aumentamos en 1 las alturas de insercion
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     
     %Hacemos las comprobaciones
     Fila2n >= Fila1n + 2,
     
     %Asignamos
     Filan=Fila1n,
     %Comprobacion de altura
     Filan<3,
     
     %Hacemos la insercion
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna,1,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna,1,Tabla_preint,Suelo_preint),
     Fila3=Fila22+1,
     cambia_fila(Tabla_preint,Suelo_preint,Fila3,Columna,2,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).

     /*FICHA ELE_INV    */
     /*                 */
     /* Ficha   X X X   */
     /*             X   */   
     /*                 */
     % Orientacion 2
mete(f(4,2,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 0 centrada en la mitad palo largo --> 3*/
  
    Tablero_in=tab(Suelo_in,Tabla_in),
     %Comprobamos limites 
     Columna>1,Columna<5,

     %Asignamos las columnas invliucradas en la pieza
     Columna0=Columna-1,
     Columna1=Columna+1,

     %Obtenemos las alturas
     obtiene_fila(Fila0,Suelo_in,1,Columna0),           
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
         
     %Cambiamos las alturas para introducir la pieza
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     Fila0n=Fila0+1,
   
     %Comprobamos si se puede meter o no
     Fila1n<=Fila2n+1,
     Fila0n<=Fila2n+1,
     %Asignamos la altura
     Filan=Fila1n,
     %Comprobamos limite de altura
     Filan<4,

     %Vamos con la insercion 
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna1,1,Tabla_int,Suelo_int),
     FilanSig = Filan + 1,
     cambia_fila(Tabla_int,Suelo_int,FilanSig,Columna0,3,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).

   /*FICHA ELE      */
   /*           X     */
   /*           X     */
   /* Ficha   X X    */     
   %Orientacion 3
mete(f(4,3,Columna),Tablero_in,Tablero_out):-  /*es una L.-->1  con la base horizontal --> 1 centrada en la columna --> 3*/
     Tablero_in=tab(Suelo_in,Tabla_in),

     %Calculamos los limites laterales
     Columna>1,Columna<=5,

     %Columna colindante
     Columna1=Columna-1,        
     
     %Obtenemos las alturas del suelo
     obtiene_fila(Fila1,Suelo_in,1,Columna),
     obtiene_fila(Fila2,Suelo_in,1,Columna1),
     
     %Aumentamos en 1 las alturas de insercion
     Fila2n=Fila2+1,
     Fila1n=Fila1+1,
     
     %Hacemos las comprobaciones
     Fila1n<=Fila2n,
     
     %Asignamos
     Filan=Fila1n,
     %Comprobacion de altura
     Filan<3,
     
     %Hacemos la insercion
     cambia_fila(Tabla_in,Suelo_in,Filan,Columna1,2,Tabla_int,Suelo_int),
     Fila22=Filan+1,
     cambia_fila(Tabla_int,Suelo_int,Fila22,Columna,1,Tabla_preint,Suelo_preint),
     Fila3=Fila22+1,
     cambia_fila(Tabla_preint,Suelo_preint,Fila3,Columna,1,Tabla_preout,Suelo_preout),
     limpia_filas(Tabla_preout,Suelo_preout,Suelo_out,Tabla_out),
     Tablero_out=tab(Suelo_out,Tabla_out).


     
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
     
/* Predicados de inicializaci�n e impresion de resultados */
     
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
  regla(Tab_in,Ficha,0,1,Tab_int):-  /*Est� claro es el tablero, el tipo de ficha, su orientaci�n, la columna y el resultado intermedio */
     mete(f(Ficha,0,1),Tab_in,Tab_int).

  regla(Tab_in,Ficha,1,1,Tab_int):-
     mete(f(Ficha,1,1),Tab_in,Tab_int).
   
  regla(Tab_in,Ficha,2,1,Tab_int):-
     mete(f(Ficha,2,1),Tab_in,Tab_int).

  regla(Tab_in,Ficha,3,1,Tab_int):-
     mete(f(Ficha,3,1),Tab_in,Tab_int).

  
/* Columna 2*/ 
  regla(Tab_in,Ficha,0,2,Tab_int):-  /*Est� claro es el tablero, el tipo de ficha, su orientaci�n, la columna y el resultado intermedio */
     mete(f(Ficha,0,2),Tab_in,Tab_int).

  regla(Tab_in,Ficha,1,2,Tab_int):-
     mete(f(Ficha,1,2),Tab_in,Tab_int).
   
  regla(Tab_in,Ficha,2,2,Tab_int):-
     mete(f(Ficha,2,2),Tab_in,Tab_int).

  regla(Tab_in,Ficha,3,2,Tab_int):-
     mete(f(Ficha,3,2),Tab_in,Tab_int).

/* Columna 3*/ 
  regla(Tab_in,Ficha,0,3,Tab_int):-  /*Est� claro es el tablero, el tipo de ficha, su orientaci�n, la columna y el resultado intermedio */
     mete(f(Ficha,0,3),Tab_in,Tab_int).

  regla(Tab_in,Ficha,1,3,Tab_int):-
     mete(f(Ficha,1,3),Tab_in,Tab_int).
   
  regla(Tab_in,Ficha,2,3,Tab_int):-
     mete(f(Ficha,2,3),Tab_in,Tab_int).

  regla(Tab_in,Ficha,3,3,Tab_int):-
     mete(f(Ficha,3,3),Tab_in,Tab_int).

/* Columna 4*/ 
  regla(Tab_in,Ficha,0,4,Tab_int):-  /*Est� claro es el tablero, el tipo de ficha, su orientaci�n, la columna y el resultado intermedio */
     mete(f(Ficha,0,4),Tab_in,Tab_int).

  regla(Tab_in,Ficha,1,4,Tab_int):-
     mete(f(Ficha,1,4),Tab_in,Tab_int).
   
  regla(Tab_in,Ficha,2,4,Tab_int):-
     mete(f(Ficha,2,4),Tab_in,Tab_int).

  regla(Tab_in,Ficha,3,4,Tab_int):-
     mete(f(Ficha,3,4),Tab_in,Tab_int).

/* Columna 5*/ 
  regla(Tab_in,Ficha,0,5,Tab_int):-  /*Est� claro es el tablero, el tipo de ficha, su orientaci�n, la columna y el resultado intermedio */
     mete(f(Ficha,0,5),Tab_in,Tab_int).

  regla(Tab_in,Ficha,1,5,Tab_int):-
     mete(f(Ficha,1,5),Tab_in,Tab_int).
   
  regla(Tab_in,Ficha,2,5,Tab_int):-
     mete(f(Ficha,2,5),Tab_in,Tab_int).

  regla(Tab_in,Ficha,3,5,Tab_int):-
     mete(f(Ficha,3,5),Tab_in,Tab_int).


/* Codigo de backtrack */

/* Caso base: todas las fichas se han colocado */
backtrack([], Tablero, Solucion, Solucion):-
    pinta(Tablero),                 % Pinta el tablero final
    escribesol(Solucion).           % Escribe la solución final

/* Caso recursivo: intenta colocar la siguiente ficha */
backtrack([Ficha | RestJuego], Tablero, SolucionActual, SolucionFinal):-
    probar_orientaciones(Ficha, Tablero, 1, SolucionActual, RestJuego, SolucionFinal).

/* Probar todas las orientaciones (0 a 3) */
probar_orientaciones(Ficha, Tablero, Orientacion, SolucionActual, RestJuego, SolucionFinal):-
    Orientacion <= 3,                         % Orientaciones válidas: 0, 1, 2, 3
    probar_columnas(Ficha, Tablero, Orientacion, 1, SolucionActual, RestJuego, SolucionFinal).

probar_orientaciones(Ficha, Tablero, Orientacion, SolucionActual, RestJuego, SolucionFinal):-
    Orientacion < 3,                          % Incrementa orientación si no se encuentra solución
    OrientacionSiguiente is Orientacion + 1,
    probar_orientaciones(Ficha, Tablero, OrientacionSiguiente, SolucionActual, RestJuego, SolucionFinal).

/* Probar todas las columnas (1 a 5) */
probar_columnas(Ficha, Tablero, Orientacion, Columna, SolucionActual, RestJuego, SolucionFinal):-
    Columna <= 5,                             % Columnas válidas: 1 a 5
    regla(Tablero, Ficha, Orientacion, Columna, TableroActualizado),  % Intentar colocar la ficha
    Movimiento = f(Ficha, Orientacion, Columna), % Registrar el movimiento realizado
    backtrack(RestJuego, TableroActualizado, [Movimiento | SolucionActual], SolucionFinal).

probar_columnas(Ficha, Tablero, Orientacion, Columna, SolucionActual, RestJuego, SolucionFinal):-
    Columna < 5,                              % Incrementa columna si no se encuentra solución
    ColumnaSiguiente is Columna + 1,
    probar_columnas(Ficha, Tablero, Orientacion, ColumnaSiguiente, SolucionActual, RestJuego, SolucionFinal).

  tetris():-
  
     vacia(T),
     backtrack([1,2,3,3],T,[],Solucion_Final),
     write(Solucion_Final,'\n').
    
     

goal

  tetris().
