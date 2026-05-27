# Front Despacho

Frontend React + Vite para consultar ventas pendientes, generar ordenes de despacho y cerrar despachos. La aplicacion se construye como archivos estaticos y se sirve con nginx dentro de un contenedor Docker.

## Stack

- React 18
- Vite 5
- Axios
- React Hook Form
- Tailwind CSS
- Docker multistage
- nginx

## Arquitectura actual

En produccion, el frontend se despliega en una EC2 publica y consume APIs que pueden estar en una EC2 privada.

```text
Navegador
  -> EC2 publica / nginx / contenedor frontend
  -> reverse proxy nginx
  -> APIs privadas en la VPC
```

El navegador no llama directamente a las IPs privadas. React llama rutas relativas del mismo host publico:

```text
/api/ventas
/api/despachos
```

nginx reenvia esas rutas a los endpoints privados configurados en runtime:

```text
/api/ventas/     -> PRIVATE_VENTAS_API_URL
/api/despachos/  -> PRIVATE_DESPACHOS_API_URL
```

## Variables

Para desarrollo local con Vite puedes usar [.env.example](/C:/Users/marti/Desktop/devops/front_despacho/.env.example):

```env
VITE_VENTAS_API_URL=http://localhost:8082/api/v1
VITE_DESPACHOS_API_URL=http://localhost:8081/api/v1
```

Para contenedor se usan variables de runtime:

```text
APP_VENTAS_API_URL=/api/ventas
APP_DESPACHOS_API_URL=/api/despachos
PRIVATE_VENTAS_API_URL=http://10.0.2.15:8082/api/v1
PRIVATE_DESPACHOS_API_URL=http://10.0.2.16:8081/api/v1
```

`APP_*` son las rutas que usa el navegador. `PRIVATE_*` son las URLs reales que nginx puede alcanzar desde la EC2 publica hacia la red privada.

## Instalacion Local

Requisitos:

- Node.js 20 o superior
- npm 10 o superior

Instalar dependencias:

```bash
npm ci
```

Ejecutar en desarrollo:

```bash
npm run dev
```

Generar build:

```bash
npm run build
```

Previsualizar build:

```bash
npm run preview
```

## Docker

La imagen usa un `Dockerfile` multistage:

1. `node:20-alpine` instala dependencias y ejecuta `npm run build`.
2. `nginx:1.27-alpine` sirve `dist/`.
3. Al iniciar el contenedor se generan `config.js` y la configuracion nginx desde templates.

Construir imagen:

```bash
docker build -t front-despacho .
```

Ejecutar en Windows PowerShell:

```bash
docker run --rm -p 8080:80 ^
  -e APP_VENTAS_API_URL=/api/ventas ^
  -e APP_DESPACHOS_API_URL=/api/despachos ^
  -e PRIVATE_VENTAS_API_URL=http://host.docker.internal:8082/api/v1 ^
  -e PRIVATE_DESPACHOS_API_URL=http://host.docker.internal:8081/api/v1 ^
  front-despacho
```

Ejecutar en Linux/macOS:

```bash
docker run --rm -p 8080:80 \
  -e APP_VENTAS_API_URL=/api/ventas \
  -e APP_DESPACHOS_API_URL=/api/despachos \
  -e PRIVATE_VENTAS_API_URL=http://host.docker.internal:8082/api/v1 \
  -e PRIVATE_DESPACHOS_API_URL=http://host.docker.internal:8081/api/v1 \
  front-despacho
```

La aplicacion quedara disponible en `http://localhost:8080`.

## Configuracion Runtime

El frontend carga `/config.js` antes del bundle principal:

```js
window.__APP_CONFIG__ = {
  APP_VENTAS_API_URL: "/api/ventas",
  APP_DESPACHOS_API_URL: "/api/despachos",
};
```

Ese archivo se genera al iniciar el contenedor desde [docker/config.template.js](/C:/Users/marti/Desktop/devops/front_despacho/docker/config.template.js). La configuracion nginx se genera desde [docker/nginx.default.conf.template](/C:/Users/marti/Desktop/devops/front_despacho/docker/nginx.default.conf.template).

## Pipeline CI/CD

