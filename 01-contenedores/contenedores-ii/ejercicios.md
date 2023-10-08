# Ejercicio 1
## Creación de fichero Dockerfile
Primeramente buscamos la imagen de Apache HTTP Server en [Docker Hub](https://hub.docker.com/_/httpd) y seleccionamos la que nos interese, por ejemplo la versión *2.4.57*.

Creamos el fichero Dockerfile y le añadimos la imagen base desde donde construiremos nuestra imagen final.

```
FROM httpd:2.4.57-alpine
```

Añadimos las labels que queramos

```
LABEL maintainer="https://github.com/danielfajardo"
LABEL project="bootcamp-devops-lemoncode"
LABEL version="0.1.0"
```

Exponemos el puerto que utilizará la imagen.
```
EXPOSE 80
```

Finalmente copiamos los ficheros de la web a la imagen base.
```
COPY content/. /usr/local/apache2/htdocs/
```

Por último, ejecutamos los siguientes comandos para construir y ejecutar nuestra imagen.
```
docker build -t simple-apache:new .
```

Tras finalizar el comando, si todo ha ido correctamente, deberemos ver un resultado similar al siguiente en nuestra shell.
```shell
[+] Building 6.5s (7/7) FINISHED                                                                                                                                                              docker:default
 => [internal] load .dockerignore                                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                                         0.0s 
 => [internal] load build definition from Dockerfile                                                                                                                                                    0.1s 
 => => transferring dockerfile: 242B                                                                                                                                                                    0.0s 
 => [internal] load metadata for docker.io/library/httpd:2.4.57-alpine                                                                                                                                  2.2s 
 => [internal] load build context                                                                                                                                                                       0.1s
 => => transferring context: 466B                                                                                                                                                                       0.0s 
 => [1/2] FROM docker.io/library/httpd:2.4.57-alpine@sha256:02a928bf7db1a0baeebb01cb24c25237a111bbf2c43d5fa42eda6b41568dff41                                                                            3.8s 
 => => resolve docker.io/library/httpd:2.4.57-alpine@sha256:02a928bf7db1a0baeebb01cb24c25237a111bbf2c43d5fa42eda6b41568dff41                                                                            0.1s 
 => => sha256:02a928bf7db1a0baeebb01cb24c25237a111bbf2c43d5fa42eda6b41568dff41 1.65kB / 1.65kB                                                                                                          0.0s
 => => sha256:91bb108409cbcbc423565d2f2d0622a9eacf67d0adcb5e987e3a3fd8e4bc9a5d 1.57kB / 1.57kB                                                                                                          0.0s 
 => => sha256:455844a3909290903168b21eef4045aed972e64702105b6c79fe5c078b30c420 9.04kB / 9.04kB                                                                                                          0.0s 
 => => sha256:96526aa774ef0126ad0fe9e9a95764c5fc37f409ab9e97021e7b4775d82bf6fa 3.40MB / 3.40MB                                                                                                          0.5s 
 => => sha256:b3dd1fa329807111056d657121001901fcf2fe523b7ea48676de3d98f3689fbf 1.26kB / 1.26kB                                                                                                          0.3s 
 => => sha256:14ea5955682c77b24ee54e5e554c1b038e6cf752ced05cd5a06af6be8da634f9 177B / 177B                                                                                                              0.2s 
 => => sha256:68d0cfd9417970779cbf75ef9b812b27269d9f539f6d662b8972ec71eecf0433 9.87MB / 9.87MB                                                                                                          1.4s
 => => sha256:9a2127eda58eff3011383af0f677364796cc5178fcf2b88c5fb40fa28c5447e4 4.98MB / 4.98MB                                                                                                          1.1s
 => => extracting sha256:96526aa774ef0126ad0fe9e9a95764c5fc37f409ab9e97021e7b4775d82bf6fa                                                                                                               0.6s
 => => sha256:1887458c92fdfdaf14545198b8f8c8abc337fc15116271585367b2fe44845e00 291B / 291B                                                                                                              0.9s 
 => => extracting sha256:b3dd1fa329807111056d657121001901fcf2fe523b7ea48676de3d98f3689fbf                                                                                                               0.0s
 => => extracting sha256:14ea5955682c77b24ee54e5e554c1b038e6cf752ced05cd5a06af6be8da634f9                                                                                                               0.0s 
 => => extracting sha256:68d0cfd9417970779cbf75ef9b812b27269d9f539f6d662b8972ec71eecf0433                                                                                                               1.2s
 => => extracting sha256:9a2127eda58eff3011383af0f677364796cc5178fcf2b88c5fb40fa28c5447e4                                                                                                               0.4s
 => => extracting sha256:1887458c92fdfdaf14545198b8f8c8abc337fc15116271585367b2fe44845e00                                                                                                               0.0s 
 => [2/2] COPY content/. /usr/local/apache2/htdocs/                                                                                                                                                     0.2s 
 => exporting to image                                                                                                                                                                                  0.1s 
 => => exporting layers                                                                                                                                                                                 0.0s 
 => => writing image sha256:5faab3a74ba6c4713aebbee23a6df9a3e5aca464f97db33d86c0230a17ea9591                                                                                                            0.0s 
 => => naming to docker.io/library/simple-apache:new                                                                                                                                                    0.0s 
```

Si comprobamos las imágenes que tenemos disponible en nuestro repositorio veremos que simple-apache con tag new se acaba de añadir.
```shell
$ docker images simple*
REPOSITORY      TAG       IMAGE ID       CREATED         SIZE
simple-apache   new       5faab3a74ba6   3 minutes ago   59.2MB
```

# Ejercicio 2
Para ejecutar la imagen creada en el ejercicio 1, simplemente tenemos que ejecutar el siguiente comando.
```
docker run -d --name my-apache \
            -p 5050:80 \
            simple-apache:new
```

Si comprobamos los contenedores activos en Docker, vemos que el servidor está UP.
```shell
$ docker ps -a
CONTAINER ID   IMAGE               COMMAND              CREATED          STATUS         PORTS                  NAMES
b9c28c8fcecc   simple-apache:new   "httpd-foreground"   10 seconds ago   Up 9 seconds   0.0.0.0:5050->80/tcp   my-apache
```

Finalmente hacemos una llamada al servidor y vemos que nos responde correctamente.
```shell
$ curl http://localhost:5050/
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link href="site.css" rel="stylesheet" />
</head>

<body>
    I'm inside of a container. Help!
</body>

</html>
```

# Ejercicio 3
Para averiguar el número de capas que tiene una imagen podemos utilizar los comandos *history* e *inspect*.

El comando history nos devuelve cómo se ha construido la imagen.

```shell
$ docker history simple-apache:new
IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
5faab3a74ba6   13 minutes ago   COPY content/. /usr/local/apache2/htdocs/ # …   343B      buildkit.dockerfile.v0
<missing>      13 minutes ago   EXPOSE map[80/tcp:{}]                           0B        buildkit.dockerfile.v0
<missing>      13 minutes ago   LABEL version=0.1.0                             0B        buildkit.dockerfile.v0
<missing>      13 minutes ago   LABEL project=bootcamp-devops-lemoncode         0B        buildkit.dockerfile.v0
<missing>      13 minutes ago   LABEL maintainer=https://github.com/danielfa…   0B        buildkit.dockerfile.v0
<missing>      9 days ago       /bin/sh -c #(nop)  CMD ["httpd-foreground"]     0B
<missing>      9 days ago       /bin/sh -c #(nop)  EXPOSE 80                    0B
<missing>      9 days ago       /bin/sh -c #(nop) COPY file:c432ff61c4993ecd…   138B
<missing>      9 days ago       /bin/sh -c #(nop)  STOPSIGNAL SIGWINCH          0B
<missing>      9 days ago       /bin/sh -c set -eux;   apk add --no-cache --…   14.8MB
<missing>      9 days ago       /bin/sh -c #(nop)  ENV HTTPD_PATCHES=rewrite…   0B
<missing>      9 days ago       /bin/sh -c #(nop)  ENV HTTPD_SHA256=dbccb84a…   0B
<missing>      9 days ago       /bin/sh -c #(nop)  ENV HTTPD_VERSION=2.4.57     0B
<missing>      9 days ago       /bin/sh -c set -eux;  apk add --no-cache   a…   37MB
<missing>      9 days ago       /bin/sh -c #(nop) WORKDIR /usr/local/apache2    0B
<missing>      9 days ago       /bin/sh -c mkdir -p "$HTTPD_PREFIX"  && chow…   0B
<missing>      9 days ago       /bin/sh -c #(nop)  ENV PATH=/usr/local/apach…   0B
<missing>      9 days ago       /bin/sh -c #(nop)  ENV HTTPD_PREFIX=/usr/loc…   0B
<missing>      9 days ago       /bin/sh -c set -x  && adduser -u 82 -D -S -G…   4.68kB
<missing>      9 days ago       /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B
<missing>      9 days ago       /bin/sh -c #(nop) ADD file:756183bba9c7f4593…   7.34MB
```

Vemos que hay 6 comandos cuyo size es mayor que 0B y uno que crea una carpeta que tiene 0B. Por lo tanto, intuimos que serán 7 capas.

Vamos a inspeccionar la imagen para comprobar si la suposición es correcta.
```shell
$ docker inspect simple-apache:new | jq ".[].RootFS.Layers"
[
  "sha256:cc2447e1835a40530975ab80bb1f872fbab0f2a0faecf2ab16fbbb89b3589438",
  "sha256:c41dd6334a712b8e19dfe31eb3ee9a5e5f8620a96cb85f1bf3303c0e29921703",
  "sha256:77bf3ef7f3a295c8ea05bc7ad1ef43bddc1ab96a848b9f3763c78b424fe6e39d",
  "sha256:52d4c13e48af021ad6b5b2e5d143c9c42f74ed998d648dfece564d390f32c974",
  "sha256:2c605fadae9d98d39519fb2665e6af48816b11a1e595eaf57f504764a36bc75d",
  "sha256:103ae3929c6fc5f3ba3215bf680cc2f5a14fe2829446b557d2d831923e315d95",
  "sha256:e1513aced696e740deb219274a2e75f495087ebde3e19d51a30ad6aa2604aec4"
]
```

Vemos que efectivamente hay 7 capas en nuestra imagen simple-apache:new.