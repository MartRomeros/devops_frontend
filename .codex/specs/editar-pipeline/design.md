# Design: Editar pipeline para desplegar frontend en EC2

## Resumen

El workflow `.github/workflows/deploy.yaml` debe mantener el build y push de la imagen Docker del frontend a Docker Hub, y agregar un despliegue remoto en una instancia EC2 Ubuntu. El despliegue se hara por SSH, validando que existan `docker` y `git`, actualizando una copia del repositorio en la instancia y ejecutando el contenedor publicado en Docker Hub en el puerto 80.

## Archivos que probablemente se modificaran

- `.github/workflows/deploy.yaml`: ajustar el job `deploy` para que no copie archivos inexistentes y despliegue la imagen Docker publicada.
- `.codex/specs/editar-pipeline/tasks.md`: registrar tareas ejecutables del spec.

## Arquitectura propuesta

El workflow tendra dos jobs:

1. `build-and-push`: valida el frontend, construye la imagen desde `./Dockerfile` y la publica en Docker Hub.
2. `deploy`: espera a `build-and-push`, se conecta por SSH al EC2, actualiza o clona el repositorio, descarga la imagen `latest` desde Docker Hub y reinicia el contenedor.

El despliegue remoto no dependera de `docker-compose.yml`, porque ese archivo no existe en este repositorio. Se usara `docker run` directamente.

## Flujo de datos

GitHub Actions publica la imagen:

```yaml
${{ secrets.DOCKERHUB_USERNAME }}/front-despacho:latest
${{ secrets.DOCKERHUB_USERNAME }}/front-despacho:${{ github.sha }}
```

El job `deploy` usa SSH para ejecutar comandos en EC2:

1. Validar que existan `docker` y `git`.
2. Crear el directorio base del proyecto si no existe.
3. Si ya existe un repositorio Git, ejecutar `git fetch` y `git reset --hard origin/master`.
4. Si no existe, clonar `https://github.com/${{ github.repository }}.git`.
5. Hacer login en Docker Hub desde EC2.
6. Ejecutar `docker pull` de la imagen `latest`.
7. Detener y eliminar el contenedor anterior si existe.
8. Ejecutar un nuevo contenedor con `-p 80:80` y variables runtime para endpoints.

## Cambios en base de datos

No aplica.

## Dependencias nuevas

No se agregaran dependencias al proyecto. El workflow usa:

- `actions/checkout@v4`
- `actions/setup-node@v4`
- `docker/setup-buildx-action@v3`
- `docker/login-action@v3`
- `docker/build-push-action@v5`
- `appleboy/ssh-action@v1.0.3`

## Secretos necesarios

- `DOCKERHUB_USERNAME`: usuario de Docker Hub.
- `DOCKERHUB_TOKEN`: token de Docker Hub con permisos para push y pull.
- `EC2_HOST`: IP publica o DNS de la instancia EC2.
- `EC2_USER`: usuario SSH de Ubuntu, normalmente `ubuntu`.
- `EC2_SSH_KEY`: llave privada SSH con acceso al EC2.
- `APP_VENTAS_API_URL`: URL runtime del backend de ventas accesible desde el navegador.
- `APP_DESPACHOS_API_URL`: URL runtime del backend de despachos accesible desde el navegador.

## Riesgos

- Si el repositorio es privado, el `git clone` desde EC2 por HTTPS puede requerir credenciales adicionales o una llave configurada previamente en la instancia.
- Si Docker no esta instalado en EC2, el deploy fallara con un mensaje claro en lugar de instalar paquetes automaticamente.
- Si otro servicio ya ocupa el puerto 80, el contenedor no podra iniciar.
- Si `APP_VENTAS_API_URL` o `APP_DESPACHOS_API_URL` apuntan a URLs internas no accesibles desde el navegador del usuario, la app cargara pero las llamadas API fallaran.

## Estrategia de testing

Validaciones locales:

```bash
npm run build
docker build -t front-despacho:test .
```

Validaciones estaticas del workflow:

- No debe copiar `docker-compose.yml` ni `init-db/`.
- Debe contener `appleboy/ssh-action@v1.0.3`.
- Debe validar `command -v docker` y `command -v git`.
- Debe ejecutar `docker pull`.
- Debe publicar el contenedor con `-p 80:80`.
- Debe usar `APP_VENTAS_API_URL` y `APP_DESPACHOS_API_URL` en `docker run`.
