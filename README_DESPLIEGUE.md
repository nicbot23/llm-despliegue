# 📚 Índice de Documentación de Despliegue

## 🎯 Respuesta Rápida a tus Preguntas

### ¿Los Dockerfiles están listos?
✅ **SÍ** - Backend y Frontend están listos para GCP

### ¿Qué nginx usar?
✅ **`nginx/default-gpt.conf`** - Tiene frontend Y backend configurado

### ¿Qué docker-compose usar?
✅ **`docker-compose-gpt.yml`** - Ya corregido y listo

### ¿Cómo subir el código?
✅ **GitHub** - `git clone https://github.com/nicbot23/llm-despliegue.git`  
(Ver `CAMBIOS_GITHUB.md` para detalles)

### ¿Qué falta para desplegar?
1. Crear VM en GCP
2. Instalar Docker y Git
3. Clonar desde GitHub
4. Ejecutar `docker-compose -f docker-compose-gpt.yml up -d`

**Tiempo total: ~40 minutos**

---

## 📖 Documentos Creados

### 🚀 Para Empezar YA (Elige uno):

1. **`COMANDOS_RAPIDOS.md`** ⚡ ← EMPIEZA AQUÍ
   - Comandos listos para copiar y pegar
   - Sin explicaciones largas, solo comandos
   - Perfecto si ya sabes qué hacer

2. **`PASOS_VISUALES_GCP.md`** 👁️ ← O AQUÍ SI ES TU PRIMERA VEZ
   - Qué verás en cada pantalla de GCP
   - Capturas de texto de lo que aparecerá
   - Paso a paso muy detallado

### 📚 Para Entender Más:

3. **`GUIA_SUBIR_A_GCP.md`** 📘
   - Guía completa y detallada
   - Múltiples opciones para subir código
   - Solución de problemas
   - Tips para ahorrar dinero

4. **`DESPLIEGUE_GCP.md`** 📗
   - Arquitectura del sistema
   - Flujo de peticiones
   - Monitoreo y seguridad
   - Comandos de gestión

### 🔍 Para Comparar Opciones:

5. **`RESUMEN_DESPLIEGUE.md`** 📊
   - Resumen ejecutivo
   - Respuestas directas
   - Checklist final
   - Tabla de archivos

6. **`COMPARACION_ARCHIVOS.md`** 🔬
   - Comparación lado a lado
   - Por qué usar cada archivo
   - Diferencias explicadas
   - Flujo de peticiones

7. **`CAMBIOS_GITHUB.md`** 🔄 ← NUEVO
   - Cambios para usar GitHub
   - Método actualizado de despliegue
   - Ventajas del nuevo flujo
   - Troubleshooting para Git

### ⚙️ Mejoras Opcionales:

8. **`MEJORAS_FRONTEND_DOCKERFILE.md`** 🎨
   - Optimizaciones opcionales
   - NO necesarias para funcionar
   - Para producción avanzada

### 🤖 Script Automatizado:

9. **`deploy-gcp.sh`** 🛠️
   - Script para automatizar todo
   - Opcional, puedes usar comandos manuales

---

## 🎯 Ruta Recomendada Según tu Nivel

### 🟢 Primera vez con GCP y Docker:
```
1. Lee: PASOS_VISUALES_GCP.md
2. Usa: COMANDOS_RAPIDOS.md (para copiar comandos)
3. Si hay problemas: GUIA_SUBIR_A_GCP.md (troubleshooting)
```

### 🟡 Ya usaste Docker antes:
```
1. Lee: COMANDOS_RAPIDOS.md
2. Ejecuta los comandos
3. Si hay problemas: DESPLIEGUE_GCP.md (sección troubleshooting)
```

### 🔴 Experiencia con GCP y Docker:
```
1. Lee: RESUMEN_DESPLIEGUE.md (checklist)
2. Ejecuta: ./deploy-gcp.sh
3. Done ✅
```

---

## ⚡ Inicio Rápido (TL;DR)

```bash
# 1. Crea VM en GCP Console (manual)
#    - Nombre: misw4411-rag-app
#    - Machine: e2-standard-2
#    - OS: Ubuntu 22.04
#    - Firewall: ✅ Allow HTTP

# 2. Instala Docker (en la VM)
sudo apt update && sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER && newgrp docker

# 3. Clona desde GitHub (en la VM)
cd ~
git clone https://github.com/nicbot23/llm-despliegue.git
cd llm-despliegue

# 4. Despliega (en la VM)
docker-compose -f docker-compose-gpt.yml build
docker-compose -f docker-compose-gpt.yml up -d

# 5. Obtén IP y prueba
curl ifconfig.me
# Abre http://TU_IP/ en tu navegador
```

---

## 📁 Estructura de Archivos del Proyecto

```
llm-despliegue/                        ← Repo de GitHub
│
├── 📄 docker-compose-gpt.yml          ← USAR ESTE ✅
├── 📄 docker-compose.yml              ← NO usar
│
├── nginx/
│   ├── 📄 default-gpt.conf            ← USAR ESTE ✅
│   └── 📄 default.conf                ← NO usar
│
├── 202515-MISW4411-Backend-Grupo20/
│   ├── 📄 Dockerfile                  ← Listo ✅
│   ├── 📄 main.py
│   ├── 📄 requirements.txt
│   ├── 📄 apikey.json                 ← Ya tienes esto ✅
│   └── app/
│
├── MISW4411-Frontend-Template/
│   ├── 📄 Dockerfile                  ← Listo ✅
│   ├── 📄 package.json
│   └── src/
│       └── config/
│           └── 📄 appConfig.ts        ← Corregido ✅
│
└── 📚 DOCUMENTACIÓN (NUEVA):
    ├── README_DESPLIEGUE.md           ← Estás aquí
    ├── CAMBIOS_GITHUB.md              🔄 Cambios para GitHub
    ├── COMANDOS_RAPIDOS.md            ⚡ Empieza aquí
    ├── PASOS_VISUALES_GCP.md          👁️ O aquí
    ├── GUIA_SUBIR_A_GCP.md            📘 Guía completa
    ├── DESPLIEGUE_GCP.md              📗 Detalles técnicos
    ├── RESUMEN_DESPLIEGUE.md          📊 Resumen ejecutivo
    ├── COMPARACION_ARCHIVOS.md        🔬 Comparaciones
    ├── MEJORAS_FRONTEND_DOCKERFILE.md 🎨 Opcional
    └── deploy-gcp.sh                  🛠️ Script automático
```

