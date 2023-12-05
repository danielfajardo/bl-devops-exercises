# Ejercicios

## Ejercicio 1. Monolito en memoria.

Se trata de una aplicación web que expone una aplicación de UI (la típica aplicación *To Do*), y una API para gestionar en servidor los *To Do*. La persistencia de la aplicación es en memoria, eso significa que cuando apaguemos esta, dejarán de persistir los datos. 

[Solución](./exercises/00-monolith-in-memory/exercise.md)

## Ejercicio 2. Monolito.

Se trata de la misma aplicación pero en este caso la persistencia se hace a través de una base de datos.

[Solución](./exercises/01-monolith/exercise.md)

## Ejercicio 3. Aplicación Distribuida

See trata de dos aplicaciones, una UI expuesta a través de un NGINX y una API que corre sobre Express/Node.js, accesible a través de un Ingress.

[Solución](./exercises/02-distributed/exercise.md)