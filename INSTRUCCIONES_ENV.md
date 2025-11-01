# 🔑 Configurar Variables de Entorno

## En la VM de GCP:

Después de clonar los repositorios, debes crear el archivo `.env` con tu API key de Gemini:

```bash
cd ~/llm-despliegue/202515-MISW4411-Backend-Grupo20

# Crear el archivo .env
cat > .env << 'EOF'
GOOGLE_API_KEY=tu_api_key_de_gemini_aqui
EOF

# O usando nano:
nano .env
# Pega: GOOGLE_API_KEY=tu_api_key_aqui
# Guarda con Ctrl+O, Enter, Ctrl+X
```

## Obtener tu API Key de Gemini:

1. Ve a: https://makersuite.google.com/app/apikey
2. Crea una nueva API key
3. Cópiala
4. Pégala en el archivo `.env`

## Verificar:

```bash
cd ~/llm-despliegue/202515-MISW4411-Backend-Grupo20
cat .env
# Deberías ver: GOOGLE_API_KEY=AIza...
```

## Reiniciar el backend:

```bash
cd ~/llm-despliegue
docker-compose -f docker-compose-gpt.yml restart backend
docker-compose -f docker-compose-gpt.yml logs -f backend
```

El warning de `GOOGLE_API_KEY no encontrada` debería desaparecer. ✅

