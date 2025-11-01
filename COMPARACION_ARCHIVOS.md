# 🔍 Comparación Detallada de Archivos

## 📋 Tabla Resumen

| Archivo | ¿Usar? | Razón |
|---------|--------|-------|
| `docker-compose-gpt.yml` | ✅ **SÍ** | Mejor seguridad (expose), ya corregido |
| `docker-compose.yml` | ❌ NO | Expone puertos innecesariamente |
| `nginx/default-gpt.conf` | ✅ **SÍ** | Tiene frontend Y backend configurado |
| `nginx/default.conf` | ❌ NO | Solo frontend, falta backend |

---

## 1️⃣ Docker Compose: Comparación Lado a Lado

### ✅ docker-compose-gpt.yml (USAR ESTE - YA CORREGIDO)

```yaml
version: "3.9"

networks:
  rag-misw:
    driver: bridge

services:
  backend:
    build:
      context: ./202515-MISW4411-Backend-Grupo20  # ✅ CORREGIDO
    image: misw4411-backend:latest
    environment:
      - UVICORN_WORKERS=2
    expose:                                        # ✅ MEJOR: Solo interno
      - "8000"
    networks:
      - rag-misw
    restart: unless-stopped

  frontend:
    build:
      context: ./MISW4411-Frontend-Template
    image: misw4411-frontend:latest
    expose:                                        # ✅ MEJOR: Solo interno
      - "3000"
    networks:
      - rag-misw
    depends_on:
      - backend
    restart: unless-stopped

  proxy:
    image: nginx:1.25-alpine
    ports:
      - "80:80"                                    # ✅ Solo el proxy público
    networks:
      - rag-misw
    depends_on:
      - frontend
      - backend
    volumes:
      - ./nginx/default-gpt.conf:/etc/nginx/conf.d/default.conf:ro  # ✅ CORREGIDO
    restart: unless-stopped
```

**Ventajas:**
- ✅ **Seguridad:** Backend y frontend NO son accesibles directamente desde internet
- ✅ **Arquitectura correcta:** Solo nginx expone puerto público
- ✅ **Mejor práctica:** Separación de concerns
- ✅ **Correcciones aplicadas:** Contexto y nginx config correctos

---

### ❌ docker-compose.yml (NO USAR)

```yaml
networks:
  rag-misw:
    driver: bridge

services:
  backend:
    build:
      context: ./MISW4411-Backend              # ❌ RUTA INCORRECTA
    image: misw4411-backend-img
    ports:                                      # ❌ EXPONE PÚBLICAMENTE
      - "8000:8000"
    networks:
      - rag-misw
    restart: unless-stopped

  frontend:
    build:
      context: ./MISW4411-Frontend-Template
    image: misw4411-frontend-img
    ports:                                      # ❌ EXPONE PÚBLICAMENTE
      - "3000:3000"
    networks:
      - rag-misw
    depends_on:
      - backend
    restart: unless-stopped

  proxy:
    image: nginx:1.25-alpine
    ports:
      - "80:80"
    networks:
      - rag-misw
    depends_on:
      - frontend
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro  # ❌ CONFIG INCOMPLETA
    restart: unless-stopped
```

**Problemas:**
- ❌ Backend expuesto en puerto 8000 (vulnerable)
- ❌ Frontend expuesto en puerto 3000 (innecesario)
- ❌ Contexto del backend incorrecto
- ❌ Usa `default.conf` que no tiene backend

---

## 2️⃣ Nginx: Comparación Lado a Lado

### ✅ default-gpt.conf (USAR ESTE)

```nginx
server {
  listen 80;
  server_name _;

  # ✅ FRONTEND: Ruta raíz para la aplicación React
  location / {
    proxy_pass http://frontend:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    # WebSockets support
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  # ✅ BACKEND: Ruta /api/ para la API FastAPI
  location /api/ {
    proxy_pass http://backend:8000/;           # ← ESTO ES CLAVE
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
  }

  # ✅ Permite subir archivos de hasta 25MB
  client_max_body_size 25m;
}
```

