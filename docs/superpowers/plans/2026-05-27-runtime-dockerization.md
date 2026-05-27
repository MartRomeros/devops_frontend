# Runtime Dockerization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Containerize the Vite frontend with a multi-stage Docker build and runtime-configurable API endpoints served by nginx.

**Architecture:** Build the React app with Node.js, serve the generated static files with nginx, and generate a `config.js` file at container startup so endpoint values can change without rebuilding the image.

**Tech Stack:** React 18, Vite 5, nginx, Docker

---

### Task 1: Add runtime configuration support

**Files:**
- Create: `src/config.js`
- Modify: `index.html`
- Modify: `src/componentes/CrudAdmin/TableCompras.jsx`
- Modify: `src/componentes/CrudAdmin/TableDespachos.jsx`
- Modify: `src/componentes/CrudAdmin/FormDespacho.jsx`
- Modify: `src/componentes/CrudAdmin/FormCierreDespacho.jsx`

- [ ] Read current hardcoded API usage and define the runtime configuration shape.
- [ ] Load `config.js` before the Vite bundle in `index.html`.
- [ ] Replace hardcoded endpoint URLs with a shared config helper.
- [ ] Keep safe defaults so local development still works without Docker.

### Task 2: Add multi-stage container runtime

**Files:**
- Create: `Dockerfile`
- Create: `.dockerignore`
- Create: `nginx/default.conf`
- Create: `docker-entrypoint.d/40-generate-config.sh`
- Create: `public/config.template.js`

- [ ] Build the app in a Node.js stage using `npm ci` and `npm run build`.
- [ ] Serve `dist` with nginx in the final stage.
- [ ] Generate `/usr/share/nginx/html/config.js` from environment variables at container startup.
- [ ] Add nginx SPA routing fallback for React Router.

### Task 3: Document local and container usage

**Files:**
- Create: `.env.example`
- Modify: `README.md`

- [ ] Document the application purpose and architecture.
- [ ] Document local dependency installation and execution.
- [ ] Document environment variables and defaults.
- [ ] Document Docker image build and container execution commands.
