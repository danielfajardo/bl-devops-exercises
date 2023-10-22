# Ejercicio 1

El ejercicio consiste en dockerizar la aplicación de [lemoncode-challenge](https://github.com/Lemoncode/bootcamp-devops-lemoncode/tree/master/01-contenedores/lemoncode-challenge), compuesta de 3 partes:

    * Base de datos: MongoDB
    * Backend: .NET
    * Frontend: Node.js

En primer lugar, vamos a crear la red donde se comunicarán los 3 servicios.
```
docker network create lemoncode-challenge
```

## Configuración de Base de Datos

Levantamos la instancia de MongoDB, indicando la red en la que se va a instanciar, el hostname con el que le atacaremos y el volumen que utilizaremos para persistir los datos.
```
docker run -d --name mongodb \
            --network lemoncode-challenge \
            --hostname some-mongo \
            -v mongodb_data:/data/db \
            -e MONGO_INITDB_ROOT_USERNAME=admin \
            -e MONGO_INITDB_ROOT_PASSWORD=password \
            mongo:7.0.2
```

Nos conectamos a Mongo para crear la arquitectura de la base de datos.
```shell
$ docker exec -it mongodb \
    mongosh --host some-mongo \
            -u admin \
            -p password

test> show dbs
admin   100.00 KiB
config   12.00 KiB
local    72.00 KiB
```

Creamos la colección dentro de la base de datos e insertamos algunos datos para comprobar el correcto funcionamiento.

```shell

test> use TopicstoreDb
switched to db TopicstoreDb
TopicstoreDb> db.createCollection("Topics")
{ ok: 1 }
TopicstoreDb> db.Topics.insertMany([{"Name":"Docker"},{"Name":"Kubernetes"},{"Name":"Kafka"},{"Name":"Snowflake"}])
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId("65266d8b9b9becb93c4d6a2e"),
    '1': ObjectId("65266d8b9b9becb93c4d6a2f"),
    '2': ObjectId("65266d8b9b9becb93c4d6a30"),
    '3': ObjectId("65266d8b9b9becb93c4d6a31")
  }
}
TopicstoreDb> db.Topics.find()
[
  { _id: ObjectId("65266d8b9b9becb93c4d6a2e"), Name: 'Docker' },
  { _id: ObjectId("65266d8b9b9becb93c4d6a2f"), Name: 'Kubernetes' },
  { _id: ObjectId("65266d8b9b9becb93c4d6a30"), Name: 'Kafka' },
  { _id: ObjectId("65266d8b9b9becb93c4d6a31"), Name: 'Snowflake' }
]
```

Reiniciamos el contenedor y observamos si la configuración realizada permanece correcta.
```shell
$ docker restart mongodb
mongodb

$ docker exec -it mongodb \
>     mongosh --host some-mongo \
>             -u admin \
>             -p password

test> show dbs
TopicstoreDb   48.00 KiB
admin         100.00 KiB
config        108.00 KiB
local          72.00 KiB
test> use TopicstoreDb
switched to db TopicstoreDb
TopicstoreDb> db.Topics.find()
[
  { _id: ObjectId("65266d8b9b9becb93c4d6a2e"), Name: 'Docker' },
  { _id: ObjectId("65266d8b9b9becb93c4d6a2f"), Name: 'Kubernetes' },
  { _id: ObjectId("65266d8b9b9becb93c4d6a30"), Name: 'Kafka' },
  { _id: ObjectId("65266d8b9b9becb93c4d6a31"), Name: 'Snowflake' }
]
```

Vemos que la información sigue estando disponible, por lo que seguimos con el siguiente punto.

## Configuración de Backend

Generamos con VSCode la plantilla del Dockerfile y lo editamos para que funcione en la estructura de este repositorio, quedando así:

```docker
FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:3.1 AS build
ARG configuration=Release
WORKDIR /src
COPY ["dotnet-stack/backend/backend.csproj", "./"]
RUN dotnet restore "backend.csproj"
COPY ./dotnet-stack/backend/ .
WORKDIR "/src/."
RUN dotnet build "backend.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "backend.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "backend.dll"]
```

Editamos dentro del fichero *appsettings.json* el *ConnectionString* para añadirle la autenticación de MongoDB y el hostname correcto, quedando así:

```json
{
  "TopicstoreDatabaseSettings": {
    "ConnectionString": "mongodb://admin:password@some-mongo:27017",
    "TopicsCollectionName": "Topics",
    "DatabaseName": "TopicstoreDb"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "AllowedHosts": "*"
}

```

Construimos la imagen con el siguiente comando.
```
docker build -f Dockerfile.backend -t backend:0.0.1 .
```

Comprobamos que se ha creado correctamente.
```shell
$ docker images backend
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
backend      0.0.1     2cb597dcb63e   2 minutes ago   214MB
```

Finalmente levantamos el contenedor, asignándole la red deseada y el hostname para atacar posteriormente desde el frontend.
```
docker run -d --name backend \
            --network lemoncode-challenge \
            --hostname topics-api \
            backend:0.0.1
```

## Configuración del Frontend

Generamos con VSCode la plantilla del Dockerfile y lo editamos para que funcione en la estructura de este repositorio, quedando así:

```docker
FROM node:lts-alpine

ENV NODE_ENV=production

WORKDIR /usr/src/app

COPY ["dotnet-stack/frontend/package.json", "dotnet-stack/frontend/package-lock.json*", "dotnet-stack/frontend/npm-shrinkwrap.json*", "./"]

RUN npm install --production --silent && mv node_modules ../

COPY ./dotnet-stack/frontend/ .

EXPOSE 3000

RUN chown -R node /usr/src/app

USER node

CMD ["npm", "start"]
```

Construimos la imagen con el siguiente comando.
```
docker build -f Dockerfile.frontend -t frontend:0.0.1 .
```

Comprobamos que se ha creado correctamente.
```shell
$ docker images frontend
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
frontend     0.0.1     1e2fca4b8e1c   9 seconds ago   193MB
```

Finalmente levantamos el contenedor, asignándole la red deseada, el puerto al que vamos a atacar desde el host y la variable de entorno *API_URI* para que ataque al endpoint correcto del backend.
```
docker run -d --name frontend \
            --network lemoncode-challenge \
            -p 8080:3000 \
            -e API_URI='http://topics-api:5000/api/topics' \
            frontend:0.0.1
```

## Comprobación del sistema

Una vez realizados todos los pasos anteriores, revisamos una vez más que los 3 contenedores estén activos.

```shell
$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                    NAMES
7a999f860dfc   frontend:0.0.1   "docker-entrypoint.s…"   28 minutes ago   Up 28 minutes   0.0.0.0:8080->3000/tcp   frontend
a2bd12c94d11   backend:0.0.1    "dotnet backend.dll"     35 minutes ago   Up 35 minutes   5000/tcp                 backend
271b1af309f7   mongo:7.0.2      "docker-entrypoint.s…"   37 minutes ago   Up 37 minutes   27017/tcp                mongodb
```

Revisamos la red creada y que los 3 contenedores estén en ella.

```shell
$ docker network inspect lemoncode-challenge
[
    {
        "Name": "lemoncode-challenge",
        "Id": "2060464a8a18cf3388580d53c882ecfa2d3e0c6e7a2b0bc2fd7fd469427539cf",
        "Created": "2023-10-11T08:57:15.498027213Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.19.0.0/16",
                    "Gateway": "172.19.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "271b1af309f7218dd12756b00471d062678673ebdb15792e618ee127099b00a0": {
                "Name": "mongodb",
                "EndpointID": "94f1582869a8078cebfa7c1c360dd43e98bb3148e26af3d78a2451099370caf4",
                "MacAddress": "02:42:ac:13:00:02",
                "IPv4Address": "172.19.0.2/16",
                "IPv6Address": ""
            },
            "7a999f860dfcd7c55f761db3d33344abd8647ae000360c26d8b91e5ea344e432": {
                "Name": "frontend",
                "EndpointID": "90bcaf07ce6d9a795e31918f1074c7a0a88a83e1f703a47718051bc141f8b714",
                "MacAddress": "02:42:ac:13:00:04",
                "IPv4Address": "172.19.0.4/16",
                "IPv6Address": ""
            },
            "a2bd12c94d118c28ca9eae8b1e76730e2aad24f7024d1e925dd14f7cf5d4e6f9": {
                "Name": "backend",
                "EndpointID": "8b3d73f2b373bc6b047733adb7c1c0e01a61d457fe293ac5323126c88dbdb710",
                "MacAddress": "02:42:ac:13:00:03",
                "IPv4Address": "172.19.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

Accedemos la URL [http://localhost:8080/](http://localhost:8080/) para ver el contenido expuesto por el frontend, que debe coincidir con los datos introducidos en la configuración de la DB.

![](images/frontend.png)

¡Listo! ¡Ya tenemos nuestra app funcionando!