**Características:**
- ✅ **Frontend en `/`**: Todas las rutas base van al frontend
- ✅ **Backend en `/api/`**: Todas las llamadas API van al backend
- ✅ **WebSocket support**: Para desarrollo con hot reload
- ✅ **Headers completos**: Forwarding correcto de IP y protocolo
- ✅ **Tamaño de archivo**: Configurado para subir documentos

**Ejemplo de Enrutamiento:**
```
http://vm-ip/                    → frontend:3000/
http://vm-ip/about               → frontend:3000/about
http://vm-ip/api/v1/ask          → backend:8000/v1/ask
http://vm-ip/api/health          → backend:8000/health
```

---

### ❌ default.conf (NO USAR)

```nginx
server {
    listen 80;
    server_name localhost;

    # Solo tiene frontend
    location / {
        proxy_pass http://frontend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # ❌ NO HAY CONFIGURACIÓN PARA EL BACKEND
}
```

**Problemas:**
- ❌ **Falta ruta `/api/`**: No hay forma de llegar al backend
- ❌ **Aplicación rota**: Frontend no podrá hacer llamadas al backend
- ❌ **Configuración incompleta**: Faltan headers y opciones avanzadas

**Resultado:**
```
http://vm-ip/                    → ✅ frontend:3000/
http://vm-ip/api/v1/ask          → ❌ ERROR 404 (nginx no sabe qué hacer)
http://vm-ip/api/health          → ❌ ERROR 404 (nginx no sabe qué hacer)
```

---

## 3️⃣ Visualización de la Arquitectura

### Con docker-compose-gpt.yml + default-gpt.conf (✅ CORRECTO)

```
┌─────────────────────────────────────────────────────┐
│                    INTERNET                         │
│              (Solo puerto 80 abierto)               │
└────────────────────┬────────────────────────────────┘
                     │
                     ↓
        ┌────────────────────────┐
        │    Nginx Proxy :80     │
        │  (Público, accesible)  │
        └────────┬───────┬───────┘
                 │       │
        ┌────────┘       └────────┐
        ↓                         ↓
┌───────────────┐         ┌──────────────┐
│ Frontend:3000 │         │ Backend:8000 │
│   (Privado)   │         │   (Privado)  │
└───────────────┘         └──────────────┘

RED INTERNA: rag-misw
Seguridad: ✅ Alta
Acceso: Solo a través de nginx
```

---

### Con docker-compose.yml + default.conf (❌ INCORRECTO)

```
┌─────────────────────────────────────────────────────┐
│                    INTERNET                         │
│         (Puertos 80, 3000, 8000 abiertos)          │
└────────┬────────────┬──────────────┬────────────────┘
         │            │              │
         ↓            ↓              ↓
    ┌────────┐  ┌──────────┐  ┌──────────┐
    │Nginx:80│  │Front:3000│  │Back:8000 │
    │(Roto)  │  │(Expuesto)│  │(Expuesto)│
    └────────┘  └──────────┘  └──────────┘

Problemas:
❌ Backend expuesto (seguridad)
❌ Frontend expuesto (innecesario)
❌ Nginx no enruta al backend (roto)
```

---

## 4️⃣ Flujo de Peticiones Completo

### Ejemplo: Usuario hace una pregunta en el chat

**Con configuración correcta (docker-compose-gpt.yml + default-gpt.conf):**

```
1. Usuario escribe: "¿Qué es un LLM?"
   └─> Frontend envía: POST /api/v1/ask

2. Navegador hace: POST http://vm-ip/api/v1/ask
   └─> Llega a Nginx (puerto 80)

3. Nginx ve "/api/" en la URL
   └─> Aplica regla: location /api/
   └─> Redirige a: http://backend:8000/v1/ask

4. Backend (FastAPI) procesa
   └─> Consulta vector DB
   └─> Llama a OpenAI/Google
   └─> Genera respuesta

5. Backend responde
   └─> Nginx recibe respuesta
   └─> Nginx envía al navegador

6. Frontend recibe y muestra respuesta
   ✅ TODO FUNCIONA
```

