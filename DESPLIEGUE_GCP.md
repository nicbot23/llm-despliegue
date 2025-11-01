# 🚀 Guía de Despliegue en GCP

## ✅ Estado del Proyecto

### Archivos Corregidos y Listos
- ✅ **docker-compose-gpt.yml** - Corregido y listo para usar
- ✅ **nginx/default-gpt.conf** - Configuración completa con frontend y backend
- ✅ **appConfig.ts** - Configurado para usar rutas relativas con proxy
- ✅ **Dockerfiles** - Ambos (backend y frontend) están listos

---

## 📋 Arquitectura del Despliegue

```
Internet (Puerto 80)
        ↓
    [Nginx Proxy]
        ↓
    ┌───────┴───────┐
    ↓               ↓
[Frontend:3000] [Backend:8000]
    (React)      (FastAPI)
```

### Flujo de Peticiones:
- **`http://tu-vm-ip/`** → Frontend (React + Vite)
- **`http://tu-vm-ip/api/`** → Backend (FastAPI)

---

## 🛠️ Instrucciones de Despliegue

### 1. Preparar la VM en GCP

```bash
# Instalar Docker y Docker Compose
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# Agregar tu usuario al grupo docker (opcional, para no usar sudo)
sudo usermod -aG docker $USER
```

### 2. Clonar o Subir el Proyecto

```bash
# Opción 1: Clonar desde Git
git clone <tu-repositorio>
cd despliegue

# Opción 2: Subir con SCP desde tu máquina local
# scp -r /path/local/despliegue usuario@vm-ip:/home/usuario/
```

### 3. Configurar el Backend (Si es necesario)

Asegúrate de que el archivo `apikey.json` esté en la carpeta del backend:
```bash
# Verificar que existe
ls 202515-MISW4411-Backend-Grupo20/apikey.json
```

Si usas variables de entorno, agrégalas al `docker-compose-gpt.yml`:
```yaml
backend:
  environment:
    - UVICORN_WORKERS=2
    - OPENAI_API_KEY=${OPENAI_API_KEY}  # Si necesitas
    - GOOGLE_API_KEY=${GOOGLE_API_KEY}   # Si necesitas
```

### 4. Abrir Puertos en GCP

En la consola de GCP, configura las reglas de firewall:
- **Puerto 80** (HTTP) - DEBE estar abierto
- **Puerto 443** (HTTPS) - Opcional, para SSL/TLS

```bash
# Desde Cloud Shell o gcloud CLI
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow HTTP traffic"
```

### 5. Construir y Ejecutar

```bash
# Navegar al directorio principal
cd /Users/nicolasibarra/uniandes/miso-uniandes/semestre4/ciclo\ 2/apps\ -\ basadas\ -\ llm/despliegue

# Construir las imágenes (primera vez o después de cambios)
docker-compose -f docker-compose-gpt.yml build

# Iniciar los servicios
docker-compose -f docker-compose-gpt.yml up -d

# Ver logs
docker-compose -f docker-compose-gpt.yml logs -f

# Ver estado
docker-compose -f docker-compose-gpt.yml ps
```

### 6. Verificar el Despliegue

```bash
# Verificar que los contenedores estén corriendo
docker ps

# Debería mostrar 3 contenedores:
# - despliegue_backend_1
# - despliegue_frontend_1
# - despliegue_proxy_1

# Probar desde la VM
curl http://localhost/api/health  # Backend
curl http://localhost/           # Frontend

# Probar desde tu navegador
# http://<IP-EXTERNA-VM>/
# http://<IP-EXTERNA-VM>/api/health
```

---

## 🔧 Comandos Útiles

### Reiniciar Servicios
```bash
docker-compose -f docker-compose-gpt.yml restart
```

### Detener Todo
```bash
docker-compose -f docker-compose-gpt.yml down
```

### Reconstruir un Servicio Específico
```bash
# Solo backend
docker-compose -f docker-compose-gpt.yml up -d --build backend

# Solo frontend
docker-compose -f docker-compose-gpt.yml up -d --build frontend
```

### Ver Logs de un Servicio
```bash
docker-compose -f docker-compose-gpt.yml logs -f backend
docker-compose -f docker-compose-gpt.yml logs -f frontend
docker-compose -f docker-compose-gpt.yml logs -f proxy
```

### Limpiar Recursos
```bash
# Detener y eliminar contenedores, redes
docker-compose -f docker-compose-gpt.yml down

# Eliminar también volúmenes
docker-compose -f docker-compose-gpt.yml down -v

# Limpiar imágenes sin usar
docker system prune -a
```

---

## 🐛 Troubleshooting

### Problema 1: No se puede acceder desde el navegador

