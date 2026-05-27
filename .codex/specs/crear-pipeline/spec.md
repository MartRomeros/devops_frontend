# Spec: Ajustar GitHub Actions para publicar imagen Docker del frontend

## Objetivo

Ajustar el workflow `.github/workflows/deploy.yaml` para que, en cada push a la rama `master`, construya la imagen Docker del frontend y la publique en Docker Hub.

## Contexto revisado

- `AGENTS.md` indica que antes de ejecutar un spec se debe revisar la carpeta `context/`; actualmente no existe `.codex/context/` en este repositorio.
- El repositorio contiene un frontend React + Vite con `Dockerfile` en la raiz.
- El workflow actual se llama `CI/CD Backend - Build, Push & Deploy`, pero apunta a imagenes y rutas de backend que no existen en este repositorio:
  - `backend-ventas`
  - `backend-despachos`
  - `./back-Ventas_SpringBoot/Springboot-API-REST`
- El frontend ya tiene scripts disponibles en `package.json`:
  - `npm ci`
  - `npm run build`
  - `npm run lint`
- Los secretos esperados para Docker Hub ya estan declarados como repository secrets:
  - `DOCKERHUB_USERNAME`
  - `DOCKERHUB_TOKEN`

## Alcance

- Modificar `.github/workflows/deploy.yaml` para que represente al frontend, no a backends inexistentes.
- Mantener el trigger en push a `master`.
- Autenticarse en Docker Hub usando `secrets.DOCKERHUB_USERNAME` y `secrets.DOCKERHUB_TOKEN`.
- Construir la imagen usando el `Dockerfile` de la raiz del repositorio.
- Publicar la imagen en Docker Hub con al menos estos tags:
  - `<DOCKERHUB_USERNAME>/front-despacho:latest`
  - `<DOCKERHUB_USERNAME>/front-despacho:<github.sha>`
- Usar Docker Buildx y cache de GitHub Actions para acelerar builds futuros.
- Ejecutar validaciones previas antes de publicar:
  - `npm ci`
  - `npm run build`
- Documentar en el workflow nombres claros de jobs y steps orientados al frontend.

## Fuera de alcance

- Crear o modificar infraestructura AWS.
- Desplegar automaticamente en AWS Academy.
- Crear nuevos secretos en GitHub.
- Cambiar el `Dockerfile` salvo que durante el diseno se detecte un bloqueo real para el pipeline.
- Cambiar la rama principal de `master` a `main`.
- Publicar imagenes de backend.
- Agregar dependencias nuevas al proyecto.

## Reglas de negocio y operacion

- La publicacion a Docker Hub solo debe ocurrir desde `master`.
- Si `npm ci` o `npm run build` falla, no se debe publicar la imagen.
- El login a Docker Hub debe usar `docker/login-action` con los secrets del repositorio.
- El nombre de imagen debe ser estable y especifico del frontend: `front-despacho`.
- El tag `latest` representa el ultimo commit exitoso de `master`.
- El tag `${{ github.sha }}` permite trazabilidad exacta del commit publicado.
- Los repository secrets son el lugar correcto si este workflow pertenece solo a este repositorio. Si en el futuro se requiere aprobacion por ambiente o protecciones por entorno, se deberia evaluar usar environment secrets.

## Criterios de aceptacion

- Dado un push a `master`, cuando se ejecuta GitHub Actions, entonces el workflow corre el job de build y publicacion del frontend.
- Dado que existen `DOCKERHUB_USERNAME` y `DOCKERHUB_TOKEN`, cuando el workflow llega al login, entonces se autentica correctamente en Docker Hub.
- Dado que el frontend compila correctamente, cuando termina el workflow, entonces Docker Hub contiene la imagen `<DOCKERHUB_USERNAME>/front-despacho:latest`.
- Dado un commit publicado, cuando se revisan los tags en Docker Hub, entonces existe tambien `<DOCKERHUB_USERNAME>/front-despacho:<github.sha>`.
- Dado que falla `npm ci` o `npm run build`, cuando se ejecuta el workflow, entonces no se debe ejecutar el push de la imagen.
- Dado el workflow actualizado, cuando se revisa `.github/workflows/deploy.yaml`, entonces no quedan referencias a `backend-ventas`, `backend-despachos` ni rutas `back-Ventas_SpringBoot`.
- El workflow debe usar el contexto `.` y el archivo `./Dockerfile`.
- El workflow debe pasar validacion YAML basica y usar versiones actuales de acciones:
  - `actions/checkout@v4`
  - `docker/setup-buildx-action@v3`
  - `docker/login-action@v3`
  - `docker/build-push-action@v5` o superior compatible

## Preguntas abiertas

- Confirmar si el repositorio de Docker Hub debe llamarse exactamente `front-despacho` o si se requiere otro nombre.
- Confirmar si `npm run lint` debe bloquear la publicacion. El spec exige `npm run build`; `lint` queda recomendado, pero debe validarse si el estado actual del proyecto permite hacerlo obligatorio.
- Confirmar si se requiere publicar solo `linux/amd64` o tambien `linux/arm64`.
- Confirmar si el workflow debe mantener el nombre `deploy.yaml` o si se permite renombrarlo para reflejar que solo construye y publica la imagen frontend.

## Riesgos tecnicos

- Si los secretos existen con nombres distintos, el login a Docker Hub fallara.
- Si el repositorio de Docker Hub no existe y la cuenta no permite crearlo automaticamente desde push, la publicacion fallara.
- Si `npm run lint` se vuelve obligatorio sin corregir errores existentes, podria bloquear el pipeline aunque el build de produccion funcione.
- Si Docker Hub aplica limites de uso o rate limiting, el job podria fallar de forma intermitente.
- Si `master` no es la rama usada realmente para releases, el pipeline publicaria desde una rama incorrecta.

## Supuestos

- El workflow se ejecuta dentro de este mismo repositorio.
- `DOCKERHUB_USERNAME` y `DOCKERHUB_TOKEN` son repository secrets y estan disponibles para GitHub Actions.
- El `Dockerfile` de la raiz es el artefacto que debe construirse para publicar el frontend.
- La imagen final debe ser publica o accesible con las credenciales ya configuradas en Docker Hub.
- El objetivo inmediato es publicar la imagen en Docker Hub; el despliegue posterior en AWS/IaC se resolvera en otro spec si hace falta.

## Cambios sugeridos a la spec original

- Reemplazar el ejemplo generico `imagen:latest` por un nombre de imagen concreto y trazable: `<DOCKERHUB_USERNAME>/front-despacho:latest`.
- Agregar tag por commit SHA para poder auditar que version fue publicada.
- Eliminar referencias conceptuales a backends y orientar el workflow al frontend real de este repositorio.
- Aclarar que repository secrets es correcto para este caso, con la salvedad de environment secrets si luego se necesitan aprobaciones o separacion por ambientes.
- Convertir la peticion en criterios de aceptacion verificables antes de pasar a `design.md` y `tasks.md`.
