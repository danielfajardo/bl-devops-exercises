# Ejercicio 1

Creamos una red dentro de Docker llamada *lemoncode*.
```
docker network create lemoncode
```

Creamos dos contenedores dentro de esta red para comprobar la comunicación interna.

Primero arrancamos un servicio con Nginx.
```
docker run -d --name nginx-container \
    --network lemoncode \
    nginx
```

En segundo lugar arrancamos un contenedor con ubuntu.
```
docker run -dit --name ubuntu-container \
    --network lemoncode \
    ubuntu
```

Si ejecutamos *docker ps* vemos que tenemos los dos contenedores activos.
```shell
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS     NAMES
0d633c22f58a   ubuntu    "/bin/bash"              8 seconds ago    Up 7 seconds              ubuntu-container
0cd6fa01e9fd   nginx     "/docker-entrypoint.…"   12 minutes ago   Up 12 minutes   80/tcp    nginx-container
```

Si inspeccionamos la red *lemoncode* observamos que tenemos dos contenedores, cuyas IPs son *172.18.0.2 *y *172.18.0.3* para nginx y ubuntu respectivamente.

```shell
$ docker inspect lemoncode
[
    {
        "Name": "lemoncode",
        "Id": "ecec12401b8519b401e8ee15ceb4f5ff007c3793f7e0e16d0c050c8e3886d09a",
        "Created": "2023-10-11T08:07:43.475346314Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
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
            "0cd6fa01e9fd585299b80bef66b4665d0058d6e390bb35f8f8b65ddd9f76748c": {
                "Name": "nginx-container",
                "EndpointID": "6a842e81892ec87d15fc27a066b362fa33adc878b75f6d36810f4ee9606258a8",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            },
            "0d633c22f58af23f57e29a2e2251081e64cd1a50b942bd12395c40fd1e7730fa": {
                "Name": "ubuntu-container",
                "EndpointID": "96fd0bd155d01f130e71bba8eea3c7ec2e3da7e59f5686785b7525aaa1f5fe24",
                "MacAddress": "02:42:ac:12:00:03",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

Nos conectamos al ubuntu container para comprobar la conectividad.

```
docker exec -it ubuntu-container sh
```

Pero antes hay que instalar los paquetes para utilizar los comandos *ping* y *cURL*.

```shell
apt update && apt upgrade
apt -y install curl
apt -y install iputils-ping
```

Una vez instalados comprobamos la conectividad del contenedor de ubuntu con nginx.
```shell
# ping 172.18.0.2
PING 172.18.0.2 (172.18.0.2) 56(84) bytes of data.
64 bytes from 172.18.0.2: icmp_seq=1 ttl=64 time=12.4 ms
64 bytes from 172.18.0.2: icmp_seq=2 ttl=64 time=0.210 ms
64 bytes from 172.18.0.2: icmp_seq=3 ttl=64 time=0.614 ms
^C
--- 172.18.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2062ms
rtt min/avg/max/mdev = 0.210/4.396/12.365/5.637 ms
```

¡Tenemos conectividad! 

Ahora vamos a probar utilizando las DNS internas de Docker, ya que la red ha sido creada manualmente por nosotros y nos podemos beneficiar de estas.
```shell
# ping nginx-container
PING nginx-container (172.18.0.2) 56(84) bytes of data.
64 bytes from nginx-container.lemoncode (172.18.0.2): icmp_seq=1 ttl=64 time=0.125 ms
64 bytes from nginx-container.lemoncode (172.18.0.2): icmp_seq=2 ttl=64 time=0.083 ms
64 bytes from nginx-container.lemoncode (172.18.0.2): icmp_seq=3 ttl=64 time=0.070 ms
^C
--- nginx-container ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2083ms
rtt min/avg/max/mdev = 0.070/0.092/0.125/0.023 ms
```

Una vez comprobada la conectividad, pasamos a realizar una petición HTTP al servidor y ver su respuesta.
```shell
# curl nginx-container
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Nos ha devuelto la página por defecto de Nginx, por lo que concluimos que todo está funcionando correctamente.