**Síntomas:** Timeout o "No se puede acceder al sitio"

**Soluciones:**
1. Verificar que el puerto 80 esté abierto en GCP
2. Verificar que nginx esté corriendo: `docker ps | grep proxy`
3. Ver logs de nginx: `docker-compose -f docker-compose-gpt.yml logs proxy`

### Problema 2: Frontend carga pero no se conecta al backend

**Síntomas:** Errores de red en la consola del navegador

**Soluciones:**
1. Verificar que el backend esté corriendo: `curl http://localhost/api/health`
2. Ver logs del backend: `docker-compose -f docker-compose-gpt.yml logs backend`
3. Verificar la configuración de nginx en `default-gpt.conf`

### Problema 3: Error al construir las imágenes

**Síntomas:** `docker-compose build` falla

**Soluciones:**
1. Verificar que `apikey.json` exista en el backend
2. Verificar conexión a internet para descargar dependencias
3. Limpiar cache de Docker: `docker builder prune`

### Problema 4: Contenedor se reinicia constantemente

**Síntomas:** `docker ps` muestra "Restarting"

**Soluciones:**
1. Ver logs: `docker-compose -f docker-compose-gpt.yml logs <servicio>`
2. Verificar variables de entorno necesarias
3. Verificar que los puertos no estén ocupados

---

## 📊 Monitoreo

### Ver Uso de Recursos
```bash
docker stats
```

### Ver Logs en Tiempo Real
```bash
docker-compose -f docker-compose-gpt.yml logs -f --tail=100
```

### Verificar Salud de los Servicios
```bash
# Health check del backend
curl http://localhost/api/health

# Si tienes endpoints de health
curl http://localhost/api/v1/health
```

---

## 🔒 Seguridad (Recomendaciones)

### 1. Usar HTTPS (Producción)
Considera usar Let's Encrypt con Certbot:
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d tu-dominio.com
```

### 2. Variables de Entorno
No hardcodear API keys. Usa archivos `.env`:
```bash
# Crear archivo .env
cat > .env << EOF
OPENAI_API_KEY=tu-key-aqui
GOOGLE_API_KEY=tu-key-aqui
EOF

# En docker-compose-gpt.yml
services:
  backend:
    env_file:
      - .env
```

### 3. Limitar Acceso
Si solo necesitas acceso desde ciertas IPs:
```bash
gcloud compute firewall-rules create allow-http-specific \
    --allow tcp:80 \
    --source-ranges=TU_IP/32
```

---

## 📝 Resumen de Archivos Clave

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `docker-compose-gpt.yml` | Orquestación de servicios | ✅ Corregido |
| `nginx/default-gpt.conf` | Proxy inverso | ✅ Listo |
| `202515-MISW4411-Backend-Grupo20/Dockerfile` | Imagen backend | ✅ Listo |
| `MISW4411-Frontend-Template/Dockerfile` | Imagen frontend | ✅ Listo |
| `appConfig.ts` | Config frontend | ✅ Corregido |

---

## ✅ Checklist de Despliegue

- [ ] VM creada en GCP
- [ ] Docker y Docker Compose instalados
- [ ] Puerto 80 abierto en firewall
- [ ] Código subido a la VM
- [ ] `apikey.json` configurado (si aplica)
- [ ] Variables de entorno configuradas (si aplica)
- [ ] `docker-compose -f docker-compose-gpt.yml build` ejecutado exitosamente
- [ ] `docker-compose -f docker-compose-gpt.yml up -d` ejecutado exitosamente
- [ ] Frontend accesible desde navegador
- [ ] Backend responde en `/api/health`
- [ ] Chat funciona correctamente

---

## 🎯 Próximos Pasos

1. **Desarrollo Local vs Producción:**
   - Para desarrollo local: cambiar `BACKEND_URL` a `"http://127.0.0.1:8000"` en `appConfig.ts`
   - Para producción: mantener `BACKEND_URL: "/api"` (actual)

2. **Mejorar el Frontend:**
   - Considera usar nginx estático en lugar de `npm run preview`
   - Ver `MEJORAS_FRONTEND.md` para más detalles (próximo documento)

3. **Monitoreo:**
   - Considera agregar herramientas como Prometheus/Grafana
   - Configurar alertas para caídas de servicio

---

## 📞 Contacto y Soporte

Si tienes problemas:
1. Revisa los logs: `docker-compose -f docker-compose-gpt.yml logs`
2. Verifica el estado: `docker-compose -f docker-compose-gpt.yml ps`
3. Consulta este documento
4. Revisa la documentación de GCP

---

**Fecha de Última Actualización:** 1 de Noviembre, 2025  
**Versión:** 1.0

