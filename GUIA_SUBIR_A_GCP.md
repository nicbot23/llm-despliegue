# 🚀 Guía Práctica: Cómo Subir tu Proyecto a GCP

## 📋 Checklist de Lo Que Necesitas

### ✅ Ya Tienes (Confirmado):
- ✅ Proyecto configurado localmente
- ✅ `apikey.json` configurado
- ✅ `docker-compose-gpt.yml` corregido
- ✅ `nginx/default-gpt.conf` listo
- ✅ Dockerfiles funcionales

### 🔧 Necesitas en GCP:
- [ ] VM (Máquina Virtual) creada
- [ ] Puerto 80 abierto en firewall
- [ ] Docker instalado en la VM
- [ ] Código subido a la VM

---

## 🎯 Opción 1: Método Rápido (Recomendado para Principiantes)

### Paso 1: Crear la VM en GCP

1. **Ve a Google Cloud Console:**
   - https://console.cloud.google.com/
   - Selecciona tu proyecto: `misw4411-apps-474904`

2. **Crear una VM:**
   ```
   - Ve a: Compute Engine > VM instances
   - Clic en "CREATE INSTANCE"
   
   Configuración recomendada:
   ┌─────────────────────────────────────┐
   │ Name: misw4411-rag-app              │
   │ Region: us-central1                 │
   │ Zone: us-central1-a                 │
   │                                     │
   │ Machine type:                       │
   │   - e2-medium (2 vCPU, 4 GB RAM)   │
   │   O MEJOR:                          │
   │   - e2-standard-2 (2 vCPU, 8 GB)   │
   │                                     │
   │ Boot disk:                          │
   │   - Ubuntu 22.04 LTS                │
   │   - Size: 30 GB                     │
   │                                     │
   │ Firewall:                           │
   │   ✅ Allow HTTP traffic             │
   │   ✅ Allow HTTPS traffic            │
   └─────────────────────────────────────┘
   ```

3. **Clic en "CREATE"** y espera 1-2 minutos

### Paso 2: Conectarte a la VM

**Opción A: Desde Cloud Console (Más Fácil)**
```bash
# En Cloud Console, clic en "SSH" junto a tu VM
# Se abrirá una terminal en el navegador
```

**Opción B: Desde tu Terminal Local**
```bash
# Instala gcloud CLI si no lo tienes
# Mac: brew install google-cloud-sdk
# Linux/Windows: https://cloud.google.com/sdk/docs/install

# Conectarse
gcloud compute ssh misw4411-rag-app --zone=us-central1-a
```

### Paso 3: Instalar Docker en la VM

Una vez conectado a la VM, ejecuta estos comandos:

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker y Git
sudo apt install -y docker.io docker-compose git

# Iniciar y habilitar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Agregar tu usuario al grupo docker (para no usar sudo)
sudo usermod -aG docker $USER

# Aplicar cambios (o cierra y reabre la sesión SSH)
newgrp docker

# Verificar instalación
docker --version
docker-compose --version
```

### Paso 4: Subir tu Proyecto a la VM

**Opción A: Usando Git desde GitHub (RECOMENDADO ⭐)**

```bash
# En la VM
cd ~
git clone https://github.com/nicbot23/llm-despliegue.git
cd llm-despliegue

# Verificar que todo esté ahí
ls -la

# Deberías ver: docker-compose-gpt.yml, nginx/, 202515-MISW4411-Backend-Grupo20/, etc.
```

**Opción B: Usando SCP desde tu Mac (Alternativa)**

```bash
# En tu Mac (terminal local)
cd "/Users/nicolasibarra/uniandes/miso-uniandes/semestre4/ciclo 2/apps - basadas - llm"

# Subir todo el proyecto (toma 5-10 minutos)
gcloud compute scp --recurse llm-despliegue/ misw4411-rag-app:~/ --zone=us-central1-a

# En la VM, entrar al directorio
cd ~/llm-despliegue
```

**Opción C: Usando el Editor de Cloud Console**

```bash
# En la VM
mkdir -p ~/despliegue
cd ~/despliegue

