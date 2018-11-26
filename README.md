# AniBot

Integrantes:
- Angélica Acosta 14-10005.
- Giulianne Tavano 13-11389. 

## Para iniciar con el chatbot, debe realizar los siguientes pasos:

(1) Tener instalado SWI-Prolog.
(2) Abrir la terminar y escribir: "swipl -S AniBot.pl"
(3) Escribrir "inicio.", que es el predicado que da inicio al chatbot.

## En el chatbot se pueden realizar consultas de diversos tipos. Los formatos admitidos son los siguientes:

(1) Para ordenar:
- dime los animes del genero G ordenados de forma ascendente segun rating 
- dime los animes del genero G ordenados de forma descendente segun rating 
- dime los animes del genero G ordenados de forma ascendente segun popularidad 
- dime los animes del genero G ordenados de forma descendente segun popularidad
- dime los animes del genero G ordenados de forma ascendente segun popularidad y rating
- dime los animes del genero G ordenados de forma descendente segun popularidad y rating

(2) Sobre numero de estrellas y genero:
- cuales son los animes con X estrellas del genero G

(3) Ver todos los animes:
- ver animes

(4) Ver los animes poco conocidos: (Se consideran animes poco conocidos aquellos que tengan 4 o 5 estrellas y popularidad de 1 a 5.)
- cuales son los animes poco conocidos
- quiero saber cuales son los animes poco conocidos
- dime cuales son los animes poco conocidos

(5) Agregar nuevo anime a la base de datos:
- deseo agregar el anime X del genero G con W de rating
- deseo agregar el anime X del genero G con W de rating y popularidad Z 

(6) Ver genero de anime:
- quiero saber el genero del anime X
- cual es el genero del anime X
- cual es el genero de X

(7) Ver rating de anime:
- quiero saber el rating del anime X
- quiero saber el rating de 
- cual es el rating del anime X
- cual es el rating de X

(8) Ver popularidad de anime:
- quiero saber la popularidad del anime X
- cual es la popularidad del anime X
- cual es la popularidad de X
- cuanta popularidad tiene el anime X
- cuanta popularidad tiene X

(9) Ver contador de consultas:
- ver contador

(10) Ver popularidad de los animes:
- ver popularidad

(11) Ver el rating de los animes:
- ver rating

(12) Ver los generos:
- ver generos

(13) Consultas extras:
- cuales son los mejores ratings
- cuales son los bastante conocidos
- cuales son los muy conocidos
- cuales son los conocidos
- cuales son los muy poco conocidos
- dime los mejores ratings
- dime los bastante conocidos
- dime los muy conocidos
- dime los conocidos
- dime los muy poco conocidos

(14) Recomendaciones segun genero:
- me gusta el G
- me gusta el genero G
- el genero que mas me gusta es G

(15) Salir:
- salir

## Sobre el diseño

El predicado inicio se encarga de ejecutar AniBot. Este llama al predicado recursivo mensajes/1 que se 
encarga de recibir el input del usuario para ejecutar su consulta y mostrar el output correspondiente.

Se tienen verificaciones para el input de los generos y los anime, pues para preguntar por ellos deben 
estar cargados en la base. Estos predicados son generoValido/2 y animeValido/2.

Cuando un mensaje del usuario no cumple con las caracteristicas antes mencionadas se muestran mensajes 
de error.

El predicado consulta/1 mantiene un contador de la cantidad de consultas que se le realizan a un anime
en particular, a fin de poder aumentar la popularidad cuando se hacen muchas consultas.