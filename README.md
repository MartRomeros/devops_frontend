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

## Pipeline CI/CD (GitHub Actions)

Este proyecto incluye un pipeline de Integración Continua (CI) implementado con **GitHub Actions**. El archivo de configuración se encuentra en `.github/workflows/ci.yml`.

Cada vez que se realiza un `push` o se abre un `pull request` hacia las ramas `main` o `master`, el pipeline ejecuta automáticamente los siguientes pasos para asegurar la calidad del código:

1. **Instalación y Verificación (Node.js):** 
   - Instala las dependencias (`npm install`).
   - Ejecuta el linter para mantener estándares de código (`npm run lint`).
   - Comprueba que el proyecto compila correctamente (`npm run build`).
2. **Validación de Docker:**
   - Construye la imagen de Docker usando `docker-compose build` para asegurar que el `Dockerfile` y las configuraciones no se hayan roto con los nuevos cambios.

---

## Historial y Commits Explicativos

> **Nota para los desarrolladores:** Según los requerimientos, asegúrese de revisar el historial de commits. Se han utilizado mensajes descriptivos para evidenciar claramente cada `feat` (nueva característica), `fix` (corrección de errores), y `update` (actualizaciones y refactorizaciones) realizados en el código base, manteniendo así una trazabilidad completa de los cambios del proyecto.
