:- dynamic anime/1.
anime(X) :- member(X,["Dragon Ball", "Naruto", "Bleach", "HunterXHunter", "Hamtaro", "Full Metal Alchemist"]).

genero(X) :- member(X,["Aventura", "Shoujo", "Shounen", "Kodomo", "Seinen", "Josei", "Ficcion",
                    "Fantasia", "Mecha", "Sobrenatural", "Magia", "Gore"]).

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
interseccion(_, [],[]).
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

/*
Subir la popularidad del anime si los usuarios preguntan por él 5 o más veces.
*/
:- dynamic contador/2.
contador("Dragon Ball",0).
contador("Naruto",0).
contador("Bleach",0).
contador("HunterXHunter",0).
contador("Hamtaro",0).
contador("Full Metal Alchemist",0).

% Predicado inicio del chatbot.
inicio :- write('Esto es AniBot, un chatbot que te recomendará sobre Animes.'), nl, 
		  write('Puedes hacer preguntas sobre la popularidad, genero y el rating.'), nl,
          write('Escribe <start> en la terminal si deseas continuar. En caso contrario por <salir>.'), 
          nl, readln(X), nl, mensajes(X).

mensajes([start]) :- write('Pregunte lo que desee consultar'),nl, readln(X), nl, mensajes(X).

% Preguntas sobre el orden segun rating.

