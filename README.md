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

Si no se definen, el contenedor usa estos valores por defecto:

- `http://localhost:8082/api/v1`
- `http://localhost:8081/api/v1`

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
  -e APP_VENTAS_API_URL=http://host.docker.internal:8082/api/v1 ^
  -e APP_DESPACHOS_API_URL=http://host.docker.internal:8081/api/v1 ^
  front-despacho
```

En sistemas tipo Unix, el mismo comando seria:

```bash
docker run --rm -p 8080:80 \
  -e APP_VENTAS_API_URL=http://host.docker.internal:8082/api/v1 \
  -e APP_DESPACHOS_API_URL=http://host.docker.internal:8081/api/v1 \
  front-despacho
```

Luego la aplicacion quedara disponible en `http://localhost:8080`.

## Como funciona la configuracion runtime

La aplicacion carga `/config.js` antes del bundle principal. Ese archivo es generado por `nginx` al iniciar el contenedor y expone:

```js
window.__APP_CONFIG__ = {
  APP_VENTAS_API_URL: "http://host.docker.internal:8082/api/v1",
  APP_DESPACHOS_API_URL: "http://host.docker.internal:8081/api/v1",
};
```

Con esto, la misma imagen Docker puede reutilizarse en distintos ambientes sin recompilar.

## Archivos relevantes

- [Dockerfile](/C:/Users/marti/Desktop/devops/front_despacho/Dockerfile)
- [nginx/default.conf](/C:/Users/marti/Desktop/devops/front_despacho/nginx/default.conf)
- [docker-entrypoint.d/40-generate-config.sh](/C:/Users/marti/Desktop/devops/front_despacho/docker-entrypoint.d/40-generate-config.sh)
- [src/config.js](/C:/Users/marti/Desktop/devops/front_despacho/src/config.js)

## Notas

- Si los backends corren fuera del contenedor en tu maquina local, `host.docker.internal` suele ser la opcion correcta para Docker Desktop.
- Si el frontend se despliega junto con APIs en otra red o cluster, debes ajustar `APP_VENTAS_API_URL` y `APP_DESPACHOS_API_URL` a las URLs accesibles desde el navegador del usuario.
