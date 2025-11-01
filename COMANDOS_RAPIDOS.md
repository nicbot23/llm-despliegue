# ⚡ Comandos Rápidos - Copiar y Pegar

## 🎯 Lo Que Falta Para Desplegar (Resumen)

### ✅ Ya Tienes:
- Código listo y configurado
- `apikey.json` configurado
- Dockerfiles listos
- Docker Compose corregido

### 🔧 Te Falta:
1. **Crear VM en GCP** (manual, en Cloud Console)
2. **Instalar Docker en la VM** (comandos abajo)
3. **Subir el código a la VM** (comandos abajo)
4. **Ejecutar el despliegue** (1 comando)

---

## 📋 COMANDOS LISTOS - COPIA Y PEGA

### 1️⃣ Crear VM (Manual en GCP Console)

```
Ve a: https://console.cloud.google.com/compute/instances
Clic en: CREATE INSTANCE

Usa esta configuración:
- Name: misw4411-rag-app
- Region: us-central1
- Machine: e2-standard-2 (2 vCPU, 8 GB)
- Boot disk: Ubuntu 22.04 LTS, 30 GB
- Firewall: ✅ Allow HTTP traffic

Clic en: CREATE
```

### 2️⃣ Conectarte a la VM

```bash
# Opción A: Desde Cloud Console
# → Ve a Compute Engine > VM instances
# → Clic en "SSH" junto a tu VM

# Opción B: Desde tu terminal
gcloud compute ssh misw4411-rag-app --zone=us-central1-a
```

### 3️⃣ Instalar Docker (En la VM)

```bash
# COPIAR TODO ESTO Y PEGAR EN LA VM:

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
sudo apt install -y docker.io docker-compose

# Iniciar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker

# Verificar
docker --version
docker-compose --version

echo "✅ Docker instalado correctamente"
```

### 4️⃣ Subir el Proyecto (En la VM - Desde GitHub)

```bash
# OPCIÓN A: Con Git desde GitHub (RECOMENDADO ⭐)
# En la VM, ejecuta:

cd ~
git clone https://github.com/nicbot23/llm-despliegue.git
cd llm-despliegue

# Verificar que todo esté ahí
ls -la

# OPCIÓN B: Con gcloud scp (alternativa, desde tu Mac)
# Abre una terminal en tu Mac y ejecuta:

cd "/Users/nicolasibarra/uniandes/miso-uniandes/semestre4/ciclo 2/apps - basadas - llm"

gcloud compute scp --recurse \
    llm-despliegue/ \
    misw4411-rag-app:~/ \
    --zone=us-central1-a

# En la VM:
cd ~/llm-despliegue
```

### 5️⃣ Desplegar (En la VM)

```bash
# COPIAR TODO Y PEGAR EN LA VM:

# Ir al directorio (si usaste git clone)
cd ~/llm-despliegue

# Verificar archivos
ls -la

# Construir imágenes (toma 10-15 minutos)
docker-compose -f docker-compose-gpt.yml build

# Iniciar servicios
docker-compose -f docker-compose-gpt.yml up -d

# Verificar estado
docker-compose -f docker-compose-gpt.yml ps

# Ver logs
docker-compose -f docker-compose-gpt.yml logs -f

# Presiona Ctrl+C para salir de los logs
```

### 6️⃣ Obtener tu IP y Probar

```bash
# En la VM, obtener IP externa
curl ifconfig.me

# O desde tu Mac:
gcloud compute instances describe misw4411-rag-app \
    --zone=us-central1-a \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

# Probar localmente en la VM
curl http://localhost/
curl http://localhost/api/health
```

**Desde tu navegador:**
```
http://TU_IP_EXTERNA/
http://TU_IP_EXTERNA/api/health
```

---

## 🚨 Si el Puerto 80 NO Funciona

```bash
# Verificar firewall
gcloud compute firewall-rules list

# Crear regla HTTP
gcloud compute firewall-rules create allow-http-80 \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow HTTP"

# O desde GCP Console:
# VPC Network > Firewall > CREATE FIREWALL RULE
# - Name: allow-http-80
# - Targets: All instances in network
# - Source IP ranges: 0.0.0.0/0
# - Protocols and ports: tcp:80
```

---

## 📦 Método Alternativo: Comprimir y Subir

Si GitHub no funciona y tampoco `gcloud scp`:

