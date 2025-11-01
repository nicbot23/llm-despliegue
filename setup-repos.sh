#!/bin/bash

# Script para clonar los repositorios del backend y frontend
# Ejecutar este script después de clonar llm-despliegue
# Usa HTTPS para evitar problemas con SSH keys en la VM

set -e

echo "🚀 Clonando repositorios de Backend y Frontend..."

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Backend
if [ -d "202515-MISW4411-Backend-Grupo20" ]; then
    echo -e "${YELLOW}⚠${NC}  Backend ya existe, omitiendo..."
    echo -e "   Si quieres actualizar: cd 202515-MISW4411-Backend-Grupo20 && git pull"
else
    echo -e "${BLUE}→${NC} Clonando Backend..."
    git clone https://github.com/MISW4411-Aplicaciones-basadas-en-LLMs/202515-MISW4411-Backend-Grupo20.git
    echo -e "${GREEN}✓${NC} Backend clonado"
fi

# Frontend
if [ -d "MISW4411-Frontend-Template" ]; then
    echo -e "${YELLOW}⚠${NC}  Frontend ya existe, omitiendo..."
    echo -e "   Si quieres actualizar: cd MISW4411-Frontend-Template && git pull"
else
    echo -e "${BLUE}→${NC} Clonando Frontend..."
    git clone https://github.com/MISW4411-Aplicaciones-basadas-en-LLMs/MISW4411-Frontend-Template.git
    echo -e "${GREEN}✓${NC} Frontend clonado"
fi

echo ""
echo -e "${GREEN}✅ Repositorios listos!${NC}"
echo ""
echo "Siguiente paso:"
echo "  docker-compose -f docker-compose-gpt.yml build"
echo "  docker-compose -f docker-compose-gpt.yml up -d"

