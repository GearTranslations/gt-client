# GearTranslations Client

El cliente(gt-api-client) se encarga cada día, a las 21 hs UTC, de observar si hubo cambios en los locales de los repositorios que se dieron de alta para su monitorización. Por cada repositorio se lee el archivo _geartranslations.yml_, de esa forma el cliente verifica dónde se encuentran los locales en dicho repositorio. Luego se procede a verificar, por cada locale, si hubo un cambio desde la última ejecución. En caso de que así sea, se genera un proyecto de traducción en el TMS de Gear Translations. Cuando el proyecto finaliza, se crea un Pull Request en el repositorio de dicho locale.

Un detalle a tener en cuenta es que, si existen PRs abiertos por el usuario para un locale, hasta que los mismos no se encuentren mergeados o declinados, el cliente no observará al locale involucrado.

## 1. Prerequisitos
1. Para instalar la siguiente aplicación, deberá contar con Docker instalado. Puede descargarse [aquí](https://www.docker.com/).
2. Deberá configurar su usuario de Bitbucket para poder consumir sus respectivos repositorios. (Explicado en los siguientes pasos)
3. Deberá crear los archivos de configuración necesarios para cada repositorio que desee observar. (Explicado en los siguientes pasos)


## 2. Usuario Bitbucket para el cliente

Para poder observar un repositorio de Bitbucket, es necesario un usuario con capacidad de lectura y escritura en el mismo, asociarlo como un miembro del repositorio y por último generar las credenciales para que el cliente lo pueda utilizar.

El cliente permite establecer qué usuario se utilizará para observar cada repositorio, por lo tanto, es posible tener tantos usuarios como repositorios o un único usuario para todos los repositorios. Es importante tener en cuenta que se requerirá crear credenciales(App Password) para cada usuario.

Los pasos a realizar en un repositorio de Bitbucket para agregar el usuario del cliente al repositorio son los siguientes:

1. Crear un usuario en Bitbucket o tomar uno existente
2. Al usuario del paso previo, se le debe asociar el repositorio que se desea observar. Para esto necesitamos ingresar a Bitbucket con un usuario que ya sea miembro del proyecto y tenga permisos para agregar nuevos usuarios.
  1. Ir al root del proyecto. En el menú lateral izquierdo nos vamos a Repository Settings -\&gt; User and group access y le damos a Add members, buscamos y agregamos el usuario.
  2. Es necesario darle permisos de escritura, para poder crear los pull requests.


`Nota: Esto es necesario realizarlo en cada repositorio.`

### Cómo generar las credenciales del usuario
Para cada usuario a utilizar para observar un repositorio es necesario crear un App Password.

1. Ingresar a Bitbucket.
2. Crear un [App Password](https://bitbucket.org/account/settings/app-passwords/).
  1. Es necesario seleccionar los permisos de repository:write y pullrequest:write
  2. Guardar este App Password en un sitio seguro.
3. Con el username y el App Password obtenido, vamos a poder utilizar la API de Bitbucket. Estos datos se van a requerir a la hora de dar de alta un repositorio en el cliente.
4. Para más detalles, podemos acceder a la documentación oficial de [bitbucket](https://developer.atlassian.com/bitbucket/api/2/reference/meta/authentication#app-pw).


## 3. Archivo de configuración

Es necesario agregar, en cada repositorio a observar, un archivo en el cual se indica la ubicación y los locales a observar, el formato del mismo, el idioma origen, el idioma destino y un tag específico que se establece para ser utilizado como marcador a futuro para indicar urgencias, prioridades tratamiento especial, etc.

Además, es necesario indicar el Access Token con el cual queremos crear los proyectos de traducción en el TMS de GearTranslations. Este Access Token se puede obtener o solicitar en la plataforma, y se encuentra asociado a un usuario de la misma.

El archivo debe de ser ubicado en el root del proyecto bajo el nombre de _geartranslations.yml_, a continuación se incluye un ejemplo.

```yml
geartranslations:

    tag: "URGENT"
    access_token: 'accesstoken'
    sources:
        - file:
            name: locales/fr.json
            locale: 'fr'
            aligned_from: 'es'
            format: 'json'
        - file:
            name: locales/en.json
            locale: 'en-uk'
            aligned_from: 'es'
            format: 'json'
```

Podemos encontrar un archivo de ejemplo similar en el root del cliente bajo el nombre de _example-geartranslations.yml._

## 4. Ejecutar el proyecto (Docker)

1. Clonar el repositorio
2. Establecer en el `docker-compose` las siguientes variables:
    - `ENCRYPTION_KEY`: Debe ser una key de 64 bits. Es utilizada para encriptar.
    - `ATTRIBUTE_ENCODING_KEY`: Debe ser una key de 32 bits de longitud.
    - `SECRET_KEY_BASE`: Debe ser una string aleatoria, en lo posible, de más de 100 bits.
3. Finalmente (con Docker ON), ejecutar los siguientes comandos en una terminal:
```
$ docker-compose build
$ docker-compose up
```

_NOTA: En caso de que el docker-compose up no cree la base de datos correctamente, será necesario correr lo siguientes comandos manualmente:_
```
$ docker-compose run gt-api-client rake db:create

$ docker-compose run gt-api-client rake db:migrate
```

De esta forma, tendremos al cliente corriendo en el puerto 3000. Además, en /sidekiq podemos ver los distintos jobs encargados de las diferentes tareas dentro del cliente.

En este momento, solo resta indicarle al cliente qué repositorios queremos observar.

## Alta de repositorios a observar

Para esto, es necesario armar un archivo llamado repositories.yml y pasarlo al contenedor del cliente, para luego correr una task que lo obtenga. Dentro del repositorio existe el archivo _example-repositories.yml_ como ejemplo de cómo debe de ser el file.

El archivo `repositories.yml` debe respetar el siguiente formato:

```yml
repositories:
  - repository:
      workspace: 'workspace'
      repository_name: 'mobile-api'
      branch: 'master'
      branch_pull_request_destination: 'master'
      user_name: 'user_name'
      app_password: 'app_password'
      server_url: 'https://server.bitbucket-url.com'
      platform: 'bitbucket'

```

Por cada repositorio a observar es necesario cargar workspace, nombre del repositorio, branch donde se encuentra el archivo _geartranslations.yml_, brach\_pull\_request\_destination para indicar la rama a la que se desean aplicar los cambios a la hora de crear el Pull Request, el usuario y su App Password, la url del servidor de Bitbucket y plataforma (en este caso, Bitbucket).

Una vez generado el file repositories.yml, lo copiamos en el contenedor(gt-api-client) y ejecutamos la tarea. Para esto, seguir los siguientes pasos:

1. docker ps # Nos permite obtener el container id de la imagen gt-api-client
2. docker cp repositories.yml \&lt;container id\&gt;:/app
3. docker exec \&lt;container id\&gt; rake repositories:load

La tarea agrega todos los repositorios o ninguno, por lo tanto evitar duplicados o existentes ya que la tarea fallará si sucede algo de lo mencionado.

## 5. Cómo actualizar el cliente

Es recomendado con cierta periodicidad actualizar el cliente para obtener las nuevas funcionalidades que el mismo puede ofrecer, como así también la resolución de bugs.

Cuando se desee realizar esto, es de suma importancia no modificar los valores de las variables de entorno `ENCRYPTION_KEY`, `ATTRIBUTE_ENCODING_KEY` y `SECRET_KEY_BASE`, ya que, si se modifican, no se podrán recuperar las credenciales encriptadas. Si sucediera esto, será necesario cargar nuevamente el Access Token y las credenciales de Bitbucket para cada repositorio.

Para esto es necesario obtener los últimos cambios del repositorio (GIT PULL) y armar nuevamente la imagen de Docker. Para realizar este paso, debemos seguir los siguientes pasos en el root del proyecto:

```
$ git pull origin main --rebase
$ docker-compose build
$ docker-compose up
```