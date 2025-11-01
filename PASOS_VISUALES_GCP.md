# 👁️ Guía Visual: Qué Ver en Cada Paso

## 🎯 Resumen de Lo Que Te Falta

No puedo conectarme a GCP directamente, pero te guío EXACTAMENTE qué hacer:

---

## 📍 PASO 1: Crear la VM (5 minutos)

### Dónde ir:
```
https://console.cloud.google.com/compute/instances
```

### Qué verás:
```
┌────────────────────────────────────────────────────┐
│ Compute Engine > VM instances                      │
│                                                    │
│ [+ CREATE INSTANCE]  [Start]  [Stop]  [More]     │
│                                                    │
│ No VM instances to display                         │
└────────────────────────────────────────────────────┘
```

### Qué hacer:
1. **Clic en `+ CREATE INSTANCE`**

2. **Verás un formulario largo, llena así:**

```
┌─────────────────────────────────────────┐
│ Name *                                  │
│ misw4411-rag-app                       │ ← Escribe esto
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Region                                  │
│ us-central1 (Iowa)              ▼      │ ← Selecciona esta
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Zone                                    │
│ us-central1-a                   ▼      │ ← O cualquier zona
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ MACHINE CONFIGURATION                   │
│                                         │
│ Machine family                          │
│ ○ General-purpose  ○ Compute  ○ Memory │
│   ●                                     │ ← Deja General-purpose
│                                         │
│ Series                                  │
│ E2                              ▼      │ ← E2 es la más barata
│                                         │
│ Machine type                            │
│ e2-standard-2                   ▼      │ ← Recomendado
│ (2 vCPU, 8 GB memory)                  │
│ $49.13/month                           │
│                                         │
│ Puedes usar e2-medium si quieres       │
│ ahorrar: (2 vCPU, 4 GB) $24/month     │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ BOOT DISK                               │
│ [CHANGE]                                │ ← Clic aquí
│                                         │
│ Abrirá una ventana:                    │
│ Operating system: Ubuntu        ▼      │ ← Selecciona Ubuntu
│ Version: Ubuntu 22.04 LTS       ▼      │ ← Selecciona 22.04
│ Boot disk type: Balanced...     ▼      │ ← Deja Balanced
│ Size (GB): 30                          │ ← Cambia a 30 GB
│                                         │
│ [SELECT]                               │ ← Clic aquí
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ FIREWALL                                │
│ ✅ Allow HTTP traffic                  │ ← ¡MUY IMPORTANTE!
│ ☐ Allow HTTPS traffic                  │ ← Opcional
└─────────────────────────────────────────┘

Baja hasta el final:

┌─────────────────────────────────────────┐
│ [CREATE]                               │ ← Clic aquí
└─────────────────────────────────────────┘
```

3. **Espera 1-2 minutos**

4. **Verás tu VM creada:**
```
┌─────────────────────────────────────────────────────────────┐
│ Name             Zone           Status    Connect           │
│ misw4411-rag-app us-central1-a  ● Running [SSH] [More]     │
│                                           ↑                  │
│                                           └─ Clic aquí       │
└─────────────────────────────────────────────────────────────┘
```

---

## 📍 PASO 2: Conectarte a la VM (1 minuto)

### Qué hacer:
1. **Clic en el botón `SSH`** junto a tu VM
2. **Se abrirá una ventana nueva con una terminal negra:**

```
┌────────────────────────────────────────────────────┐
│ Transferring SSH keys to the VM                   │
│ Connecting to misw4411-rag-app...                 │
│ █                                                  │
└────────────────────────────────────────────────────┘
```

3. **Después de unos segundos verás:**

```
┌────────────────────────────────────────────────────┐
│ Welcome to Ubuntu 22.04.3 LTS                     │
│                                                    │
│ username@misw4411-rag-app:~$█                     │
│                                                    │
└────────────────────────────────────────────────────┘
```

✅ **¡Ya estás dentro de la VM!**

---

## 📍 PASO 3: Instalar Docker (5 minutos)

### En la terminal de la VM, copia y pega esto:

```bash
sudo apt update && sudo apt install -y docker.io docker-compose git
```

### Qué verás:
```
Reading package lists... Done
Building dependency tree... Done
...
Setting up docker.io (24.0.5-0ubuntu1~22.04.1)
Setting up docker-compose (1.29.2-1)
...
Processing triggers for man-db
```

### Luego ejecuta:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Verifica:
```bash
docker --version
```

### Deberías ver:
```
Docker version 24.0.5, build ced0996
```

✅ **Docker instalado correctamente**