```bash
# En tu Mac - Comprimir
cd "/Users/nicolasibarra/uniandes/miso-uniandes/semestre4/ciclo 2/apps - basadas - llm"

tar -czf llm-despliegue.tar.gz \
    --exclude='node_modules' \
    --exclude='__pycache__' \
    --exclude='chroma_db' \
    --exclude='logs' \
    --exclude='.git' \
    llm-despliegue/

# Verificar tamaño
ls -lh llm-despliegue.tar.gz

# Subir (intenta varias veces si falla)
gcloud compute scp llm-despliegue.tar.gz misw4411-rag-app:~/ --zone=us-central1-a

# En la VM - Descomprimir
cd ~
tar -xzf llm-despliegue.tar.gz
cd llm-despliegue

# Continuar con docker-compose...
docker-compose -f docker-compose-gpt.yml up -d
```

---

## 🔄 Comandos de Gestión Diaria

```bash
# Ver estado de servicios
docker-compose -f docker-compose-gpt.yml ps

# Ver logs en tiempo real
docker-compose -f docker-compose-gpt.yml logs -f

# Ver logs de un servicio específico
docker-compose -f docker-compose-gpt.yml logs -f backend
docker-compose -f docker-compose-gpt.yml logs -f frontend
docker-compose -f docker-compose-gpt.yml logs -f proxy

# Reiniciar servicios
docker-compose -f docker-compose-gpt.yml restart

# Detener servicios
docker-compose -f docker-compose-gpt.yml down

# Iniciar servicios
docker-compose -f docker-compose-gpt.yml up -d

# Reconstruir después de cambios
docker-compose -f docker-compose-gpt.yml up -d --build
```

---

## 💰 Apagar la VM (Ahorrar Dinero)

```bash
# Detener la VM (puedes iniciarla después)
gcloud compute instances stop misw4411-rag-app --zone=us-central1-a

# Iniciar la VM
gcloud compute instances start misw4411-rag-app --zone=us-central1-a

# Ver estado
gcloud compute instances list
```

---

## 🐛 Comandos de Debug

```bash
# Ver todos los contenedores (incluso detenidos)
docker ps -a

# Ver uso de recursos
docker stats

# Entrar a un contenedor
docker exec -it despliegue_backend_1 bash
docker exec -it despliegue_frontend_1 sh
docker exec -it despliegue_proxy_1 sh

# Ver configuración de nginx
docker exec despliegue_proxy_1 cat /etc/nginx/conf.d/default.conf

# Ver red de Docker
docker network ls
docker network inspect llm-despliegue_rag-misw

# Limpiar todo (CUIDADO: borra todo)
docker-compose -f docker-compose-gpt.yml down -v
docker system prune -a
```

---

## ⏱️ Tiempo Estimado Total

```
1. Crear VM en GCP           → 5 minutos
2. Instalar Docker            → 5 minutos
3. Subir proyecto            → 10 minutos
4. Construir imágenes        → 15 minutos
5. Iniciar servicios         → 2 minutos
6. Verificar funcionamiento  → 3 minutos

TOTAL: ~40 minutos
```

---

## 📱 Orden Exacto de Ejecución

```bash
# 1. En GCP Console → Crear VM (manual)

# 2. Conectar a la VM
gcloud compute ssh misw4411-rag-app --zone=us-central1-a

# 3. En la VM - Instalar Docker
sudo apt update && sudo apt install -y docker.io docker-compose git
sudo usermod -aG docker $USER
newgrp docker

# 4. En la VM - Clonar desde GitHub
cd ~
git clone https://github.com/nicbot23/llm-despliegue.git
cd llm-despliegue

# 5. En la VM - Desplegar
docker-compose -f docker-compose-gpt.yml build
docker-compose -f docker-compose-gpt.yml up -d

# 6. En la VM - Obtener IP
curl ifconfig.me

# 7. En tu navegador
# http://TU_IP/
```

---

## ✅ Checklist Rápida

```
□ VM creada en GCP
□ Conectado a VM por SSH
□ Docker instalado en VM
□ Código subido a VM
□ docker-compose build ejecutado
□ docker-compose up -d ejecutado
□ 3 contenedores corriendo
□ Frontend accesible en navegador
□ Backend responde en /api/health
```

---

## 🎯 Comando Único (Todo en uno)

Si ya tienes la VM con Docker instalado y el código clonado:

```bash
cd ~/llm-despliegue && \
docker-compose -f docker-compose-gpt.yml build && \
docker-compose -f docker-compose-gpt.yml up -d && \
docker-compose -f docker-compose-gpt.yml ps && \
echo "✅ Despliegue completado. IP externa:" && \
curl -s ifconfig.me
```

---

**¡Listo para copiar y pegar! 🚀**