**Con configuración incorrecta (docker-compose.yml + default.conf):**

```
1. Usuario escribe: "¿Qué es un LLM?"
   └─> Frontend envía: POST /api/v1/ask

2. Navegador hace: POST http://vm-ip/api/v1/ask
   └─> Llega a Nginx (puerto 80)

3. Nginx ve "/api/" en la URL
   └─> ❌ NO HAY REGLA PARA /api/
   └─> ❌ Retorna: 404 Not Found

4. ❌ Backend nunca recibe la petición
   ❌ LA APLICACIÓN NO FUNCIONA
```

---

## 5️⃣ Cambios en appConfig.ts

### ✅ Configuración Corregida (ACTUAL)

```typescript
export const APP_CONFIG = {
  // Para despliegue con nginx proxy
  BACKEND_URL: "/api",           // ✅ Ruta relativa
  API_ENDPOINT: "/v1/ask",       // ✅ Sin /api/ (lo agrega BACKEND_URL)
  
  // URL completa resultante: /api/v1/ask ✅
};
```

**Ventajas:**
- ✅ Funciona con nginx proxy
- ✅ Rutas relativas (no necesita IP hardcodeada)
- ✅ Portable entre ambientes

---

### ❌ Configuración Original

```typescript
export const APP_CONFIG = {
  // Para desarrollo local SIN nginx
  BACKEND_URL: "http://127.0.0.1:8000",  // ❌ URL absoluta
  API_ENDPOINT: "/api/v1/ask",            // ❌ Con /api/
  
  // URL completa: http://127.0.0.1:8000/api/v1/ask
  // ❌ NO funciona con nginx proxy
};
```

**Problema:**
- ❌ Intenta conectar directamente a puerto 8000
- ❌ Bypassa el nginx proxy
- ❌ No funciona en despliegue con Docker

---

## 📊 Tabla Comparativa Final

| Característica | docker-compose-gpt.yml | docker-compose.yml |
|----------------|------------------------|---------------------|
| **Contexto Backend** | ✅ Correcto | ❌ Incorrecto |
| **Seguridad** | ✅ Alta (expose) | ⚠️ Media (ports) |
| **Nginx Config** | ✅ Completa | ❌ Incompleta |
| **Frontend accesible** | ✅ Sí | ✅ Sí |
| **Backend accesible** | ✅ Sí (vía /api/) | ❌ No configurado |
| **Listo para GCP** | ✅ Sí | ❌ No |

| Característica | default-gpt.conf | default.conf |
|----------------|------------------|--------------|
| **Frontend** | ✅ Configurado | ✅ Configurado |
| **Backend** | ✅ Configurado | ❌ Falta |
| **WebSocket** | ✅ Sí | ❌ No |
| **Headers completos** | ✅ Sí | ⚠️ Básicos |
| **Upload files** | ✅ 25MB | ❌ Default |
| **Listo para GCP** | ✅ Sí | ❌ No |

---

## ✅ Conclusión

### Para Desplegar en GCP:

```bash
# Usa estos archivos:
- docker-compose-gpt.yml     ✅ (ya corregido)
- nginx/default-gpt.conf     ✅ (ya correcto)

# NO uses:
- docker-compose.yml         ❌
- nginx/default.conf         ❌
```

### Comando Final:

```bash
docker-compose -f docker-compose-gpt.yml up -d
```

**¡Eso es todo!** 🚀

---

**Archivo creado:** 1 de Noviembre, 2025  
**Propósito:** Aclarar diferencias entre archivos de configuración  
**Estado:** Correcciones ya aplicadas ✅

