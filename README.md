# Front Despacho

Este repositorio contiene el código fuente para el frontend del proyecto "Front Despacho", una aplicación web desarrollada con React y Vite.

## Tecnologías Utilizadas

El proyecto está construido utilizando las siguientes tecnologías y librerías principales:
- **React (v18):** Biblioteca principal para la construcción de interfaces de usuario.
- **Vite:** Herramienta de construcción (bundler) rápida para el desarrollo frontend.
- **Tailwind CSS:** Framework de CSS utilitario para el diseño rápido y responsivo.
- **React Router DOM:** Manejo de rutas y navegación dentro de la aplicación.
- **React Hook Form:** Gestión eficiente y validación de formularios.
- **Axios:** Cliente HTTP para realizar peticiones a la API backend.
- **SweetAlert2:** Para mostrar alertas y notificaciones modales estilizadas.
- **React Icons:** Colección de íconos vectoriales.

## Funcionamiento del Proyecto

El proyecto se encarga de la interfaz de usuario para el sistema de despacho. Permite a los usuarios interactuar con la plataforma de forma ágil y dinámica gracias al enrutamiento del lado del cliente y las peticiones asíncronas hacia el backend a través de Axios. 

El diseño está completamente enfocado en componentes reutilizables y un estilizado manejado por Tailwind CSS, asegurando que la interfaz sea amigable tanto en escritorio como en dispositivos móviles.

---

## Cómo Utilizar el Proyecto (Entorno de Desarrollo Local)

Si deseas correr o modificar el código de forma local sin Docker, necesitas tener instalado **Node.js** (se recomienda versión 18 o superior).

### 1. Instalación de dependencias
Abre una terminal en la raíz del proyecto y ejecuta:
```bash
npm install
```

### 2. Ejecutar el servidor de desarrollo
Para iniciar la aplicación en modo desarrollo con recarga en caliente (Hot Module Replacement):
```bash
npm run dev
```
La aplicación estará disponible típicamente en `http://localhost:5173`.

### 3. Construcción para Producción
Para generar una versión estática optimizada lista para producción:
```bash
npm run build
```
Esto creará una carpeta `dist/` con los archivos compilados.

---

## Cómo Utilizar el Proyecto (Entorno Dockerizado)

Este proyecto incluye configuración para ser levantado fácilmente mediante contenedores Docker, lo cual asegura que funcionará de manera idéntica en cualquier equipo. Se utiliza un enfoque de **múltiples etapas (multi-stage build)** para optimizar el tamaño de la imagen final.

### Requisitos
- Docker
- Docker Compose

### Levantar el proyecto
Para construir y ejecutar la aplicación usando los contenedores, simplemente abre una terminal en la raíz del proyecto y ejecuta:

```bash
docker-compose up -d --build
```

Esto realizará lo siguiente:
1. **Etapa de compilación:** Utilizará una imagen de `node:20-alpine` para instalar las dependencias (`npm install`) y compilar la aplicación (`npm run build`).
2. **Etapa de producción:** Utilizará un servidor web `nginx:1.25-alpine` para servir los archivos estáticos de la carpeta `dist`.

Una vez finalizado, podrás acceder a la aplicación en tu navegador web ingresando a:
**http://localhost:8080**

### Detener el proyecto
Para detener y remover los contenedores:
```bash
docker-compose down
```

---

## Pipeline de Integración y Despliegue Continuo (CI/CD)

Este proyecto incluye un pipeline completo de Integración y Despliegue Continuo implementado con **GitHub Actions**. El archivo de configuración se encuentra en `.github/workflows/ci-cd.yml`.

El pipeline utiliza **triggers basados en la rama `deploy`**. Cada vez que se realiza un `push` a esta rama, se ejecutan automáticamente los siguientes procesos (pasos documentados en el workflow):

### 1. Construcción y Publicación de la Imagen (Docker Hub)
El job `build-and-push` se encarga de:
- Iniciar sesión en Docker Hub utilizando credenciales seguras.
- Construir la imagen de Docker a partir del `Dockerfile` (usando Buildx).
- Publicar (push) la nueva imagen etiquetada como `latest` en tu repositorio de Docker Hub.

### 2. Despliegue Automático en Instancia EC2
El job `deploy-to-ec2` se encarga de:
- Conectarse vía SSH a la instancia de AWS EC2 utilizando la Action `appleboy/ssh-action`.
- Descargar (`pull`) la última versión de la imagen publicada en Docker Hub.
- Detener y eliminar el contenedor que se encuentre en ejecución.
- Iniciar un nuevo contenedor con los cambios actualizados.

### Manejo de Secrets (GitHub Secrets)
Para que el pipeline se ejecute correctamente y mantener la seguridad, es **obligatorio** configurar las siguientes variables secretas (Secrets) en la configuración del repositorio de GitHub (`Settings > Secrets and variables > Actions`):

- `DOCKER_USERNAME`: Tu nombre de usuario en Docker Hub.
- `DOCKER_PASSWORD`: Tu contraseña o token de acceso (Access Token) de Docker Hub.
- `EC2_HOST`: La dirección IP pública o el DNS público de tu instancia EC2.
- `EC2_USERNAME`: El usuario para acceder por SSH a la instancia EC2 (por ejemplo, `ubuntu` o `ec2-user`).
- `EC2_SSH_KEY`: El contenido de tu llave privada `.pem` de AWS para acceder a la instancia EC2 por SSH.

---

## Historial y Commits Explicativos

> **Nota para los desarrolladores:** Según los requerimientos, asegúrese de revisar el historial de commits. Se han utilizado mensajes descriptivos para evidenciar claramente cada `feat` (nueva característica), `fix` (corrección de errores), y `update` (actualizaciones y refactorizaciones) realizados en el código base, manteniendo así una trazabilidad completa de los cambios del proyecto.
