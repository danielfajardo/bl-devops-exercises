# Ejercicios GitHub Actions

## Ejercicio 1 - Crea un workflow CI para el proyecto de frontend

En este ejercicio vamos a crear un workflow de CI para el proyecto de frontend. Este workflow, que construirá el proyecto y ejecutará los test unitarios, se debe ejecutar cuando haya cambios en el proyecto *hangman-front* y exista una pull request.

Para ello necesitamos crear nuestros workflows bajo la ruta *.github/workflows*. Dentro de esta carpeta, creamos el fichero *ejercicio1.yml* con el siguiente contenido:

```yaml
name: Ejercicio 1 - Build and test front project

on:
  pull_request:
    paths: 
    - '03-ci-cd/03-github-actions/hangman-front/**'

jobs:
  build-test-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build the project and run the tests
        working-directory: ./03-ci-cd/03-github-actions/hangman-front
        run: |
          npm ci
          npm run build
          npm test
```

Para comprobar el workflow realizamos el siguiente proceso:
 1. Creamos una rama *test-ejercicio-1* y creamos el fichero *README.md* en el proyecto *hangman-api*.
 2. Hacemos push y creamos una *Pull Request (PR)*.
 3. Comprobamos que el workflow no se ha ejecutado.
 4. Creamos el fichero *README.md* en el proyecto *hangman-api* en la misma rama y hacemos push.
 5. El workflow si se ha ejecutado esta vez y ha fallado porque el test unitario tiene un error. Lo arreglamos y volvemos a hacer push.
 6. Comprobamos que termina satisfactoriamente y hacemos merge a la rama principal.

![](./images/01_01_test_pr.png)

También podemos comprobar las ejecuciones en la pestaña *Actions*.

![](./images/01_02_actions.png)

Y dentro de estas podemos ver los logs de cada step.

![](./images/01_03_action_error.png)