% Shounen
mensajes([dime,los, animes, del, genero, shounen, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Shounen",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, shounen, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Shounen",@>=), nl, readln(Y), nl, mensajes(Y).

% Aventura
mensajes([dime,los, animes, del, genero, aventura, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Aventura",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, aventura, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Aventura",@>=), nl, readln(Y), nl, mensajes(Y).

% Shoujo
mensajes([dime,los, animes, del, genero, shoujo, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Shoujo",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, shoujo, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Shoujo",@>=), nl, readln(Y), nl, mensajes(Y).

% Kodomo
mensajes([dime,los, animes, del, genero, kodomo, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Kodomo",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, kodomo, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Kodomo",@>=), nl, readln(Y), nl, mensajes(Y).

% Seinen
mensajes([dime,los, animes, del, genero, seinen, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Seinen",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, seinen, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Seinen",@>=), nl, readln(Y), nl, mensajes(Y).

% Josei
mensajes([dime,los, animes, del, genero, josei, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Josei",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, josei, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Josei",@>=), nl, readln(Y), nl, mensajes(Y).

% Ficcion
mensajes([dime,los, animes, del, genero, ficcion, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Ficcion",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, ficcion, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Ficcion",@>=), nl, readln(Y), nl, mensajes(Y).

% Fantasia
mensajes([dime,los, animes, del, genero, fantasia, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Fantasia",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, fantasia, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Fantasia",@>=), nl, readln(Y), nl, mensajes(Y).

% Mecha
mensajes([dime,los, animes, del, genero, mecha, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Mecha",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, mecha, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Mecha",@>=), nl, readln(Y), nl, mensajes(Y).

% Sobrenatural
mensajes([dime,los, animes, del, genero, sobrenatural, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Sobrenatural",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, sobrenatural, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Sobrenatural",@>=), nl, readln(Y), nl, mensajes(Y).

% Magia
mensajes([dime,los, animes, del, genero, magia, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Magia",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, magia, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Magia",@>=), nl, readln(Y), nl, mensajes(Y).

% Gore
mensajes([dime,los, animes, del, genero, gore, ordenados, de, forma, ascendente, segun, rating ]):- 
    orderBy(rating,"Gore",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, gore, ordenados, de, forma, descendente, segun, rating ]):- 
    orderBy(rating,"Gore",@>=), nl, readln(Y), nl, mensajes(Y).

% Preguntas sobre el orden segun popularidad.

% Shounen
mensajes([dime,los, animes, del, genero, shounen, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Shounen",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, shounen, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Shounen",@>=), nl, readln(Y), nl, mensajes(Y).

% Aventura
mensajes([dime,los, animes, del, genero, aventura, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Aventura",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, aventura, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Aventura",@>=), nl, readln(Y), nl, mensajes(Y).

% Shoujo
mensajes([dime,los, animes, del, genero, shoujo, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Shoujo",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, shoujo, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Shoujo",@>=), nl, readln(Y), nl, mensajes(Y).

% Kodomo
mensajes([dime,los, animes, del, genero, kodomo, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Kodomo",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, kodomo, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Kodomo",@>=), nl, readln(Y), nl, mensajes(Y).

% Seinen
mensajes([dime,los, animes, del, genero, seinen, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Seinen",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, seinen, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Seinen",@>=), nl, readln(Y), nl, mensajes(Y).

% Josei
mensajes([dime,los, animes, del, genero, josei, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Josei",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, josei, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Josei",@>=), nl, readln(Y), nl, mensajes(Y).

% Ficcion
mensajes([dime,los, animes, del, genero, ficcion, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Ficcion",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, ficcion, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Ficcion",@>=), nl, readln(Y), nl, mensajes(Y).

% Fantasia
mensajes([dime,los, animes, del, genero, fantasia, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Fantasia",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, fantasia, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Fantasia",@>=), nl, readln(Y), nl, mensajes(Y).

% Mecha
mensajes([dime,los, animes, del, genero, mecha, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Mecha",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, mecha, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Mecha",@>=), nl, readln(Y), nl, mensajes(Y).

% Sobrenatural
mensajes([dime,los, animes, del, genero, sobrenatural, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Sobrenatural",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, sobrenatural, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Sobrenatural",@>=), nl, readln(Y), nl, mensajes(Y).

% Magia
mensajes([dime,los, animes, del, genero, magia, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Magia",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, magia, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Magia",@>=), nl, readln(Y), nl, mensajes(Y).

% Gore
mensajes([dime,los, animes, del, genero, gore, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    orderBy(popularidad,"Gore",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, gore, ordenados, de, forma, descendente, segun, popularidad ]):- 
    orderBy(popularidad,"Gore",@>=), nl, readln(Y), nl, mensajes(Y).

% Preguntas sobre el orden segun popularidad y rating.

% Shounen
mensajes([dime,los, animes, del, genero, shounen, ordenados, de, forma, ascendente, segun, popularidad, y, rating]):- 
    orderBy(both,"Shounen",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, shounen, ordenados, de, forma, descendente, segun, popularidad, y, rating]):- 
    orderBy(both,"Shounen",@>=), nl, readln(Y), nl, mensajes(Y).

% Aventura
mensajes([dime,los, animes, del, genero, aventura, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Aventura",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, aventura, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Aventura",@>=), nl, readln(Y), nl, mensajes(Y).

% Shoujo
mensajes([dime,los, animes, del, genero, shoujo, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Shoujo",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, shoujo, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Shoujo",@>=), nl, readln(Y), nl, mensajes(Y).

% Kodomo
mensajes([dime,los, animes, del, genero, kodomo, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Kodomo",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, kodomo, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Kodomo",@>=), nl, readln(Y), nl, mensajes(Y).

% Seinen
mensajes([dime,los, animes, del, genero, seinen, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Seinen",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, seinen, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Seinen",@>=), nl, readln(Y), nl, mensajes(Y).

% Josei
mensajes([dime,los, animes, del, genero, josei, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Josei",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, josei, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Josei",@>=), nl, readln(Y), nl, mensajes(Y).

% Ficcion
mensajes([dime,los, animes, del, genero, ficcion, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Ficcion",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, ficcion, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Ficcion",@>=), nl, readln(Y), nl, mensajes(Y).

% Fantasia
mensajes([dime,los, animes, del, genero, fantasia, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Fantasia",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, fantasia, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Fantasia",@>=), nl, readln(Y), nl, mensajes(Y).

% Mecha
mensajes([dime,los, animes, del, genero, mecha, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Mecha",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, mecha, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Mecha",@>=), nl, readln(Y), nl, mensajes(Y).

% Sobrenatural
mensajes([dime,los, animes, del, genero, sobrenatural, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Sobrenatural",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, sobrenatural, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Sobrenatural",@>=), nl, readln(Y), nl, mensajes(Y).

% Magia
mensajes([dime,los, animes, del, genero, magia, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Magia",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, magia, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Magia",@>=), nl, readln(Y), nl, mensajes(Y).

% Gore
mensajes([dime,los, animes, del, genero, gore, ordenados, de, forma, ascendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Gore",@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, gore, ordenados, de, forma, descendente, segun, popularidad, y, rating ]):- 
    orderBy(both,"Gore",@>=), nl, readln(Y), nl, mensajes(Y).

% Preguntas sobre los animes con X número de estrellas dentro de cierto género.

%Formato 1, Shounen.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, shounen ]):- 
    estrellas(X,Shounen), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Aventura.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, aventura ]):- 
    estrellas(X,Aventura), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Shoujo.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, shoujo ]):- 
    estrellas(X,Shoujo), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Kodomo.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, kodomo ]):- 
    estrellas(X,Kodomo), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Seinen.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, seinen ]):- 
    estrellas(X,Seinen), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Josei.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, josei ]):- 
    estrellas(X,Josei), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Ficción.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, ficcion ]):- 
    estrellas(X,Ficcion), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Fantasía.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, fantasia ]):- 
    estrellas(X,Fantasia), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Mecha.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, mecha ]):- 
    estrellas(X,Mecha), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Sobrenatural.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, sobrenatural ]):- 
    estrellas(X,Sobrenatural), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Magia.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, magia ]):- 
    estrellas(X,Magia), nl, readln(Y), nl, mensajes(Y).

%Formato 1, Gore.
mensajes([cuales, son, los, animes, con, X, numero, de, estrellas, del, genero, gore ]):- 
    estrellas(X,Gore), nl, readln(Y), nl, mensajes(Y).

% Formato 2.
%mensajes([quiero, saber,cuales,son, los, animes, con, X, numero, de, estrellas, del, genero, Y, _|_]):- estrellas(X,Y), nl.

% Consulta de todos los animes
mensajes([ver, animes]):- findall(X, anime(X), X), imprimir(X), nl, readln(Y), nl, mensajes(Y).
mensajes([ver, animes,_|_]):- findall(X, anime(X), X), imprimir(X), nl, readln(Y), nl, mensajes(Y).

% Preguntas sobre animes poco conocidos:
mensajes([cuales, son , los, animes, poco, conocidos, _|_]):- pocoConocidos(), nl, readln(Y), nl, mensajes(Y).
mensajes([quiero, saber, cuales, son , los, animes, poco, conocidos, _|_]):- pocoConocidos(), nl, readln(Y), nl, mensajes(Y).
mensajes([dime, cuales, son , los, animes, poco, conocidos, _|_]):- pocoConocidos(), nl, readln(Y), nl, mensajes(Y).

% Mensaje de agregar nuevo anime a la base.

% Formato 1, Shounen, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, shounen, con, W, de, rating ]):- 
    agregar(X,"Shounen",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Shounen, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, shounen, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Shounen",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Aventura, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, aventura, con, W, de, rating ]):- 
    agregar(X,"Aventura",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Aventura, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, aventura, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Aventura",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Shoujo, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, shoujo, con, W, de, rating ]):- 
    agregar(X,"Shoujo",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Shoujo, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, shoujo, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Shoujo",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Kodomo, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, kodomo, con, W, de, rating ]):- 
    agregar(X,"Kodomo",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Kodomo, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, kodomo, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Kodomo",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Seinen, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, seinen, con, W, de, rating ]):- 
    agregar(X,"Seinen",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Seinen, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, seinen, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Seinen",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Josei, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, josei, con, W, de, rating ]):- 
    agregar(X,"Josei",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Josei, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, josei, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Josei",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Ficcion, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, ficcion, con, W, de, rating ]):- 
    agregar(X,"Ficcion",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Ficcion, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, ficcion, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Ficcion",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Fantasia, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, fantasia, con, W, de, rating ]):- 
    agregar(X,"Fantasia",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Seinen, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, fantasia, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Fantasia",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Mecha, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, mecha, con, W, de, rating ]):- 
    agregar(X,"Mecha",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Mecha, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, mecha, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Mecha",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Sobrenatural, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, sobrenatural, con, W, de, rating ]):- 
    agregar(X,"Sobrenatural",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Sobrenatural, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, sobrenatural, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Sobrenatural",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Magia, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, magia, con, W, de, rating ]):- 
    agregar(X,"Magia",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Magia, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, magia, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Magia",W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Gore, sin popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, gore, con, W, de, rating ]):- 
    agregar(X,"Gore",W,1), nl, readln(Y), nl, mensajes(Y).

% Formato 1, Gore, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, gore, con, W, de, rating, y, popularidad, Z ]):- 
    agregar(X,"Gore",W,Z), nl, readln(Y), nl, mensajes(Y).

% Para finalizar el chatbot.
mensajes([salir]).

% Cuando escribe algo que no esta en los mensajes predeterminados.
mensajes([_|_]):- write("No entiendo tu consulta, intente otra vez"),nl, readln(Y), nl, mensajes(Y).