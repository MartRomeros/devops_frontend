# Front Despacho

Aplicacion frontend construida con React y Vite para gestionar compras y despachos. La interfaz permite consultar ventas pendientes, generar despachos asociados y cerrar despachos existentes.

## Stack

- React 18
- Vite 5
- Axios
- React Hook Form
- Tailwind CSS
- Docker
- nginx

## Variables de entorno

La aplicacion consume dos servicios backend:

- `VENTAS`: operaciones sobre ventas y compras
- `DESPACHOS`: operaciones sobre despachos

Para desarrollo local, Vite puede leer estas variables desde un archivo `.env`:

```env
VITE_VENTAS_API_URL=http://localhost:8082/api/v1
VITE_DESPACHOS_API_URL=http://localhost:8081/api/v1
```

Existe un ejemplo base en [.env.example](/C:/Users/marti/Desktop/devops/front_despacho/.env.example).

Para ejecucion en contenedor, la imagen usa variables de runtime:

- `APP_VENTAS_API_URL`
- `APP_DESPACHOS_API_URL`
- `PRIVATE_VENTAS_API_URL`
- `PRIVATE_DESPACHOS_API_URL`

Si no se definen, el contenedor usa estos valores por defecto:

- `APP_VENTAS_API_URL=/api/ventas`
- `APP_DESPACHOS_API_URL=/api/despachos`
- `PRIVATE_VENTAS_API_URL=http://localhost:8082/api/v1`
- `PRIVATE_DESPACHOS_API_URL=http://localhost:8081/api/v1`

## Instalacion de dependencias

Requisitos:

- Node.js 20 o superior
- npm 10 o superior

Instalacion:

```bash
npm ci
```

## Ejecucion local

1. Crear archivo `.env` a partir de `.env.example` si necesitas cambiar endpoints.
2. Instalar dependencias con `npm ci`.
3. Levantar el entorno de desarrollo:

```bash
npm run dev
```

4. Abrir la URL que entregue Vite, normalmente `http://localhost:5173`.

## Build local

Para generar los archivos estaticos:

```bash
npm run build
```

Para previsualizar el build:

```bash
npm run preview
```

## Ejecucion con Docker

La imagen usa un `Dockerfile` multistage:

1. Etapa `builder`: instala dependencias y ejecuta `npm run build`.
2. Etapa final: usa `nginx:alpine` para servir el contenido de `dist/`.
3. En el arranque del contenedor se genera `config.js` con los endpoints definidos por variables de entorno.

### Construir la imagen

```bash
docker build -t front-despacho .
```

### Ejecutar el contenedor

```bash
docker run --rm -p 8080:80 ^
  -e APP_VENTAS_API_URL=/api/ventas ^
  -e APP_DESPACHOS_API_URL=/api/despachos ^
  -e PRIVATE_VENTAS_API_URL=http://host.docker.internal:8082/api/v1 ^
  -e PRIVATE_DESPACHOS_API_URL=http://host.docker.internal:8081/api/v1 ^
  front-despacho
```

En sistemas tipo Unix, el mismo comando seria:

```bash
docker run --rm -p 8080:80 \
  -e APP_VENTAS_API_URL=/api/ventas \
  -e APP_DESPACHOS_API_URL=/api/despachos \
  -e PRIVATE_VENTAS_API_URL=http://host.docker.internal:8082/api/v1 \
  -e PRIVATE_DESPACHOS_API_URL=http://host.docker.internal:8081/api/v1 \
  front-despacho
```

Luego la aplicacion quedara disponible en `http://localhost:8080`.

## Como funciona la configuracion runtime

La aplicacion carga `/config.js` antes del bundle principal. Ese archivo es generado por `nginx` al iniciar el contenedor y expone:

```js
window.__APP_CONFIG__ = {
  APP_VENTAS_API_URL: "/api/ventas",
  APP_DESPACHOS_API_URL: "/api/despachos",
};
```

Con esto, el navegador llama al mismo host publico del frontend y nginx reenvia las peticiones hacia las APIs configuradas en `PRIVATE_VENTAS_API_URL` y `PRIVATE_DESPACHOS_API_URL`.

## Frontend publico y APIs privadas

Cuando el frontend se sirve desde una EC2 publica y las APIs estan en una EC2 privada, el navegador no debe consumir directamente la IP privada. En su lugar, la app llama rutas relativas del nginx publico:

```text
/api/ventas/ventas
/api/despachos/despachos
```

Dentro del contenedor, nginx hace reverse proxy hacia las APIs privadas:

```text
/api/ventas/     -> PRIVATE_VENTAS_API_URL
/api/despachos/  -> PRIVATE_DESPACHOS_API_URL
```

Ejemplo para AWS:

```text
APP_VENTAS_API_URL=/api/ventas
APP_DESPACHOS_API_URL=/api/despachos
PRIVATE_VENTAS_API_URL=http://10.0.2.15:8082/api/v1
PRIVATE_DESPACHOS_API_URL=http://10.0.2.16:8081/api/v1
```