# Luego copia y pega los archivos manualmente
# O sube un archivo .tar.gz comprimido
```

### Paso 5: Desplegar en la VM

```bash
# En la VM, ve al directorio del proyecto
cd ~/llm-despliegue

# Verificar que todo esté ahí
ls -la
# Deberías ver: docker-compose-gpt.yml, nginx/, 202515-MISW4411-Backend-Grupo20/, etc.

# Construir las imágenes (toma 10-15 minutos la primera vez)
docker-compose -f docker-compose-gpt.yml build

# Iniciar los servicios
docker-compose -f docker-compose-gpt.yml up -d

# Verificar que estén corriendo
docker-compose -f docker-compose-gpt.yml ps

# Ver logs
docker-compose -f docker-compose-gpt.yml logs -f
```

### Paso 6: Probar tu Aplicación

```bash
# En la VM, probar localmente
curl http://localhost/
curl http://localhost/api/health

# Obtener tu IP externa
curl ifconfig.me
```

**Desde tu navegador:**
```
http://TU_IP_EXTERNA/           → Frontend
http://TU_IP_EXTERNA/api/health → Backend
```

---

## 🎯 Opción 2: Método Avanzado (Usando Script Automatizado)

Si quieres usar el script que creé:

```bash
# En la VM, después de clonar el proyecto
cd ~/llm-despliegue

# Dar permisos de ejecución
chmod +x deploy-gcp.sh

# Ejecutar
./deploy-gcp.sh
```

El script hace todo automáticamente:
- ✅ Verifica que Docker esté instalado
- ✅ Construye las imágenes
- ✅ Inicia los servicios
- ✅ Verifica el estado
- ✅ Prueba los endpoints

---

## 🔥 Comandos de GCloud Útiles

### Firewall (Si el puerto 80 no está abierto)

```bash
# Verificar reglas de firewall
gcloud compute firewall-rules list

# Crear regla para HTTP (puerto 80)
gcloud compute firewall-rules create allow-http-misw4411 \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow HTTP traffic for MISW4411"

# Aplicar tag a la VM
gcloud compute instances add-tags misw4411-rag-app \
    --tags http-server \
    --zone us-central1-a
```

### Gestión de la VM

```bash
# Ver tus VMs
gcloud compute instances list

# Detener la VM (para ahorrar dinero cuando no la uses)
gcloud compute instances stop misw4411-rag-app --zone=us-central1-a

# Iniciar la VM
gcloud compute instances start misw4411-rag-app --zone=us-central1-a

# Ver IP externa
gcloud compute instances describe misw4411-rag-app \
    --zone=us-central1-a \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

---

## 📦 Método Alternativo: Subir Archivo Comprimido

Si SCP o Git no funcionan:

### En tu Mac:
```bash
cd "/Users/nicolasibarra/uniandes/miso-uniandes/semestre4/ciclo 2/apps - basadas - llm"

# Comprimir el proyecto (excluye archivos innecesarios)
tar -czf llm-despliegue.tar.gz \
    --exclude='node_modules' \
    --exclude='__pycache__' \
    --exclude='chroma_db' \
    --exclude='logs' \
    --exclude='.git' \
    llm-despliegue/

# Verificar tamaño
ls -lh llm-despliegue.tar.gz
```

### Subir a la VM:
```bash
# Opción 1: Con gcloud
gcloud compute scp llm-despliegue.tar.gz misw4411-rag-app:~/ --zone=us-central1-a

# Opción 2: Subir a Google Drive y descargar desde la VM
# - Sube llm-despliegue.tar.gz a tu Google Drive
# - En la VM usa: gdown o wget con link compartido
```

### En la VM:
```bash
# Descomprimir
cd ~
tar -xzf llm-despliegue.tar.gz

# Continuar con el despliegue
cd llm-despliegue
docker-compose -f docker-compose-gpt.yml up -d
```

---

## 🐛 Solución de Problemas Comunes