El workflow principal esta en [.github/workflows/deploy.yaml](/C:/Users/marti/Desktop/devops/front_despacho/.github/workflows/deploy.yaml). Se ejecuta con cada push a `master`.

Flujo:

1. Descarga el repositorio.
2. Configura Node.js 20.
3. Ejecuta `npm ci`.
4. Ejecuta `npm run build`.
5. Configura Docker Buildx.
6. Inicia sesion en Docker Hub.
7. Construye la imagen desde [Dockerfile](/C:/Users/marti/Desktop/devops/front_despacho/Dockerfile).
8. Publica tags `latest` y `${{ github.sha }}` en Docker Hub.
9. Se conecta por SSH al EC2 publico.
10. Verifica que existan `git` y `docker`.
11. Clona o actualiza el repositorio en `/home/<EC2_USER>/devops_frontend`.
12. Hace `docker pull` de la imagen `latest`.
13. Elimina el contenedor anterior si existe.
14. Levanta el contenedor nuevo en el puerto `80`.

## Secrets de GitHub Actions

Configura estos valores en `Settings > Secrets and variables > Actions > Repository secrets`:

```text
DOCKERHUB_USERNAME=<usuario-dockerhub>
DOCKERHUB_TOKEN=<token-dockerhub>
EC2_HOST=<ip-publica-o-dns-publico-del-ec2-publico>
EC2_USER=ubuntu
EC2_SSH_KEY=<contenido-completo-de-la-llave-privada-pem>
PRIVATE_VENTAS_API_URL=<url-privada-api-ventas>
PRIVATE_DESPACHOS_API_URL=<url-privada-api-despachos>
```

Ejemplo:

```text
EC2_HOST=18.222.10.55
PRIVATE_VENTAS_API_URL=http://10.0.2.15:8082/api/v1
PRIVATE_DESPACHOS_API_URL=http://10.0.2.16:8081/api/v1
```

`EC2_SSH_KEY` debe ser el contenido completo de la llave privada:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

No necesitas crear secrets para `APP_VENTAS_API_URL` ni `APP_DESPACHOS_API_URL`; el workflow los fija como `/api/ventas` y `/api/despachos`.

## AWS Academy

En AWS Academy algunos valores pueden cambiar cuando se reinicia o recrea el laboratorio:

- `EC2_HOST`: cambia si la EC2 publica recibe una nueva IP publica.
- `EC2_SSH_KEY`: cambia si usas una nueva key pair.
- `PRIVATE_VENTAS_API_URL`: cambia si cambia la IP privada de la EC2/API de ventas.
- `PRIVATE_DESPACHOS_API_URL`: cambia si cambia la IP privada de la EC2/API de despachos.
- `EC2_USER`: para Ubuntu normalmente es `ubuntu`.

Security Groups necesarios:

- EC2 publica: permitir HTTP `80` desde internet.
- EC2 publica: permitir SSH `22` para despliegue.
- EC2 privada/API ventas: permitir su puerto, por ejemplo `8082`, desde la EC2 publica.
- EC2 privada/API despachos: permitir su puerto, por ejemplo `8081`, desde la EC2 publica.

La EC2 publica debe tener `docker` y `git` instalados antes de ejecutar el pipeline.

## Datos de Prueba

El archivo [script.sql](/C:/Users/marti/Desktop/devops/front_despacho/script.sql) contiene datos de ejemplo para `productos`, `ventas` y `despachos`, alineados con la forma que devuelven los endpoints consumidos por el frontend.

## Archivos Clave

- [Dockerfile](/C:/Users/marti/Desktop/devops/front_despacho/Dockerfile)
- [docker-entrypoint.d/40-generate-config.sh](/C:/Users/marti/Desktop/devops/front_despacho/docker-entrypoint.d/40-generate-config.sh)
- [docker/config.template.js](/C:/Users/marti/Desktop/devops/front_despacho/docker/config.template.js)
- [docker/nginx.default.conf.template](/C:/Users/marti/Desktop/devops/front_despacho/docker/nginx.default.conf.template)
- [src/config.js](/C:/Users/marti/Desktop/devops/front_despacho/src/config.js)
- [.github/workflows/deploy.yaml](/C:/Users/marti/Desktop/devops/front_despacho/.github/workflows/deploy.yaml)
