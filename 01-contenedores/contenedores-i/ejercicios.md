# Ejercicio 1

## Instalación de MongoDB
Primero buscamos las opciones disponibles en Docker Hub.
```
docker search mongo
```

Seleccionamos la imagen de la lista anterior y ejecutamos la instancia con el siguiente comando.
```
docker run -d --name my-mongo \
            -p 27017:27017 \
            -e MONGO_INITDB_ROOT_USERNAME=admin \
            -e MONGO_INITDB_ROOT_PASSWORD=password \
            mongo:latest
```

Tras ejecutar por primera vez este comando, se descargará la última imagen de mongo al repositorio local y una vez completado, se iniciará el contenedor. Una vez realizado todo esto, nos devolverá el ID del contenedor.

También se puede revisar que todo ha ido correcto, haciendo uso del siguiente comando que listará aquellos contenedores que están ejecutándose.
```
docker ps
```
```shell
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                      NAMES
daf02ff0c276   mongo:latest   "docker-entrypoint.s…"   15 minutes ago   Up 15 minutes   0.0.0.0:27017->27017/tcp   my-mongo
```

Ya está lista nuestra instancia de MongoDB!

## Creación de base de datos y colecciones en MongoDB

Hay diferentes formas de crear bases de datos y colecciones en MongoDB. Una de ellas es haciendo uso de *mongosh*. Para ello, ejecutamos el comando a través de Docker en modo interactivo.
```
docker exec -it my-mongo \
    mongosh --host localhost \
            -u admin \
            -p password
```
Una vez dentro de la terminal de Mongosh, ejecutamos los siguientes comandos:
```
use Library
db.createCollection("Books")
```
Para comprobar la correcta creación de la base de datos y la colección, puedes ejecutar el comando show seguido de las palabras clave databases o collections.
```shell
test> show databases
Library   40.00 KiB
admin    100.00 KiB
config   108.00 KiB
local     72.00 KiB
test> use Library
switched to db Library
Library> show collections
Books
```


## Importar datos desde fichero a una colección de MongoDB
Primero copiamos el fichero al contenedor.
```
docker cp books.json my-mongo:/tmp
```
En segundo lugar, abrimos una shell para trabajar dentro del contenedor y ejecutamos los siguientes comandos.
```
docker exec -it my-mongo sh

mongoimport --port 27017 -u admin -p password --authenticationDatabase admin -d Library -c Books --file /tmp/books.json
```

Por último, lanzamos el siguiente comando para que devuelva los datos importados.

```
docker exec my-mongo \
    mongosh --host localhost \
            -u admin \
            -p password \
            --authenticationDatabase admin \
            --quiet \
            --eval 'use Library' \
            --eval 'printjson(db.Books.find())'
```
```shell
[
  {
    _id: ObjectId("65199635ba97c0016167999d"),
    title: 'Docker in Action, Second Edition',
    author: 'Jeff Nickoloff and Stephen Kuenzli'
  },
  {
    _id: ObjectId("65199635ba97c0016167999e"),
    title: 'Kubernetes in Action, Second Edition ',
    author: 'Marko Lukša'
  }
]
```

# Ejercicio 2
Ejecutamos el siguiente comando para crear una instancia de Nginx.
```
docker run -d --name lemoncoders-web \
    -p 9999:80 \
    nginx:latest
```

Copiamos el contenido de la carpeta lemoncoders-web al contenedor de Nginx.
```
docker cp lemoncoders-web/. lemoncoders-web:/usr/share/nginx/html/
```

Comprobamos que la copia se ha realizado satisfactoriamente.
```shell
$ docker exec lemoncoders-web ls //usr/share/nginx/html/
50x.html
index.html
styles.css
```

*Nota: Se ha añadido una barra / adicional en la ruta del comando anterior para deshabilitar la conversión automática del path de Git Bash que daba un error similar al siguiente*
```shell
$ docker exec lemoncoders-web ls /usr/share/nginx/html/
ls: cannot access 'C:/Program Files/Git/usr/share/nginx/html/': No such file or directory
```

# Ejercicio 3
Si ejecutamos el siguiente comando, vemos que tenemos dos contenedores activos.
```shell
$ docker ps -a

CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                      NAMES
5e8129b4f763   nginx:latest   "/docker-entrypoint.…"   29 minutes ago   Up 29 minutes   0.0.0.0:9999->80/tcp       lemoncoders-web
daf02ff0c276   mongo:latest   "docker-entrypoint.s…"   2 hours ago      Up 2 hours      0.0.0.0:27017->27017/tcp   my-mongo
```

Para parar todos los contenedores a la vez podemos ejecutar el siguiente comando.
```
docker stop $(docker ps -aq)
```

Si volvemos a ejecutar el comando anterior, vemos que ya no están activos.
```shell
$ docker ps -a

CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS                      PORTS     NAMES
5e8129b4f763   nginx:latest   "/docker-entrypoint.…"   32 minutes ago   Exited (0) 17 seconds ago             lemoncoders-web
daf02ff0c276   mongo:latest   "docker-entrypoint.s…"   2 hours ago      Exited (0) 17 seconds ago             my-mongo
```

Si queremos eliminarlos por completo del sistema, podemos ejecutar el siguiente comando.

```
docker rm $(docker ps -aq)
```

Si queremos eliminar los contenedores mientras están en ejecución, podemos añadir la opción *-f* al comando rm, que forzará en primer lugar la detención de los contenedores utilizando la señal SIGKILL.