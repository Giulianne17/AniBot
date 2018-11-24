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


% Dado un arreglo imprime cada elemento en una linea
imprimir([]).
imprimir([X|L]) :- writeln(X), imprimir(L).


% Funcion que concatena dos listas.
concat([], X, X).
concat([Y|YS], X, [Y|Z]) :- concat(YS, X, Z).

% Muestra los animes del genero G que tengan X estrellas
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

% Dado un string de genero lo devuelve en el formato deseado 
cambiarGenero(aventura, "Aventura").
cambiarGenero(shoujo, "Shoujo").
cambiarGenero(shounen, "Shounen").
cambiarGenero(kodomo, "Kodomo").
cambiarGenero(seinen, "Seinen").
cambiarGenero(josei, "Josei"). 
cambiarGenero(ficcion, "Ficcion").
cambiarGenero(fantasia, "Fantasia").
cambiarGenero(mecha, "Mecha").
cambiarGenero(sobrenatural, "Sobrenatural").
cambiarGenero(magia, "Magia").
cambiarGenero(gore, "Gore").

% Dado un genero lo devuelve en el formato deseado en el caso de que pertenezca a la lista de generos existente 
generoValido(G, NewG):- cambiarGenero(G, NewG), findall(Genero, genero(Genero), Generos), member(NewG,Generos).

% Muestra animes con baja popularidad y rating alto
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

% Si el anime A no existe en la base de datos, lo agrega con genero G, rating R y popularidad P
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
          write('Escribe <start> en la terminal si deseas continuar. En caso contrario pon <salir>.'), 
          nl, readln(X), nl, mensajes(X).

mensajes([start]) :- write('Pregunte lo que desee consultar'),nl, readln(X), nl, mensajes(X).

/* Preguntas sobre el orden segun rating. */

mensajes([dime,los, animes, del, genero, G, ordenados, de, forma, ascendente, segun, rating ]):- 
    generoValido(G, NewG), orderBy(rating,NewG,@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, G, ordenados, de, forma, descendente, segun, rating ]):- 
    generoValido(G, NewG), orderBy(rating,NewG,@>=), nl, readln(Y), nl, mensajes(Y).

/* Preguntas sobre el orden segun popularidad. */

mensajes([dime,los, animes, del, genero, G, ordenados, de, forma, ascendente, segun, popularidad ]):- 
    generoValido(G, NewG), orderBy(popularidad,NewG,@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, G, ordenados, de, forma, descendente, segun, popularidad ]):- 
    generoValido(G, NewG), orderBy(popularidad,NewG,@>=), nl, readln(Y), nl, mensajes(Y).

/* Preguntas sobre el orden segun popularidad y rating. */

mensajes([dime,los, animes, del, genero, G, ordenados, de, forma, ascendente, segun, popularidad, y, rating]):- 
    generoValido(G, NewG), orderBy(both,NewG,@=<), nl, readln(Y), nl, mensajes(Y).
mensajes([dime,los, animes, del, genero, G, ordenados, de, forma, descendente, segun, popularidad, y, rating]):- 
    generoValido(G, NewG), orderBy(both,NewG,@>=), nl, readln(Y), nl, mensajes(Y).

% Mensajes invalidos
mensajes([dime,los, animes, del, genero, _, ordenados, de, forma, _, segun, _|_]):- 
    writeln("No conozco ese genero. Intenta con alguno de estos:"), nl,
    findall(G, genero(G), Generos), imprimir(Generos), nl, readln(Y), nl, mensajes(Y).

/* Preguntas sobre los animes con X número de estrellas dentro de cierto género. */

% Formato valido
mensajes([cuales, son, los, animes, con, X, estrellas, del, genero, G]):- 
    generoValido(G, NewG), number(X), X>0, X<6, estrellas(X,NewG), nl, readln(Y), nl, mensajes(Y).

% Formato genero invalido.
mensajes([cuales, son, los, animes, con, X, estrellas, del, genero, _]):- 
    number(X), X>0, X<6, writeln("No conozco ese genero. Intenta con alguno de estos:"), nl,
    findall(G, genero(G), Generos), imprimir(Generos), nl, readln(Y), nl, mensajes(Y).

