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

% found(Anime, Genre, GenreList, Result)
% Busca Genre en GenreList. 
% Si está devuelve un arreglo con el Anime, sino devuelve un arreglo vacio
found(_,_,[],[]).
found(Anime,Genre,[Genre|_],[Anime]).
found(Anime,Genre,[_|Xs],R):- found(Anime,Genre,Xs,R).

% foundGenre(Genre, List, Result)
% Para cada anime A en List busca si es del genero Genre.
% Devuelve una lista con los anime que cumplen la condicion.
foundGenre(_,[],[]).
foundGenre(Genre,[(A,B)|Xs], Result) :- foundGenre(Genre,Xs,Result1), found(A,Genre,B,Result2) ,append(Result1,Result2,Result).

% foundAnime(A, List, Result)
% Busca si el anime A es el primer elemento de alguna tupla en List.
% Si está devuelve un arreglo con la tupla, sino devuelve un arreglo vacio.
foundAnime(_,[],[]).
foundAnime(A,[(A,B)|_], [(A,B)]).
foundAnime(A,[_|Pares], Result):- foundAnime(A, Pares, Result).

% loopAnime(AnimeList, List, Result)
% Para cada anime A, busca si es el primer elemento de alguna tupla en List.
% Devuelve una lista con los anime que cumplen la condicion.
loopAnime([],_,[]).
loopAnime([A|As],List,Result):- foundAnime(A, List, ListA), loopAnime(As, List, ListB), append(ListA, ListB, Result).

% addRatingPopularity(Pares1, Pares2, Result)
% Para cada anime suma su popularidad y su rating
addRatingPopularity([(A,R)], [(A,P)], [(A,N)]) :- N is R+P.
addRatingPopularity([(A,R)|Pares1], [(A,P)|Pares2], Adds) :- addRatingPopularity(Pares1,Pares2,List), N is R+P, append([(A,N)], List, Adds).

% Realiza el query sobre el rating de todos los anime de genero G y los imprime en orden indicado
orderBy(rating,G,Order) :- 
    findall((Y,X),rating(Y,X), L),              % L tiene una lista de pares (Anime, Rating)
    findall((A,List),generoAnime(A,List),As),   % As tiene una lista de pares (Anime, ListaGeneros)
    foundGenre(G,As,ListGenre),                 % ListGenre tiene una lista de Animes que son del genero G
    loopAnime(ListGenre,L,GenreRating),         % GenreRating tiene una lista de pares (Anime, Rating) donde Anime es del genero G
    sort(2,Order, GenreRating, Sorted),         % Sorted es la lista GenreRating ordenada por Rating de forma ascendente
    imprimir(Sorted).

% Realiza el query sobre la popularidad de todos los anime de genero G y los imprime en orden indicado
orderBy(popularidad,G,Order) :- 
    findall((Y,X),popularidad(Y,X), L),         % L tiene una lista de pares (Anime, Popularidad)
    findall((A,List),generoAnime(A,List),As),   % As tiene una lista de pares (Anime, ListaGeneros)
    foundGenre(G,As,ListGenre),                 % ListGenre tiene una lista de Animes que son del genero G
    loopAnime(ListGenre,L,GenrePopular),        % GenrePopular tiene una lista de pares (Anime, Popularidad) donde Anime es del genero G
    sort(2,Order, GenrePopular, Sorted),        % Sorted es la lista GenrePopular ordenada por Popularidad de forma ascendente
    imprimir(Sorted).

