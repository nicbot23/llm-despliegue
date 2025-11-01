# 🚀 Despliegue RAG App - MISW4411

Configuración de despliegue para la aplicación RAG en Google Cloud Platform.

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Git instalado

## ⚡ Inicio Rápido

### 1. Clonar este repositorio

```bash
git clone https://github.com/nicbot23/llm-despliegue.git
cd llm-despliegue
```

### 2. Clonar los repositorios de Backend y Frontend

```bash
./setup-repos.sh
```

O manualmente:

```bash
# Backend
git clone https://github.com/MISW4411-Aplicaciones-basadas-en-LLMs/202515-MISW4411-Backend-Grupo20.git

# Frontend
git clone https://github.com/MISW4411-Aplicaciones-basadas-en-LLMs/MISW4411-Frontend-Template.git
```

### 3. Desplegar con Docker Compose

```bash
# Construir imágenes
docker-compose -f docker-compose-gpt.yml build

# Iniciar servicios
docker-compose -f docker-compose-gpt.yml up -d

# Verificar estado
docker-compose -f docker-compose-gpt.yml ps
```

### 4. Acceder a la aplicación

- Frontend: `http://localhost/` o `http://TU_IP/`
- Backend API: `http://localhost/api/` o `http://TU_IP/api/`
- Health Check: `http://localhost/api/health`

## 🏗️ Arquitectura

```
llm-despliegue/
├── docker-compose-gpt.yml          # Orquestación de servicios
├── nginx/
│   └── default-gpt.conf            # Configuración Nginx
├── setup-repos.sh                  # Script para clonar repos
├── 202515-MISW4411-Backend-Grupo20/ # ← Se clona con setup-repos.sh
└── MISW4411-Frontend-Template/     # ← Se clona con setup-repos.sh
```

## 🔄 Actualizar Código

```bash
# Actualizar backend
cd 202515-MISW4411-Backend-Grupo20
git pull
cd ..

# Actualizar frontend
cd MISW4411-Frontend-Template
git pull
cd ..

# Reconstruir y reiniciar
docker-compose -f docker-compose-gpt.yml up -d --build
```

## 🛠️ Comandos Útiles

```bash
# Ver logs
docker-compose -f docker-compose-gpt.yml logs -f

# Reiniciar servicios
docker-compose -f docker-compose-gpt.yml restart

# Detener servicios
docker-compose -f docker-compose-gpt.yml down

# Ver estado
docker-compose -f docker-compose-gpt.yml ps
```

## 🌐 Despliegue en GCP

### Paso 1: Crear VM en GCP

```
- Machine: e2-standard-2 (2 vCPU, 8 GB)
- OS: Ubuntu 22.04 LTS
- Firewall: Allow HTTP traffic
```

### Paso 2: Instalar dependencias en la VM

```bash
sudo apt update
sudo apt install -y docker.io docker-compose git
sudo usermod -aG docker $USER
newgrp docker
```

### Paso 3: Clonar y configurar

```bash
cd ~
git clone https://github.com/nicbot23/llm-despliegue.git
cd llm-despliegue
./setup-repos.sh
```

### Paso 4: Desplegar

```bash
docker-compose -f docker-compose-gpt.yml build
docker-compose -f docker-compose-gpt.yml up -d
```

### Paso 5: Obtener IP y probar

```bash
curl ifconfig.me
# Visita http://TU_IP/ en tu navegador
```

## 📚 Documentación

- `docker-compose-gpt.yml` - Configuración de servicios
- `nginx/default-gpt.conf` - Configuración del proxy inverso
- `setup-repos.sh` - Script de inicialización

## 🆘 Troubleshooting

### Error: "unable to prepare context"

```bash
# Ejecuta setup-repos.sh para clonar los repositorios
./setup-repos.sh
```

### Puertos en uso

```bash
# Detener servicios existentes
docker-compose -f docker-compose-gpt.yml down
sudo lsof -i :80
```

### Permisos de Docker

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## 📄 Licencia

Este es un proyecto académico para MISW4411 - Aplicaciones basadas en LLMs.

---

**Universidad de los Andes** | **MISW4411** | **2025-1**
