anime(X) :- member(X,["Dragon Ball", "Naruto", "Bleach", "HunterXHunter", "Hamtaro", "Full Metal Alchemist"]).

genero(X) :- member(X,["Aventura", "Shoujo", "Shounen", "Kodomo", "Seinen", "Josei", "Ficción",
                    "Fantasía", "Mecha", "Sobrenatural", "Magia", "Gore"]).

generoAnime("Naruto",["Shounen","Aventura"]).
generoAnime("Dragon Ball",["Shounen"]).
generoAnime("Bleach",["Shounen", "Sobrenatural"]).
generoAnime("HunterXHunter",["Seinen", "Aventura"]).
generoAnime("Hamtaro",["Kodomo"]).
generoAnime("Full Metal Alchemist",["Shounen", "Magia"]).

rating("Dragon Ball",3).
rating("Naruto",1).
rating("Bleach",4).
rating("HunterXHunter",5).
rating("Hamtaro",2).
rating("Full Metal Alchemist",4).

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

% Realiza el query sobre el rating de todos los anime y los imprime en orden ascendente
orderBy(rating,Z) :- findall((Y,X),rating(Y,X), L), sort(2,@=<, L,  Sorted),findall(A,generoAnime(A,Z),A),  imprimir(Sorted).


% Dado un arreglo imprime cada elemento en una linea
imprimir([]).
imprimir([X|L]) :- writeln(X), imprimir(L).

% Realiza el query sobre la popularidad de todos los anime y los imprime en orden  ascendente
orderBy(popularidad) :- findall((Y,X),popularidad(Y,X), L), sort(2,@=<, L, Sorted), imprimir(Sorted).

% Funcion que concatena dos listas.
/*concat([], X, X).
concat([Y|YS], X, [Y|Z]) :- concat(YS, X, Z).

ordenarRating(X, Z):- findall(A,generoAnime(A,X),A),
                      findall(A1, rating(A1,1),A1), member(A1,A), concat([],A1,Z1),
                      findall(A2, rating(A2,2),A2), member(A2,A), concat(Z1,A2,Z2),
                      findall(A3, rating(A3,3),A3), member(A3,A), concat(Z2,A3,Z3),
                      findall(A4, rating(A4,4),A4), member(A4,A), concat(Z3,A4,Z4),
                      findall(A5, rating(A5,5),A5), member(A5,A), concat(Z4,A5,Z).

Poder mostar los animés con X número de estrellas dentro de cierto género (el género es
un estado del chatbot que se debe conocer).
*/
estrellas(X,Y):- findall(Y,rating(Y,X), l1), findall(Z,generoAnime(Z,Y), l2).

%pertenece([X|Xs],[Y|Ys], Z):- member(X,[Y|Ys]).