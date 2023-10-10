# Ejercicio 1 - Creación de directorios y carpetas mediante comandos

Para la creación de directorios tenemos el comando mkdir. En conjunto con el comando cd, podemos crear las estructuras de carpetas que necesitemos.

Sin embargo, podemos evitar esto utilizando el modo *-p* que creará toda la estructura de una sola vez.
```shell
$ mkdir -p foo/dummy foo/empty
$ tree
.
└── foo
    ├── dummy
    └── empty

3 directories, 0 files
```

Ahora creamos los dos ficheros deseados en la carpeta *foo/dummy*. Primero creamos el fichero *file1.txt* redirigiendo la salida de la shell.

```shell
$ echo 'Me encanta la bash!!' > foo/dummy/file1.txt
$ cat foo/dummy/file1.txt
Me encanta la bash!!
```

Segundo, creamos el fichero *file2.txt* vacío.
```shell
$ touch foo/dummy/file2.txt
$ test -s foo/dummy/file2.txt || echo "File is empty"
File is empty
```

Comprobamos la estructura creada y los tamaños de los ficheros.
```shell
$ tree --du -h
[ 16K]  .
└── [ 12K]  foo
    ├── [4.0K]  dummy
    │   ├── [  21]  file1.txt
    │   └── [   0]  file2.txt
    └── [4.0K]  empty

  16K used in 3 directories, 2 files
```

## Ejercicio 2 - Copiado y movimiento de ficheros

Basándonos en el resultado del ejercicio anterior, copiamos el contenido de *file1.txt* en *file2.txt* y comprobamos que se ha copiado correctamente.
```shell
$ cp foo/dummy/file{1,2}.txt
$ head -n -0 foo/dummy/file*.txt
==> foo/dummy/file1.txt <==
Me encanta la bash!!

==> foo/dummy/file2.txt <==
Me encanta la bash!!
```

Ejecutamos el comando para mover el fichero *file2.txt* de la carpeta *dummy* a *empty* y comprobamos resultado.
```shell
$ mv foo/{dummy,empty}/file2.txt
$ tree --du -h
[ 16K]  .
└── [ 12K]  foo
    ├── [4.0K]  dummy
    │   └── [  21]  file1.txt
    └── [4.0K]  empty
        └── [  21]  file2.txt

  16K used in 3 directories, 2 files
```

## 3. Creación de script bash que agrupe los ejerciciones anteriores y permita alimentar file1.txt a través de parámetro

[Bash script](ejercicio3.sh)

Ejecución del script con una cadena vacía.
```shell
$ ./ejercicio3.sh $(pwd) ''
TREE STRUCTURE
--------------------
[ 17K]  .
├── [ 960]  ejercicio3.sh
└── [ 12K]  foo
    ├── [4.0K]  dummy
    │   └── [  25]  file1.txt
    └── [4.0K]  empty
        └── [  25]  file2.txt

  17K used in 3 directories, 3 files

FILES CONTENT
--------------------
==> /home/danielfgon/bootcamp_devops/foo/dummy/file1.txt <==
Que me gusta la bash!!!!

==> /home/danielfgon/bootcamp_devops/foo/empty/file2.txt <==
Que me gusta la bash!!!!
```

Ejecución con una cadena no vacía.
```shell
$ ./ejercicio3.sh $(pwd) 'Hola lemoncoders!'
TREE STRUCTURE
--------------------
[ 17K]  .
├── [ 960]  ejercicio3.sh
└── [ 12K]  foo
    ├── [4.0K]  dummy
    │   └── [  18]  file1.txt
    └── [4.0K]  empty
        └── [  18]  file2.txt

  17K used in 3 directories, 3 files

FILES CONTENT
--------------------
==> /home/danielfgon/bootcamp_devops/foo/dummy/file1.txt <==
Hola lemoncoders!

==> /home/danielfgon/bootcamp_devops/foo/empty/file2.txt <==
Hola lemoncoders!
```

## 4. Creación de script bash que descargue el contenido de una página web a un fichero y busque en dicho fichero una palabra dada como parámetro al invocar el script

[Bash script](ejercicio4.sh)

Ejecución de script en la que no aparece en el texto la palabra.
```
$ ./ejercicio4.sh DevOpsA
No se ha encontrado la palabra "DevOpsA".
```

Ejecución de script en la que aparece en el texto la palabra.
```
$ ./ejercicio4.sh DevOps
La palabra "DevOps" aparece 12 veces.
Aparece por primera vez en la línea 13.
```

Hay que tener en cuenta que hace una búsqueda exacta por la palabra. Si queremos que no sea case sensitive, debemos editar la línea en la que se guarda la variable *OCURRENCES* para añadirle el flag *-i*.

```
OCCURRENCES=$(grep -io $1 -n $FILE_NAME)
```

## 5. Modificar el ejercicio anterior de forma que la URL de la página web se pase por parámetro y también verifique que la llamada al script sea correcta

[Bash script](ejercicio5.sh)

Ejecución para comprobar el chequeo de parámetros.

```shell
$ ./ejercicio5.sh https://lemoncode.net/bootcamp-devops#bootcamp-devops/inicio
Se necesitan únicamente dos parámetros para ejecutar este script.

$ ./ejercicio5.sh https://lemoncode.net/bootcamp-devops#bootcamp-devops/inicio DevOps 1
Se necesitan únicamente dos parámetros para ejecutar este script.
```

Ejecución para palabra que devuelve más de un resultado.
```shell
$ ./ejercicio5.sh https://lemoncode.net/bootcamp-devops#bootcamp-devops/inicio DevOps
La palabra "DevOps" aparece 12 veces.
Aparece por primera vez en la línea 13.
```

Ejecución para palabra que devuelve un único resultado.
```shell
$ ./ejercicio5.sh https://lemoncode.net/bootcamp-devops#bootcamp-devops/inicio GitLab
La palabra "GitLab" aparece 1 vez.
Aparece únicamente en la línea 673.
```