---

## 📍 PASO 4: Clonar el Proyecto desde GitHub (5 minutos)

### En la terminal de la VM:

```bash
# Ir al directorio home
cd ~

# Clonar el repositorio
git clone https://github.com/nicbot23/llm-despliegue.git

# Entrar al directorio
cd llm-despliegue
```

### Qué verás:
```
Cloning into 'llm-despliegue'...
remote: Enumerating objects: 245, done.
remote: Counting objects: 100% (245/245), done.
remote: Compressing objects: 100% (189/189), done.
remote: Total 245 (delta 78), reused 201 (delta 45), pack-reused 0
Receiving objects: 100% (245/245), 1.24 MiB | 2.15 MiB/s, done.
Resolving deltas: 100% (78/78), done.
```

### Verificar archivos:
```bash
ls -la
```

### Deberías ver:
```
drwxr-xr-x 8 username username 4096 Nov  1 10:30 .
drwxr-xr-x 3 username username 4096 Nov  1 10:29 ..
drwxr-xr-x 8 username username 4096 Nov  1 10:30 .git
-rw-r--r-- 1 username username 1234 Nov  1 10:30 docker-compose-gpt.yml
-rw-r--r-- 1 username username  890 Nov  1 10:30 docker-compose.yml
drwxr-xr-x 3 username username 4096 Nov  1 10:30 202515-MISW4411-Backend-Grupo20
drwxr-xr-x 3 username username 4096 Nov  1 10:30 MISW4411-Frontend-Template
drwxr-xr-x 2 username username 4096 Nov  1 10:30 nginx
-rw-r--r-- 1 username username 9876 Nov  1 10:30 README_DESPLIEGUE.md
...
```

✅ **Código clonado correctamente desde GitHub**

---

### 🔄 Alternativa: Si prefieres usar gcloud scp (Desde tu Mac)

<details>
<summary>Clic para ver método alternativo</summary>

1. **Abre una NUEVA terminal en tu Mac** (no la de la VM)

2. **Ejecuta:**
```bash
cd "/Users/nicolasibarra/uniandes/miso-uniandes/semestre4/ciclo 2/apps - basadas - llm"

gcloud compute scp --recurse \
    llm-despliegue/ \
    misw4411-rag-app:~/ \
    --zone=us-central1-a
```

### Qué verás en tu Mac:
```
Uploading: llm-despliegue/docker-compose-gpt.yml
Uploading: llm-despliegue/nginx/default-gpt.conf
Uploading: llm-despliegue/202515-MISW4411-Backend-Grupo20/Dockerfile
...
[================================================] 100% 
Transfer complete.
```

3. **Vuelve a la terminal de la VM:**
```bash
cd ~/llm-despliegue
ls -la
```

</details>

---

## 📍 PASO 5: Construir y Desplegar (15 minutos)

### En la terminal de la VM:

```bash
cd ~/llm-despliegue
docker-compose -f docker-compose-gpt.yml build
```

### Qué verás (toma 10-15 minutos):
```
Building backend
[+] Building 245.3s (12/12) FINISHED
 => [internal] load build definition
 => => transferring dockerfile: 1.89kB
 => [internal] load .dockerignore
 => CACHED [builder 1/5] FROM docker.io/library/python:3.10-slim
 => [builder 2/5] WORKDIR /app
 => [builder 3/5] COPY requirements.txt .
 => [builder 4/5] RUN pip install...
...
Step 12/12 : CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
Successfully built abc123def456
Successfully tagged misw4411-backend:latest

Building frontend
[+] Building 189.7s (10/10) FINISHED
...
Successfully built xyz789uvw123
Successfully tagged misw4411-frontend:latest
```

### Iniciar servicios:
```bash
docker-compose -f docker-compose-gpt.yml up -d
```

### Qué verás:
```
Creating network "despliegue_rag-misw" with driver "bridge"
Creating despliegue_backend_1  ... done
Creating despliegue_frontend_1 ... done
Creating despliegue_proxy_1    ... done
```

### Verificar:
```bash
docker-compose -f docker-compose-gpt.yml ps
```

### Deberías ver:
```
         Name                    Command          State         Ports
-------------------------------------------------------------------------
despliegue_backend_1    uvicorn main:app ...    Up      8000/tcp
despliegue_frontend_1   npm run preview ...     Up      3000/tcp
despliegue_proxy_1      /docker-entrypoint...   Up      0.0.0.0:80->80/tcp
```

✅ **¡Todos los servicios están corriendo!**

---

## 📍 PASO 6: Probar la Aplicación (2 minutos)