% Realiza el query sobre la popularidad y el rating de todos los anime de genero G y los imprime en orden indicado
orderBy(both,G,Order) :- 
    findall((Y,X),popularidad(Y,X), L1),        % L1 tiene una lista de pares (Anime, Popularidad)
    findall((Y,X),rating(Y,X), L2),             % L2 tiene una lista de pares (Anime, Rating)
    addRatingPopularity(L1,L2,Suma),            % Suma tiene una lista de pares (Anime, Popularidad+Rating)
    findall((A,List),generoAnime(A,List),As),   % As tiene una lista de pares (Anime, ListaGeneros)
    foundGenre(G,As,ListGenre),                 % ListGenre tiene una lista de Animes que son del genero G
    loopAnime(ListGenre,Suma,GenrePopular),     % GenrePopular tiene una lista de pares (Anime, Popularidad+Rating) donde Anime es del genero G
    sort(2,Order, GenrePopular, Sorted),        % Sorted es la lista GenrePopular ordenada por Popularidad+Rating de forma ascendente
    imprimir(Sorted).

/*
Cuando se trabaje con orderBy hay que preguntar si quiere por rating, genero o ambos y si dice ascendente
Order = @<=, si dice descendente Order = @>=. Si no dice nada se pone descendente
*/

% Dado un arreglo imprime cada elemento en una linea
imprimir([]).
imprimir([X|L]) :- writeln(X), imprimir(L).


% Funcion que concatena dos listas.
concat([], X, X).
concat([Y|YS], X, [Y|Z]) :- concat(YS, X, Z).

%
/*
Poder mostar los animés con X número de estrellas dentro de cierto género (el género es
un estado del chatbot que se debe conocer).
*/
estrellas(X,G):- 
    findall(Anime,rating(Anime,X),AnimeList),                           % AnimeList es una lista de animes que tienen X estrellas
    findall((A,Y),generoAnime(A,Y),AnimeWithGenre),                     % AnimeWithGenre es una lista de pares (Anime, ListaGeneros)
    foundGenre(G, AnimeWithGenre, SpecificAnime),                       % SpecificAnime es una lista de animes que tiene genero G
    interseccion(AnimeList, SpecificAnime, Result), imprimir(Result).   % Result es la intersecion de AnimeList con SpecificAnime

% Funcion que hace la interseccion de dos listas.
interseccion([], _, []).
interseccion([A|As], Bs, [A|Cs]):- member(A, Bs), !, interseccion(As, Bs, Cs).
interseccion([_|As], Bs, Cs):- interseccion(As, Bs, Cs).

/*
Poder mostrar los animés buenos poco conocidos. Aquí se hace referencia a rating alto
con popularidad baja.
*/
pocoConocidos():- 
    findall(A1,rating(A1,5),Rating5), findall(A2,rating(A2,4),Rating4),
    findall(A3,popularidad(A3,1),Popular1), findall(A4,popularidad(A4,2),Popular2), 
    findall(A5,popularidad(A5,3),Popular3), findall(A6,popularidad(A6,4),Popular4), findall(A7,popularidad(A7,5),Popular5),
    concat(Rating5, Rating4, GoodRatings),                              % GoodRatings es una lista de animes con rating 4 o 5
    concat(Popular1, Popular2, LowPopularity1),                         % LowPopularity1 es una lista de animes con popularidad 1 o 2
    concat(Popular3, Popular4, LowPopularity2),                         % LowPopularity2 es una lista de animes con popularidad 3 o 4
    concat(LowPopularity1, LowPopularity2, LowPopularity3),             % LowPopularity3 es una lista de animes con popularidad de 1 a 4
    concat(LowPopularity3, Popular5, LowPopularity),                    % LowPopularity es una lista de animes con popularidad menor o igual a 5
    interseccion(GoodRatings,LowPopularity,NotKnow), imprimir(NotKnow). % NotKnown es la interseccion de GoodRatings y LowPopularity

/*
Poder agregar a la base de datos un anime con su género y rating, si no está en la misma.
La popularidad es opcional especificarla al agregarlo y por defecto es 1.
*/
agregar(A,G,R,P):- not(member(A,anime(_))), assert(anime(A)), assertz(generoAnime(A,G)),assertz(rating(A,R)), assertz(popularidad(A,P)).