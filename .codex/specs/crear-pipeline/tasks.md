# Tasks: Ajustar GitHub Actions para publicar imagen Docker del frontend

## Task 1: Reemplazar referencias de backend en el workflow

Objetivo: dejar el workflow orientado al frontend real del repositorio.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Revision estatica del YAML.

Criterio de finalizacion:

- El workflow no contiene `backend-ventas`, `backend-despachos` ni `back-Ventas_SpringBoot`.
- El nombre del workflow y del job describe build y push del frontend.

## Task 2: Configurar variables de imagen Docker

Objetivo: definir un nombre estable para la imagen del frontend en Docker Hub.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Revision estatica de la seccion `env`.

Criterio de finalizacion:

- Existe una variable equivalente a `IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/front-despacho`.
- El workflow sigue usando `DOCKERHUB_USERNAME` y `DOCKERHUB_TOKEN` desde repository secrets.

## Task 3: Agregar validaciones npm antes de publicar

Objetivo: impedir que se publique una imagen si el frontend no instala o no compila.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Ejecutar localmente `npm run build`.

Criterio de finalizacion:

- El workflow ejecuta `npm ci`.
- El workflow ejecuta `npm run build`.
- Los pasos de Docker login y push quedan despues de las validaciones npm.

## Task 4: Configurar Docker Buildx y login a Docker Hub

Objetivo: preparar el runner para construir y publicar la imagen Docker.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Revision estatica de acciones usadas.

Criterio de finalizacion:

- El workflow usa `docker/setup-buildx-action@v3`.
- El workflow usa `docker/login-action@v3`.
- El login usa `username: ${{ secrets.DOCKERHUB_USERNAME }}`.
- El login usa `password: ${{ secrets.DOCKERHUB_TOKEN }}`.

## Task 5: Construir y publicar la imagen del frontend

Objetivo: publicar en Docker Hub una imagen construida desde el `Dockerfile` de la raiz.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- Si Docker esta disponible, ejecutar `docker build -t front-despacho:test .`.
- Revision estatica del paso `docker/build-push-action`.

Criterio de finalizacion:

- El workflow usa `context: .`.
- El workflow usa `file: ./Dockerfile`.
- El workflow usa `push: true`.
- El workflow publica `${{ env.IMAGE_NAME }}:latest`.
- El workflow publica `${{ env.IMAGE_NAME }}:${{ github.sha }}`.
- El workflow usa cache de GitHub Actions con `cache-from: type=gha` y `cache-to: type=gha,mode=max`.

## Task 6: Validacion final del spec implementado

Objetivo: confirmar que el cambio cumple el spec antes de pedir aprobacion.

Archivos esperados:

- `.github/workflows/deploy.yaml`

Tests requeridos:

- `npm run build`
- `docker build -t front-despacho:test .`, si Docker esta disponible.
- Busqueda estatica:

```bash
rg -n "backend-ventas|backend-despachos|back-Ventas" .github/workflows/deploy.yaml
```

Criterio de finalizacion:

- `npm run build` termina con exit code 0.
- El build Docker local termina con exit code 0, si se pudo ejecutar.
- La busqueda estatica no encuentra referencias de backend en el workflow.
- El workflow mantiene el trigger en push a `master`.
- No se modifican archivos fuera del alcance del pipeline.