### Problema 1: No puedo conectarme a la VM
```bash
# Verificar que la VM está corriendo
gcloud compute instances list

# Reiniciar la VM
gcloud compute instances reset misw4411-rag-app --zone=us-central1-a
```

### Problema 2: Puerto 80 no responde
```bash
# En la VM, verificar servicios
docker-compose -f docker-compose-gpt.yml ps

# Verificar que nginx esté escuchando
sudo netstat -tulpn | grep :80

# Ver logs
docker-compose -f docker-compose-gpt.yml logs proxy
```

### Problema 3: Docker dice "permission denied"
```bash
# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker

# O usar sudo temporalmente
sudo docker-compose -f docker-compose-gpt.yml up -d
```

### Problema 4: Build falla por falta de memoria
```bash
# Si tu VM es muy pequeña (menos de 4GB RAM)
# Construye localmente y sube las imágenes

# En tu Mac:
docker-compose -f docker-compose-gpt.yml build

# Guardar imágenes
docker save -o backend.tar misw4411-backend:latest
docker save -o frontend.tar misw4411-frontend:latest

# Subir a la VM
gcloud compute scp backend.tar frontend.tar misw4411-rag-app:~/ --zone=us-central1-a

# En la VM, cargar imágenes
docker load -i backend.tar
docker load -i frontend.tar

# Iniciar servicios
docker-compose -f docker-compose-gpt.yml up -d
```

---

## 📊 Checklist Final de Despliegue

Antes de dar por terminado:

### En GCP:
- [ ] VM creada y corriendo
- [ ] Firewall permite HTTP (puerto 80)
- [ ] IP externa asignada y anotada

### En la VM:
- [ ] Docker instalado: `docker --version`
- [ ] Docker Compose instalado: `docker-compose --version`
- [ ] Git instalado: `git --version`
- [ ] Proyecto clonado: `ls ~/llm-despliegue/`
- [ ] Imágenes construidas: `docker images`
- [ ] Servicios corriendo: `docker-compose -f docker-compose-gpt.yml ps`

### Pruebas:
- [ ] Frontend accesible: `http://TU_IP/`
- [ ] Backend responde: `http://TU_IP/api/health`
- [ ] Chat funciona correctamente
- [ ] Puedes hacer preguntas y recibir respuestas

---

## 💰 Tips para Ahorrar Dinero en GCP

```bash
# Detener la VM cuando no la uses (fin de semana, noche)
gcloud compute instances stop misw4411-rag-app --zone=us-central1-a

# Iniciar cuando la necesites
gcloud compute instances start misw4411-rag-app --zone=us-central1-a

# Ver costos estimados
# Ve a: Cloud Console > Billing > Reports
```

**Costo aproximado:**
- e2-medium: ~$25/mes (corriendo 24/7)
- e2-medium: ~$12/mes (corriendo 8 horas/día)

---

## 🎓 Para la Evaluación del Curso

Asegúrate de tener:
1. ✅ URL pública funcionando
2. ✅ Frontend cargando correctamente
3. ✅ Backend respondiendo
4. ✅ Arquitectura documentada (ya tienes los .md)
5. ✅ Logs accesibles: `docker-compose -f docker-compose-gpt.yml logs`

---

## 📞 Próximos Pasos

**Ahora mismo puedes hacer:**

1. **Crear la VM** (5 minutos)
   - Ve a GCP Console → Compute Engine → Create Instance

2. **Conectarte por SSH** (1 minuto)
   - Clic en "SSH" en la VM

3. **Instalar Docker** (5 minutos)
   - Copia y pega los comandos del Paso 3

4. **Subir el proyecto** (10 minutos)
   - Usa gcloud scp o git clone

5. **Desplegar** (15 minutos)
   - `docker-compose -f docker-compose-gpt.yml up -d`

**Total: ~35-40 minutos** ⏱️

---

## ❓ ¿Necesitas Ayuda Específica?

Si tienes problemas en algún paso, pregúntame y te ayudo con:
- Comandos específicos de gcloud
- Configuración de firewall
- Debugging de errores
- Optimización de la VM

¡Estoy aquí para ayudarte! 🚀