% Formato error de numero.
mensajes([cuales, son, los, animes, con, X, estrellas, del, genero, _]):- 
    number(X), writeln("Los animes pueden tener de 1 a 5 estrellas. Intenta de nuevo."), nl, readln(Y), nl, mensajes(Y).

%Formato error de letra.
mensajes([cuales, son, los, animes, con, _, estrellas, del, genero, _]):- 
    writeln("Creo que es obvio pero lo dire. La cantidad de estrellas son numeros."), nl, readln(Y), nl, mensajes(Y).


/* Consulta de todos los animes */

mensajes([ver, animes]):- findall(X, anime(X), X), imprimir(X), nl, readln(Y), nl, mensajes(Y).
mensajes([ver, animes,_|_]):- findall(X, anime(X), X), imprimir(X), nl, readln(Y), nl, mensajes(Y).

/* Preguntas sobre animes poco conocidos: */

mensajes([cuales, son , los, animes, poco, conocidos, _|_]):- pocoConocidos(), nl, readln(Y), nl, mensajes(Y).
mensajes([quiero, saber, cuales, son , los, animes, poco, conocidos, _|_]):- pocoConocidos(), nl, readln(Y), nl, mensajes(Y).
mensajes([dime, cuales, son , los, animes, poco, conocidos, _|_]):- pocoConocidos(), nl, readln(Y), nl, mensajes(Y).

/* Mensaje de agregar nuevo anime a la base. */

% Formato valido, sin popularidad
mensajes([deseo, agregar, el, anime, X, del, genero, G, con, W, de, rating ]):- 
    generoValido(G, NewG), number(W), W>0, W<6, agregar(X,NewG,W,1), nl, readln(Y), nl, mensajes(Y).

% Formato valido, con popularidad.
mensajes([deseo, agregar, el, anime, X, del, genero, G, con, W, de, rating, y, popularidad, Z ]):- 
    generoValido(G, NewG), number(W), W>0, W<6, number(Z), Z>0, Z<11, agregar(X,NewG,W,Z), nl, readln(Y), nl, mensajes(Y).

% Formato invalido, genero.
mensajes([deseo, agregar, el, anime, _, del, genero, _, con, W, de, rating ]):- 
    number(W), W>0, W<6, writeln("No conozco ese genero. Intenta con alguno de estos:"), nl,
    findall(G, genero(G), Generos), imprimir(Generos), nl, readln(Y), nl, mensajes(Y).

% Formato invalido, genero con popularidad.
mensajes([deseo, agregar, el, anime, _, del, genero, _, con, W, de, rating, y, popularidad, Z ]):- 
    number(W), W>0, W<6, number(Z), Z>0, Z<11, writeln("No conozco ese genero. Intenta con alguno de estos:"), nl,
    findall(G, genero(G), Generos), imprimir(Generos), nl, readln(Y), nl, mensajes(Y).

% Formato invalido, error numero rating.
mensajes([deseo, agregar, el, anime, _, del, genero, _, con, W, de, rating ]):- 
   number(W), write("El rating debe ser del 1 al 5."), nl, readln(Y), nl, mensajes(Y).

% Formato invalido, error numero rating y popularidad.
mensajes([deseo, agregar, el, anime, _, del, genero, _, con, W, de, rating, y, popularidad, Z ]):-  
   number(W), number(Z), write("El rating debe ser del 1 al 5. La popularidad debe ser del 1 al 10."), 
   nl, readln(Y), nl, mensajes(Y).

% Formato invalida, error rating.
mensajes([deseo, agregar, el, anime, _, del, genero, _, con, _, de, rating]):- 
   write("Creo que es obvio pero lo dire. El rating debe ser un numero."), nl, readln(Y), nl, mensajes(Y).

% Formato invalido, error rating y popularidad.
mensajes([deseo, agregar, el, anime, _, del, genero, _, con, _, de, rating, y, popularidad, _]):-  
   write("Creo que es obvio pero lo dire. El rating y la popularidad deben ser un numero."), nl, readln(Y), nl, mensajes(Y).

/* Para finalizar el chatbot. */
mensajes([salir]).

/* Mensaje de error. */
mensajes([_]):-write("No entiendo tu consulta, dime otra cosa."), nl, readln(Y), nl, mensajes(Y).