### En la VM, obtén tu IP:
```bash
curl ifconfig.me
```

### Verás algo como:
```
34.123.45.67
```

### Probar localmente en la VM:
```bash
curl http://localhost/
```

### Deberías ver HTML del frontend:
```
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>MISW4411</title>
...
```

### Probar el backend:
```bash
curl http://localhost/api/health
```

### Deberías ver (o similar):
```
{"status":"healthy","service":"MISW4411 Backend"}
```

---

## 🌐 PASO 7: Acceder desde tu Navegador

### En tu navegador (Chrome, Firefox, Safari):

1. **Ve a:** `http://34.123.45.67/` (usa TU IP)

### Deberías ver:
```
┌─────────────────────────────────────────────────┐
│ 🎓 Asistente Inteligente MISW4411              │
│                                                 │
│ Pregúntame sobre el curso o temas relacionados │
│                                                 │
│ ┌─────────────────────────────────────────┐   │
│ │ Hola 👋 Soy el Asistente Inteligente... │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ ┌─────────────────────────────────────────┐   │
│ │ Escribe tu pregunta aquí...        [>] │   │
│ └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

2. **Prueba el backend:** `http://34.123.45.67/api/health`

### Deberías ver:
```
{
  "status": "healthy",
  "service": "MISW4411 Backend"
}
```

✅ **¡TODO FUNCIONA!** 🎉

---

## 🎯 Si Algo No Funciona

### Problema: No puedo acceder desde el navegador

1. **Verifica el firewall en GCP Console:**
```
Ve a: VPC Network > Firewall
Busca: default-allow-http
```

Si no existe:
```
Clic en: CREATE FIREWALL RULE

Name: allow-http
Targets: All instances
Source IP: 0.0.0.0/0
Protocols: tcp:80

[CREATE]
```

2. **Verifica que los servicios estén corriendo:**
```bash
docker-compose -f docker-compose-gpt.yml ps
```

Todos deben decir "Up"

3. **Ver logs de errores:**
```bash
docker-compose -f docker-compose-gpt.yml logs
```

---

## 📊 Qué Esperar en Logs Normales

### Backend logs (normal):
```
INFO:     Started server process [1]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

### Frontend logs (normal):
```
  ➜  Local:   http://localhost:3000/
  ➜  Network: http://172.18.0.2:3000/
  ready in 1234 ms.
```

### Nginx logs (normal):
```
/docker-entrypoint.sh: Configuration complete; ready for start up
```

---

## 💡 Comandos Útiles Una Vez Desplegado

```bash
# Ver logs en tiempo real
docker-compose -f docker-compose-gpt.yml logs -f

# Reiniciar todo
docker-compose -f docker-compose-gpt.yml restart

# Detener todo
docker-compose -f docker-compose-gpt.yml down

# Iniciar de nuevo
docker-compose -f docker-compose-gpt.yml up -d

# Ver uso de CPU/RAM
docker stats
```

---

## ✅ Checklist Visual Final

```
✅ VM creada (verde en GCP Console)
✅ Conectado por SSH (ventana terminal abierta)
✅ Docker instalado (docker --version funciona)
✅ Código en ~/despliegue (ls muestra archivos)
✅ Imágenes construidas (docker images muestra 2 imágenes)
✅ 3 contenedores "Up" (docker ps muestra 3)
✅ Frontend carga en navegador
✅ Backend responde en /api/health
✅ Chat funciona (puedes hacer preguntas)
```

---

## 🎓 Para tu Profesor

Muéstrale:
1. **URL pública:** http://TU_IP/
2. **Arquitectura:** Los .md que creé
3. **Logs:** `docker-compose -f docker-compose-gpt.yml logs`
4. **Configuración:** Muestra `docker-compose-gpt.yml` y `default-gpt.conf`

---

## 📱 Captura de Pantalla de Éxito

Cuando todo funcione, verás:

**En GCP Console:**
```
● misw4411-rag-app - Running
```

**En tu navegador:**
```
http://TU_IP/ → Frontend cargando ✅
http://TU_IP/api/health → {"status":"healthy"} ✅
```

**En la terminal de la VM:**
```
$ docker ps
CONTAINER ID   IMAGE                    STATUS
abc123def456   misw4411-backend:latest  Up 10 minutes
789uvw012xyz   misw4411-frontend:latest Up 10 minutes
345mno678pqr   nginx:1.25-alpine        Up 10 minutes
```

---

**¡Eso es todo! Con estas imágenes mentales sabes exactamente qué esperar en cada paso.** 🚀

