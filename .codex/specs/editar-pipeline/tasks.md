# Tasks: Editar pipeline para desplegar frontend en EC2

## Task 1: Quitar despliegue basado en archivos inexistentes

Objetivo: eliminar del workflow la copia de `docker-compose.yml` e `init-db/`, porque no existen en este repositorio.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Busqueda estatica de `docker-compose.yml` e `init-db`.

Criterio de finalizacion:

- El workflow no contiene pasos `scp` para archivos inexistentes.

## Task 2: Validar prerequisitos en EC2

Objetivo: asegurar que el deploy falle claramente si EC2 no tiene `docker` o `git`.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Revision estatica del script SSH.

Criterio de finalizacion:

- El script contiene `command -v docker`.
- El script contiene `command -v git`.

## Task 3: Actualizar o clonar repositorio en EC2

Objetivo: cumplir el flujo de primera ejecucion y ejecuciones posteriores.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Revision estatica del script SSH.

Criterio de finalizacion:

- Si existe `.git`, el script actualiza el repo.
- Si no existe `.git`, el script clona `https://github.com/${{ github.repository }}.git`.

## Task 4: Descargar imagen publicada desde Docker Hub

Objetivo: desplegar exactamente la imagen publicada por el job de build.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Revision estatica del script SSH.

Criterio de finalizacion:

- El script hace login a Docker Hub.
- El script ejecuta `docker pull $IMAGE_NAME:latest`.

## Task 5: Reiniciar contenedor en puerto 80

Objetivo: dejar la aplicacion ejecutandose como contenedor Docker en EC2.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Revision estatica del comando `docker run`.

Criterio de finalizacion:

- El script detiene y elimina el contenedor anterior si existe.
- El script ejecuta el contenedor nuevo con `--restart unless-stopped`.
- El script publica `80:80`.
- El script inyecta `APP_VENTAS_API_URL` y `APP_DESPACHOS_API_URL`.

## Task 6: Validacion final

Objetivo: comprobar que el pipeline sigue construyendo localmente y que el workflow cumple el spec.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- `npm run build`
- `docker build -t front-despacho:test .`
- Busquedas estaticas sobre `.github/workflows/deploy.yaml`

Criterio de finalizacion:

- El build frontend termina con exit code 0.
- El build Docker termina con exit code 0.
- El workflow mantiene `push` a `master`.
- El workflow mantiene push de imagen a Docker Hub.
- El workflow contiene deploy por SSH a EC2.
