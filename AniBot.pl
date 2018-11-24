:- dynamic anime/1.
anime(X) :- member(X,["Dragon Ball", "Naruto", "Bleach", "HunterXHunter", "Hamtaro", "Full Metal Alchemist"]).

genero(X) :- member(X,["Aventura", "Shoujo", "Shounen", "Kodomo", "Seinen", "Josei", "Ficción",
                    "Fantasía", "Mecha", "Sobrenatural", "Magia", "Gore"]).

:- dynamic generoAnime/2.
generoAnime("Naruto",["Shounen","Aventura"]).
generoAnime("Dragon Ball",["Shounen"]).
generoAnime("Bleach",["Shounen", "Sobrenatural"]).
generoAnime("HunterXHunter",["Seinen", "Aventura"]).
generoAnime("Hamtaro",["Kodomo"]).
generoAnime("Full Metal Alchemist",["Shounen", "Magia"]).

:- dynamic rating/2.
rating("Dragon Ball",3).
rating("Naruto",1).
rating("Bleach",4).
rating("HunterXHunter",5).
rating("Hamtaro",2).
rating("Full Metal Alchemist",4).

:- dynamic popularidad/2.
popularidad("Dragon Ball",7).
popularidad("Naruto",5).
popularidad("Bleach",8).
popularidad("HunterXHunter",3).
popularidad("Hamtaro",10).
popularidad("Full Metal Alchemist",1).

%
/* Poder mostrar los animés de un género ordenados por rating y/o popularidad, según
pregunte el usuario, por defecto de mayor a menor. En caso de que se pregunte por ambos
se suma el rating y popularidad y se ordena según el resultado. */

found(_,_,[],[]).
found(A,X,[X|_],[A]).
found(A,X,[_|Xs],Z):- found(A,X,Xs,Z).

foundGenre(_,[],[]).
foundGenre(Genre,[(A,B)|Xs], D) :- foundGenre(Genre,Xs,C), found(A,Genre,B,Z) ,append(Z,C,D).

foundAnime(_,[],[]).
foundAnime(A,[(A,B)|_], [(A,B)]).
foundAnime(A,[_|Pares], As):- foundAnime(A, Pares, As).

loopAnime([],_,[]).
loopAnime([X|Xs],List2,List3):- foundAnime(X, List2, ListA), loopAnime(Xs, List2, ListB), append(ListA, ListB, List3).

% Realiza el query sobre el rating de todos los anime de genero G y los imprime en orden ascendente
orderBy(rating,G) :- 
    findall((Y,X),rating(Y,X), L),              % L tiene una lista de pares (Anime, Rating)
    findall((A,List),generoAnime(A,List),As),   % As tiene una lista de pares (Anime, ListaGeneros)
    foundGenre(G,As,ListGenre),                 % ListGenre tiene una lista de Animes que son del genero G
    loopAnime(ListGenre,L,GenreRating),         % GenreRating tiene una lista de pares (Anime, Rating) donde Anime es del genero G
    sort(2,@=<, GenreRating, Sorted),           % Sorted es la lista GenreRating ordenada por Rating de forma ascendente
    imprimir(Sorted).

% Realiza el query sobre la popularidad de todos los anime de genero G y los imprime en orden ascendente
orderBy(popularidad,G) :- 
    findall((Y,X),popularidad(Y,X), L),         % L tiene una lista de pares (Anime, Popularidad)
    findall((A,List),generoAnime(A,List),As),   % As tiene una lista de pares (Anime, ListaGeneros)
    foundGenre(G,As,ListGenre),                 % ListGenre tiene una lista de Animes que son del genero G
    loopAnime(ListGenre,L,GenrePopular),        % GenrePopular tiene una lista de pares (Anime, Popularidad) donde Anime es del genero G
    sort(2,@=<, GenrePopular, Sorted),          % Sorted es la lista GenrePopular ordenada por Popularidad de forma ascendente
    imprimir(Sorted).


% Dado un arreglo imprime cada elemento en una linea
imprimir([]).
imprimir([X|L]) :- writeln(X), imprimir(L).

% Realiza el query sobre la popularidad de todos los anime y los imprime en orden  ascendente
orderBy(popularidad) :- findall((Y,X),popularidad(Y,X), L), sort(2,@=<, L, Sorted), imprimir(Sorted).

% Funcion que concatena dos listas.
concat([], X, X).
concat([Y|YS], X, [Y|Z]) :- concat(YS, X, Z).
%
/*
ordenarRating(X, Z):- findall(A,generoAnime(A,X),A),
                      findall(A1, rating(A1,1),A1), member(A1,A), concat([],A1,Z1),
                      findall(A2, rating(A2,2),A2), member(A2,A), concat(Z1,A2,Z2),
                      findall(A3, rating(A3,3),A3), member(A3,A), concat(Z2,A3,Z3),
                      findall(A4, rating(A4,4),A4), member(A4,A), concat(Z3,A4,Z4),
                      findall(A5, rating(A5,5),A5), member(A5,A), concat(Z4,A5,Z).
*/

%
/*
Poder mostar los animés con X número de estrellas dentro de cierto género (el género es
un estado del chatbot que se debe conocer).
*/
estrellas(X,Y):- findall(L,rating(L,X),L), findall(A,generoAnime(A,Y),A), interseccion(L,A,W), imprimir(W).

% Funcion que hace la interseccion de dos listas.
interseccion([], _, []).
interseccion([A|As], Bs, [A|Cs]):- member(A, Bs), !, interseccion(As, Bs, Cs).
interseccion([_|As], Bs, Cs):- interseccion(As, Bs, Cs).

/*
Poder mostrar los animés buenos poco conocidos. Aquí se hace referencia a rating alto
con popularidad baja.
*/
pocoConocidos():- findall(L,rating(L,5),L), findall(M,rating(M,4),M), concat(L, M, Z),
                  findall(N,popularidad(N,1),N), findall(O,popularidad(O,2),O), concat(N, O, A),
                  findall(P,popularidad(P,3),P), findall(Q,popularidad(Q,4),Q), concat(P,Q, B),
                  findall(R,popularidad(R,5),R), concat(A,B,C), concat(C,R,D), 
                  interseccion(Z,D,F), imprimir(F). 

/*
Poder agregar a la base de datos un anime con su género y rating, si no está en la misma.
La popularidad es opcional especificarla al agregarlo y por defecto es 1.
*/
agregar(A,G,R,P):- not(member(A,anime(_))), assert(anime(A)), assertz(generoAnime(A,G)),assertz(rating(A,R)), assertz(popularidad(A,P)).