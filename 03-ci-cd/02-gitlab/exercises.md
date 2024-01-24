# Ejercicios GitLab

### Preparación del entorno

Los ejercicios se realizan en un entorno local de GitLab. Para ello, hay que seguir los pasos indicados en el repositorio del bootcamp de Lemoncode: [GitLab - Creación del entorno](https://github.com/Lemoncode/bootcamp-devops-lemoncode/blob/master/03-cd/02-gitlab/README.md#creaci%C3%B3n-del-entorno).

Una vez levantado el entorno, podemos acceder a GitLab a través de la siguiente URL: [http://gitlab.local:8888/](http://gitlab.local:8888/).

A continuación, creamos un usuario de tipo *regular* y un grupo, al que tiene que pertenecer el anterior usuario creado, que utilizaremos como base para crear nuestros proyectos.

## Ejercicio 1 - CI/CD de una aplicación Spring

Creamos un nuevo proyecto en blanco en GitLab, llamado *springapp* dentro del grupo creado anteriormente.

![](./images/01_create_project.png)

Preparamos nuestro código fuente en nuestro repositorio local y añadimos en la raíz un fichero con nombre *.gitlab-ci.yml* que contendrá la definición de nuestra pipeline.

La primera parte es la encargada de definir los stages disponibles en la pipeline.

Nos indican que creemos cuatro stages:
 - maven:package
 - maven:verify
 - docker:build
 - deploy

No obstante, teniendo en cuenta el [funcionamiento de Maven](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#a-build-lifecycle-is-made-up-of-phases), nos podemos ahorrar la fase de package, ya que verify la va a ejecutar previamente. Por lo tanto, nuestros stages finalmente serán los siguientes 3.

```yaml
stages:
  - maven:verify
  - docker:build
  - deploy
```
A continuación se define cada uno de los stages. 

En primer lugar creamos el job de *maven:verify*, donde le indicamos:
 1. La imagen de Docker a utilizar para las fases de compilación, construcción y ejecución de pruebas. 
 2. El nombre del stage.
 3. Las tareas a realizar en el job.
 4. Se define qué ficheros se van a guardar como artefactos, en este caso solo los ficheros con extension *jar*.

```yaml
maven_verify_job:
  image: maven:3.8.8-eclipse-temurin-8
  stage: maven:verify
  script:
    - mvn clean verify
  artifacts:
    when: on_success
    paths:
      - "target/*.jar"
```

En segundo lugar, el job de *docker:build*, indicándole además del nombre y las tareas a realizar, su dependencia con el job de *maven:verify* a través del keyword [needs](https://docs.gitlab.com/ee/ci/yaml/#needsartifacts), pues necesita el artefacto para generar la imagen de Docker.

```yaml
docker_build_job:
  stage: docker:build
  needs:
    - maven_verify_job
  script:
    - docker build -t $CI_REGISTRY/$CI_PROJECT_PATH:$CI_COMMIT_SHA . 
```

En último lugar, el job de *deploy* realizará el despliegue en local. Para ello en primer lugar tiene que comprobar si el contenedor con nombre *springapp* está en ejecución y si lo está, lo elimina con el fin de asegurar que siempre se despliega la última versión. Por último, se ejecuta la aplicación.

```yaml
deploy_job:
  stage: deploy
  needs:
    - docker_build_job
  before_script:
    - if [[ "$(docker ps --filter "name=springapp" --format '{{.Names}}')" == "springapp" ]]; then  docker rm -f springapp;  fi
  script:
    - docker run --name "springapp" -d -p 8080:8080 $CI_REGISTRY/$CI_PROJECT_PATH:$CI_COMMIT_SHA
```

Finalmente, subimos todos los ficheros a nuestro repositorio remoto.

![](./images/02_add_files.png)

A continuación, nos vamos a la sección de *pipelines* de nuestro proyecto y vemos que está en ejecución.

![](./images/03_pipeline_build.png)

Una vez que la build haya terminado los 3 stages, debemos ver algo similar a lo siguiente.

![](./images/04_successful_build.png)

Comprobamos entonces que el despliegue se ha realizado correctamente. Para ello accedemos a la URL [http://localhost:8080/](http://localhost:8080/).

![](./images/05_springapp_url.png)

Por lo tanto, tenemos desplegado correctamente nuestro servicio.

Antes de seguir con el siguiente ejercicio, vamos a bichear un poco la pipeline.

![](./images/06_pipeline_breakdown.png)

Aquí podemos observar las dependencias entre cada una de las pipelines que coincide exactamente con lo que tenemos definido en nuestro fichero *.gitlab-ci.yml*.

Si hacemos click en *Jobs*, podemos re-ejecutar alguno de los stages en caso de ser necesario.

![](./images/07_pipeline_jobs.png)

Al ejecutar en cada uno de los jobs, podemos ver los logs, donde observamos que el stage de *maven:verify* ha subido un único artefacto y que *docker:build* se lo ha descargado.

![](./images/08_maven_upload.png)
![](./images/09_docker_download.png)

Por último, vamos a hacer un redespliegue del contenedor para comprobar que elimina el contenedor anterior y crea uno nuevo.

![](./images/10_deploy_retry.png)

El job se ha ejecutado de manera satisfactoria, por lo tanto si observamos los contenedores en ejecución utilizando el comando *docker ps* en el host, veremos que se ha creado recientemente.

```shell
$ docker ps --filter "name=springapp"
CONTAINER ID   IMAGE                                                                           COMMAND                  CREATED         STATUS         PORTS                    NAMES    
740cca2d4e95   gitlab.local:5001/bootcamp/springapp:52001cf17d49a0fdc90126ccb0914eacad2cd899   "/bin/sh -c 'exec ja…"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->8080/tcp   springapp
```

## Ejercicio 2 - Comprobación de permisos para diferentes roles

Para la realización de este ejercicio, vamos a crear un usuario nuevo.

A continuación vamos a darle permisos para ver el repositorio de *springapp*. Sin embargo, el proyecto pertenece a un grupo, por lo que tenemos dos opciones:
 - Dar permisos a nivel de grupo
 - Dar permisos a nivel de proyecto

Los permisos disponibles en GitLab son los siguientes:
 - Guest (solo aplicable a proyectos *privados* e *internos*)
 - Reporter
 - Developer
 - Maintainer
 - Owner

Si le asignamos permisos para el grupo, podrá ver el proyecto, pero también cualquier otro proyecto que exista dentro del grupo. Por lo tanto, hay que asignarle permisos al usuario solamente en el proyecto.

Para comprobar esto podemos ver qué puede ver cada usuario. El usuario *Daniel* tiene el rol *Owner* tanto del grupo como del proyecto, por lo tanto podrá ver todos los proyectos disponibles en el grupo *bootcamp*.

![](./images/11_projects_daniel.png)

Sin embargo, el usuario *Daniel2*, solo puede ver el proyecto *springapp*

![](./images/12_projects_daniel2.png)

A continuación, vamos a asignarle al usuario diferentes permisos y comprobar qué acciones de las siguientes puede realizar:
 - Hacer commit
 - Ejecución de pipelines de manera manual
 - Push del repositorio
 - Pull del repositorio
 - Crear Merge request
 - Acceder a la administración del repositorio

El resultado de las pruebas se puede consultar en la siguiente tabla.

|Rol|Pull|Commit|Push|Pipeline|Merge Request|Administración|
|-|-|-|-|-|-|-|
|Guest|❌|❌|❌|❌|❌|❌|
|Reporter|✔️|✔️|❌|❌|❌|❌|
|Developer|✔️|✔️|✔️|✔️|✔️|❌|
|Maintainer|✔️|✔️|✔️|✔️|✔️|✔️|

Para más información sobre los permisos disponibles para cada rol, se puede consultar la página de GitLab: [Permissions and Roles](https://docs.gitlab.com/ee/user/permissions.html).

Como conclusión podemos indicar que el rol *guest* sería apropiado para usuarios finales que necesiten ver por ejemplo la página wiki del repositorio, pero no queramos que tenga acceso al código fuente. El *reporter* podría ser útil por ejemplo para product owners, pues pueden por ejemplo gestionar *issues* y ver el código fuente, pero no hacer cambios sobre este. Por último, los roles *developer* y *maintainer* serían útiles para desarrolladores y technical leads respectivamente.

## Ejercicio 3 - Comprobación de permisos en las pipelines

En este ejercicio vamos a crear un segundo proyecto *springapp2* en el que vamos a clonar el repositorio de *springapp* utilizando dos métodos:
 - [CI/CD job token](https://docs.gitlab.com/ee/ci/jobs/ci_job_token.html)
 - [Deploy keys](https://docs.gitlab.com/ee/user/project/deploy_keys/)

### CI/CD job token

En el repositorio de código de *springapp*, vamos a autorizar que el proyecto *springapp2* pueda acceder a este.

> Settings &rarr; CI/CD &rarr; Token Access &rarr; Add project

Añadimos el proyecto personal introduciendo *Daniel2/springapp2*.

![](./images/14_token_access.png)

Comprobamos que el usuario *Daniel2* tiene acceso al repositorio, pues es un repositorio privado.

![](./images/13_project_members.png)

A continuación, nos vamos a nuestro proyecto *springapp2* para configurar una pipeline que haga el clonado a través del *CI_JOB_TOKEN*.

```yaml
before_script:
  - apk update && apk add git

stages:
  - clone

clone-job:
  stage: clone
  script:
    - git clone http://gitlab-ci-token:$CI_JOB_TOKEN@gitlab.local:8888/bootcamp/springapp.git
```

Al ejecutar vemos que el clonado se ha realizado de manera satisfactoria.

![](./images/15_clone_reporter.png)

Ahora le cambiamos el rol al usuario *Daniel2* de *reporter* a *guest* y volvemos a lanzar la pipeline.

![](./images/16_clone_guest.png)

Al no tener permisos de lectura sobre el repositorio, el clonado falla indicando que no tenemos permisos para descargar el código.

A continuación, eliminamos el usuario del proyecto.

![](./images/17_clone_no_member.png)

En este caso vuelve a fallar, pero en este caso debido a que ni siquiera tiene permisos para ver el proyecto en sí ya que es privado.

¿Y si hacemos el proyecto *springapp* interno?

![](./images/18_internal_project.png)

En este caso, independientemente de si somos miembros o no, podremos clonar el repositorio.

Finalmente, revocamos el acceso al proyecto *springapp2*, eliminamos el miembro *Daniel2* y lo volvemos a hacer privado.

### Deploy keys

En primer lugar vamos a crear nuestra clave SSH sin especificar passphrase, en caso de que no tengamos una. Para generarla, puedes seguir esta guía: [Generate an SSH key pair](https://docs.gitlab.com/ee/user/ssh.html#generate-an-ssh-key-pair).

A continuación, añadimos la clave privada a nuestro proyecto *springapp2* y la guardamos como fichero.

> Settings &rarr; CI/CD &rarr; Variables &rarr; Expand &rarr; Add variable

![](./images/19_ssh_key.png)

En el proyecto *springapp*, navegamos a la siguiente ruta para crear nuestra deploy key a la que no le vamos a dar permisos de escritura.

> Settings &rarr; Repository &rarr; Deploy keys &rarr; Expand &rarr; Add new key

![](./images/20_deploy_key.png)

A continuación, creamos nuestra pipeline con la siguiente definición.

```yaml
before_script:
  ## Instalación de ssh-agent en el contenedor de Docker
  - 'command -v ssh-agent >/dev/null || ( apt-get update -y && apt-get install openssh-client -y )'
  
  ## Ejecución de ssh-agent dentro del entorno
  - eval $(ssh-agent -s)
  
  ## Añadir la clave SSH_KEY al agente SSH
  - chmod 400 "$SSH_KEY"
  - ssh-add "$SSH_KEY"
  
  ## Creación del directorio SSH
  - mkdir -p ~/.ssh
  - chmod 700 ~/.ssh
  
  ## Añadir gitlab.local como host de confianza
  - ssh-keyscan gitlab.local >> ~/.ssh/known_hosts
  - chmod 644 ~/.ssh/known_hosts
  
  ## Instalación de git
  - apk update && apk add git


stages:
  - clone

clone-job:
  stage: clone
  script:
    - git clone git@gitlab.local:bootcamp/springapp.git
```

Tras ejecutar la pipeline podemos ver que se ha clonado el repositorio de manera satisfactoria.

![](./images/21_clone_ssh.png)

A diferencia del método anterior, el caso de uso de este método es para interacciones no humanas, como por ejemplo un script de automatización.