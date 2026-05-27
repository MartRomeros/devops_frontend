# Design: Ajustar GitHub Actions para publicar imagen Docker del frontend

## Resumen

El workflow `.github/workflows/deploy.yaml` debe dejar de construir imagenes de backend y pasar a construir una unica imagen Docker del frontend React + Vite. La imagen se construira desde el `Dockerfile` ubicado en la raiz del repositorio y se publicara en Docker Hub con dos tags: `latest` y el SHA del commit.

## Archivos que probablemente se modificaran

- `.github/workflows/deploy.yaml`: reemplazar el workflow actual de backend por un workflow de frontend.

## Archivos que se usaran como referencia

- `.codex/specs/crear-pipeline/spec.md`: criterios y alcance aprobados.
- `Dockerfile`: archivo Docker que debe construir la imagen del frontend.
- `package.json`: scripts disponibles para validar el frontend antes de publicar.

## Arquitectura propuesta

El pipeline tendra un unico job llamado `build-and-push`. Ese job se ejecutara en `ubuntu-latest` cuando exista un push a `master`.

El flujo sera:

1. Descargar el repositorio con `actions/checkout@v4`.
2. Configurar Node.js para ejecutar validaciones del frontend.
3. Instalar dependencias con `npm ci`.
4. Ejecutar `npm run build`.
5. Configurar Docker Buildx con `docker/setup-buildx-action@v3`.
6. Iniciar sesion en Docker Hub con `docker/login-action@v3`.
7. Construir y publicar la imagen con `docker/build-push-action`.

## Flujo de datos

GitHub Actions recibira el evento `push` sobre `master`. El workflow leera `secrets.DOCKERHUB_USERNAME` y `secrets.DOCKERHUB_TOKEN` desde los repository secrets.

El nombre base de la imagen se definira en `env`:

```yaml
IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/front-despacho
```

La accion `docker/build-push-action` usara:

```yaml
context: .
file: ./Dockerfile
push: true
tags: |
  ${{ env.IMAGE_NAME }}:latest
  ${{ env.IMAGE_NAME }}:${{ github.sha }}
```

## Cambios en base de datos

No aplica. Este cambio solo modifica CI/CD.

## Dependencias nuevas

No se agregaran dependencias al proyecto. El workflow usara acciones existentes de GitHub Actions:

- `actions/checkout@v4`
- `actions/setup-node@v4`
- `docker/setup-buildx-action@v3`
- `docker/login-action@v3`
- `docker/build-push-action@v5` o superior compatible

## Validaciones previas al push

El pipeline debe ejecutar `npm ci` y `npm run build` antes de publicar la imagen. Si cualquiera de esos pasos falla, el job debe detenerse y no debe publicar en Docker Hub.

`npm run lint` queda fuera del flujo obligatorio inicial porque el spec lo marca como pregunta abierta. Se puede agregar en una iteracion posterior si se confirma que debe bloquear la publicacion.

## Seguridad y secretos

Los secretos `DOCKERHUB_USERNAME` y `DOCKERHUB_TOKEN` deben mantenerse como repository secrets. Esta ubicacion es adecuada porque el workflow pertenece a un solo repositorio y no requiere aprobaciones por ambiente.

No se deben imprimir tokens en logs. El workflow debe usar los secrets solo mediante inputs oficiales de `docker/login-action`.

## Riesgos

- El repositorio `front-despacho` podria no existir en Docker Hub o la cuenta podria no permitir su creacion automatica.
- Si `DOCKERHUB_USERNAME` o `DOCKERHUB_TOKEN` estan mal configurados, el login fallara.
- Si `master` no es realmente la rama de release, el pipeline publicara imagenes desde la rama equivocada.
- Si se agrega `npm run lint` sin corregir problemas existentes, podria bloquear una publicacion aunque el build funcione.

## Estrategia de testing

La validacion local antes de entregar el cambio debe incluir:

```bash
npm run build
```

Si Docker esta disponible, tambien validar:

```bash
docker build -t front-despacho:test .
```

La validacion del workflow debe incluir una revision estatica de `.github/workflows/deploy.yaml` para confirmar:

- No quedan referencias a backends.
- El `context` es `.`.
- El `file` es `./Dockerfile`.
- Los tags incluyen `latest` y `${{ github.sha }}`.
- El push solo ocurre despues de las validaciones npm.

## Decisiones pendientes

- Confirmar si el repositorio Docker Hub debe llamarse exactamente `front-despacho`.
- Confirmar si se requiere publicar imagen multi-arquitectura (`linux/amd64` y `linux/arm64`) o solo la arquitectura por defecto del runner.
- Confirmar si `npm run lint` debe convertirse en validacion obligatoria del pipeline.