La EC2 publica debe poder conectarse por red privada a la EC2 privada. El Security Group de la EC2 privada debe permitir entrada a los puertos de las APIs solo desde el Security Group de la EC2 publica.

## Pipeline CI/CD

El workflow principal esta en [.github/workflows/deploy.yaml](/C:/Users/marti/Desktop/devops/front_despacho/.github/workflows/deploy.yaml). Se ejecuta cuando hay un push a la rama `master`.

El flujo del pipeline es:

1. GitHub Actions descarga el repositorio.
2. Configura Node.js 20.
3. Instala dependencias con `npm ci`.
4. Compila el frontend con `npm run build`.
5. Configura Docker Buildx.
6. Inicia sesion en Docker Hub.
7. Construye la imagen desde el `Dockerfile` de la raiz.
8. Publica la imagen en Docker Hub con estos tags:

```text
<DOCKERHUB_USERNAME>/front-despacho:latest
<DOCKERHUB_USERNAME>/front-despacho:<github.sha>
```

9. Se conecta por SSH al EC2.
10. Verifica que el EC2 tenga `git` y `docker`.
11. Si es primera ejecucion, clona el repositorio en el EC2.
12. Si ya existe el repositorio, hace pull de los cambios de `master`.
13. Hace `docker pull` de la imagen `latest`.
14. Elimina el contenedor anterior si existe.
15. Levanta el nuevo contenedor en el puerto `80`.

## Secrets para GitHub Actions

Configura estos valores en `Settings > Secrets and variables > Actions > Repository secrets`.

```text
DOCKERHUB_USERNAME=<usuario-dockerhub>
DOCKERHUB_TOKEN=<token-dockerhub>
EC2_HOST=<ip-publica-o-dns-publico-del-ec2>
EC2_USER=ubuntu
EC2_SSH_KEY=<contenido-completo-de-la-llave-privada-pem>
PRIVATE_VENTAS_API_URL=<url-privada-api-ventas>
PRIVATE_DESPACHOS_API_URL=<url-privada-api-despachos>
```

`EC2_HOST` normalmente es la IP publica de la instancia EC2, por ejemplo:

```text
EC2_HOST=18.222.10.55
```

Tambien puede ser el DNS publico de AWS:

```text
EC2_HOST=ec2-18-222-10-55.us-east-2.compute.amazonaws.com
```

`EC2_SSH_KEY` debe ser el contenido completo de la llave privada, incluyendo las lineas `BEGIN` y `END`:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

## Consideraciones para AWS Academy

En AWS Academy los laboratorios suelen reiniciarse o recrearse. Por eso algunos datos pueden cambiar y se deben revisar antes de ejecutar el pipeline:

- `EC2_HOST`: cambia si la instancia obtiene una nueva IP publica.
- `EC2_SSH_KEY`: puede cambiar si se crea una nueva key pair para el laboratorio.
- `EC2_USER`: para Ubuntu normalmente es `ubuntu`, pero conviene confirmarlo si se usa otra AMI.
- Security Group: debe permitir SSH `22` desde GitHub Actions o desde internet, y HTTP `80` para acceder al frontend.
- Security Group privado: debe permitir los puertos de las APIs desde la EC2 publica, por ejemplo `8081` y `8082`.
- `PRIVATE_VENTAS_API_URL` y `PRIVATE_DESPACHOS_API_URL`: cambian si se recrean las instancias privadas o cambian sus IP privadas.
- Docker y Git: deben estar instalados en la instancia EC2 antes del despliegue.

Si cambia la IP publica o la llave del laboratorio, actualiza los repository secrets en GitHub antes de hacer push a `master`.

## Archivos relevantes

- [Dockerfile](/C:/Users/marti/Desktop/devops/front_despacho/Dockerfile)
- [nginx/default.conf](/C:/Users/marti/Desktop/devops/front_despacho/nginx/default.conf)
- [docker/nginx.default.conf.template](/C:/Users/marti/Desktop/devops/front_despacho/docker/nginx.default.conf.template)
- [docker-entrypoint.d/40-generate-config.sh](/C:/Users/marti/Desktop/devops/front_despacho/docker-entrypoint.d/40-generate-config.sh)
- [src/config.js](/C:/Users/marti/Desktop/devops/front_despacho/src/config.js)
- [.github/workflows/deploy.yaml](/C:/Users/marti/Desktop/devops/front_despacho/.github/workflows/deploy.yaml)

## Notas

- Si los backends corren fuera del contenedor en tu maquina local, `host.docker.internal` suele ser la opcion correcta para Docker Desktop.
- En despliegues con APIs privadas, manten `APP_VENTAS_API_URL` y `APP_DESPACHOS_API_URL` como rutas relativas y ajusta `PRIVATE_VENTAS_API_URL` y `PRIVATE_DESPACHOS_API_URL` hacia las IPs privadas accesibles desde nginx.