---

## ✅ Cambios Realizados en tu Proyecto

Solo 2 archivos modificados:

### 1. `docker-compose-gpt.yml`
```yaml
# ANTES:
context: ./MISW4411-Backend
volumes:
  - ./nginx/default.conf:...

# AHORA:
context: ./202515-MISW4411-Backend-Grupo20  ✅
volumes:
  - ./nginx/default-gpt.conf:...            ✅
```

### 2. `appConfig.ts`
```typescript
// ANTES:
BACKEND_URL: "http://127.0.0.1:8000",
API_ENDPOINT: "/api/v1/ask",

// AHORA:
BACKEND_URL: "/api",        ✅
API_ENDPOINT: "/v1/ask",    ✅
```

Estos cambios son **necesarios** para que funcione en GCP con Docker.

---

## 🎓 Para tu Evaluación

### Entregables:
1. ✅ URL pública funcionando: `http://TU_IP/`
2. ✅ Arquitectura documentada (en los .md)
3. ✅ Configuración lista (docker-compose + nginx)
4. ✅ Aplicación funcional (frontend + backend)

### Documentos a mencionar:
- `docker-compose-gpt.yml` - Orquestación
- `nginx/default-gpt.conf` - Proxy inverso
- `Dockerfiles` - Containerización
- Arquitectura explicada en `DESPLIEGUE_GCP.md`

---

## 🆘 Si Tienes Problemas

### 1. Error al crear VM:
→ Revisa: `GUIA_SUBIR_A_GCP.md` - Sección "Crear VM"

### 2. No puedo conectarme por SSH:
→ Usa: SSH desde Cloud Console (botón SSH en la VM)

### 3. Docker no se instala:
→ Ejecuta: `sudo apt update` primero

### 4. No puedo subir el código:
→ Usa: Método de archivo comprimido en `GUIA_SUBIR_A_GCP.md`

### 5. Puerto 80 no responde:
→ Revisa: `COMANDOS_RAPIDOS.md` - Sección "Firewall"

### 6. Contenedores no inician:
→ Ejecuta: `docker-compose -f docker-compose-gpt.yml logs`

---

## 📊 Arquitectura Final

```
                    INTERNET
                       ↓
                 Puerto 80 (GCP)
                       ↓
               ┌───────────────┐
               │  Nginx Proxy  │
               │  (Puerto 80)  │
               └───────┬───────┘
                       │
         ┌─────────────┴─────────────┐
         ↓                           ↓
   ┌──────────┐               ┌──────────┐
   │ Frontend │               │ Backend  │
   │  :3000   │               │  :8000   │
   │  (React) │               │ (FastAPI)│
   └──────────┘               └──────────┘
   
   Red interna: rag-misw
   Todos los contenedores: Docker
```

---

## 🎯 Próximos Pasos INMEDIATOS

1. **Ahora mismo, abre:** `COMANDOS_RAPIDOS.md` o `PASOS_VISUALES_GCP.md`

2. **Ve a GCP Console:** https://console.cloud.google.com/

3. **Crea tu VM** (5 minutos)

4. **Sigue los comandos** del documento que elegiste

5. **En 40 minutos tendrás tu app corriendo** 🚀

---

## 💬 Preguntas Frecuentes

**P: ¿Necesito cambiar algo más en el código?**
R: No, ya está todo listo. Solo despliega.

**P: ¿Cuánto cuesta la VM?**
R: e2-standard-2: ~$49/mes. Detenla cuando no la uses para ahorrar.

**P: ¿Funciona con el apikey.json que tengo?**
R: Sí, ya está incluido en el backend.

**P: ¿Necesito dominio propio?**
R: No, usarás la IP pública de GCP.

**P: ¿Puedo usar VS Code?**
R: Sí, instala la extensión "Remote - SSH" y conéctate a la VM.

**P: ¿Qué hago si me quedo sin créditos de GCP?**
R: Detén la VM o cámbiala a e2-micro (gratuita).

---

## 📞 Ayuda Adicional

Si te atascas:
1. Lee la sección de troubleshooting en `GUIA_SUBIR_A_GCP.md`
2. Revisa los logs: `docker-compose -f docker-compose-gpt.yml logs`
3. Verifica el estado: `docker-compose -f docker-compose-gpt.yml ps`
4. Compara con `COMPARACION_ARCHIVOS.md` para ver diferencias

---

## ✨ Resumen Final

**Tu proyecto ESTÁ LISTO para GCP.**

Solo necesitas:
1. ✅ Crear VM (manual en GCP Console)
2. ✅ Instalar Docker (3 comandos)
3. ✅ Subir código (1 comando)
4. ✅ Desplegar (2 comandos)

**Total: 6 comandos + crear VM manualmente = 40 minutos**

---

**¡EMPIEZA CON `COMANDOS_RAPIDOS.md` AHORA! 🚀**

