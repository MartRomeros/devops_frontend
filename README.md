# React + Vite - Front Despacho

This project is a React application set up with Vite. 

## Docker Configuration

This project includes configuration files to run the frontend inside a Docker container using a **multi-stage build** for optimal performance and smaller image sizes.

### 1. Dockerfile

El `Dockerfile` fue generado utilizando un enfoque de múltiples etapas (multi-stage build) que consta de dos partes principales:

- **Etapa 1 (Build):** Utiliza la imagen oficial de `node:18-alpine` para instalar las dependencias (`npm install`) y compilar la aplicación React/Vite para producción (`npm run build`). Esto genera los archivos estáticos en la carpeta `dist`.
- **Etapa 2 (Producción):** Utiliza la imagen ligera de `nginx:alpine`. Copia únicamente la carpeta `dist` generada en la etapa anterior y la aloja en la ruta pública de Nginx (`/usr/share/nginx/html`). Se expone el puerto 80 para el servidor web.

Este enfoque asegura que el contenedor final no contenga código fuente ni dependencias de Node.js, reduciendo drásticamente su peso y mejorando la seguridad. Además, se configuró un archivo `.dockerignore` para excluir carpetas innecesarias como `node_modules`.

### 2. Docker Compose

El archivo `docker-compose.yml` fue generado para simplificar la orquestación del contenedor. 

Configuraciones principales del servicio `frontend`:
- **build:** Le indica a Docker Compose que debe construir la imagen utilizando el directorio actual (`context: .`) y el archivo `Dockerfile`.
- **container_name:** Asigna el nombre `front-despacho-app` al contenedor para facilitar su identificación.
- **ports:** Mapea el puerto `8080` de tu máquina local (host) al puerto `80` del contenedor (donde Nginx está sirviendo la aplicación).
- **restart:** La política `unless-stopped` asegura que el contenedor se reiniciará automáticamente si falla o si el equipo se reinicia, a menos que se detenga manualmente.

### Instrucciones de Uso

Para levantar el proyecto utilizando Docker Compose, simplemente abre una terminal en la raíz de este proyecto y ejecuta:

```bash
docker-compose up -d --build
```

Una vez que termine de construir y levantar, podrás ver tu aplicación ingresando a:
**http://localhost:8080**

Para detener la aplicación, ejecuta:
```bash
docker-compose down
```
