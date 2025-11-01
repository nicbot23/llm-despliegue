#!/bin/bash

################################################################################
# Script de Despliegue Automatizado para GCP
# Proyecto: MISW4411 - RAG Application
# Fecha: Noviembre 2025
################################################################################

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones auxiliares
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Verificar que estamos en el directorio correcto
check_directory() {
    print_header "1. Verificando Directorio"
    
    if [ ! -f "docker-compose-gpt.yml" ]; then
        print_error "No se encuentra docker-compose-gpt.yml"
        print_info "Asegúrate de estar en el directorio raíz del proyecto"
        exit 1
    fi
    
    if [ ! -d "202515-MISW4411-Backend-Grupo20" ]; then
        print_error "No se encuentra el directorio del backend"
        exit 1
    fi
    
    if [ ! -d "MISW4411-Frontend-Template" ]; then
        print_error "No se encuentra el directorio del frontend"
        exit 1
    fi
    
    if [ ! -f "nginx/default-gpt.conf" ]; then
        print_error "No se encuentra nginx/default-gpt.conf"
        exit 1
    fi
    
    print_success "Todos los archivos necesarios están presentes"
}

# Verificar Docker
check_docker() {
    print_header "2. Verificando Docker"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        print_info "Instala Docker con: sudo apt install -y docker.io"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose no está instalado"
        print_info "Instala Docker Compose con: sudo apt install -y docker-compose"
        exit 1
    fi
    
    print_success "Docker: $(docker --version)"
    print_success "Docker Compose: $(docker-compose --version)"
}

# Verificar archivos de configuración
check_config() {
    print_header "3. Verificando Configuración"
    
    # Verificar apikey.json (opcional)
    if [ ! -f "202515-MISW4411-Backend-Grupo20/apikey.json" ]; then
        print_warning "No se encuentra apikey.json en el backend"
        print_info "Si usas Google Cloud API, copia el archivo apikey.json al directorio del backend"
    else
        print_success "apikey.json encontrado"
    fi
    
    # Verificar appConfig.ts
    if grep -q 'BACKEND_URL: "/api"' "MISW4411-Frontend-Template/src/config/appConfig.ts"; then
        print_success "appConfig.ts configurado correctamente para despliegue"
    else
        print_warning "appConfig.ts podría no estar configurado correctamente"
        print_info "Verifica que BACKEND_URL sea '/api' en lugar de 'http://127.0.0.1:8000'"
    fi
}

# Detener servicios existentes
stop_existing() {
    print_header "4. Deteniendo Servicios Existentes"
    
    if docker-compose -f docker-compose-gpt.yml ps | grep -q "Up"; then
        print_info "Deteniendo servicios en ejecución..."
        docker-compose -f docker-compose-gpt.yml down
        print_success "Servicios detenidos"
    else
        print_info "No hay servicios en ejecución"
    fi
}

# Construir imágenes
build_images() {
    print_header "5. Construyendo Imágenes Docker"
    
    print_info "Esto puede tomar varios minutos..."
    
    if docker-compose -f docker-compose-gpt.yml build; then
        print_success "Imágenes construidas exitosamente"
    else
        print_error "Error al construir las imágenes"
        exit 1
    fi
}

# Iniciar servicios
start_services() {
    print_header "6. Iniciando Servicios"
    
    if docker-compose -f docker-compose-gpt.yml up -d; then
        print_success "Servicios iniciados"
    else
        print_error "Error al iniciar los servicios"
        exit 1
    fi
    
    print_info "Esperando que los servicios estén listos..."
    sleep 5
}

# Verificar estado
check_status() {
    print_header "7. Verificando Estado de los Servicios"
    
    echo -e "\n${BLUE}Contenedores en ejecución:${NC}"
    docker-compose -f docker-compose-gpt.yml ps
    
    # Verificar que los 3 servicios estén corriendo
    RUNNING=$(docker-compose -f docker-compose-gpt.yml ps | grep "Up" | wc -l)
    
    if [ "$RUNNING" -ge 3 ]; then
        print_success "Todos los servicios están corriendo ($RUNNING/3)"
    else
        print_error "Solo $RUNNING de 3 servicios están corriendo"
        print_info "Revisa los logs con: docker-compose -f docker-compose-gpt.yml logs"
        exit 1
    fi
}

# Probar endpoints
test_endpoints() {
    print_header "8. Probando Endpoints"
    
    print_info "Probando frontend..."
    if curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200"; then
        print_success "Frontend: http://localhost/ ✅"
    else
        print_warning "Frontend no responde correctamente"
    fi
    
    print_info "Probando backend..."
    if curl -s http://localhost/api/health > /dev/null 2>&1; then
        print_success "Backend: http://localhost/api/health ✅"
    else
        print_warning "Backend no responde. Puede estar iniciando todavía."
        print_info "Espera unos segundos y prueba manualmente: curl http://localhost/api/health"
    fi
}

# Mostrar información final
show_info() {
    print_header "🎉 Despliegue Completado"
    
    # Obtener IP externa (si es una VM de GCP)
    EXTERNAL_IP=""
    if command -v curl &> /dev/null; then
        EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "No disponible")
    fi
    
    echo -e "${GREEN}✅ La aplicación está corriendo exitosamente${NC}\n"
    
    echo -e "${BLUE}📍 Acceso Local (desde la VM):${NC}"
    echo -e "   Frontend: ${GREEN}http://localhost/${NC}"
    echo -e "   Backend:  ${GREEN}http://localhost/api/health${NC}\n"
    
    if [ "$EXTERNAL_IP" != "No disponible" ]; then
        echo -e "${BLUE}🌐 Acceso Externo (desde tu navegador):${NC}"
        echo -e "   Frontend: ${GREEN}http://$EXTERNAL_IP/${NC}"
        echo -e "   Backend:  ${GREEN}http://$EXTERNAL_IP/api/health${NC}\n"
    else
        echo -e "${BLUE}🌐 Acceso Externo:${NC}"
        echo -e "   Reemplaza <VM_IP> con la IP externa de tu VM:"
        echo -e "   Frontend: ${GREEN}http://<VM_IP>/${NC}"
        echo -e "   Backend:  ${GREEN}http://<VM_IP>/api/health${NC}\n"
    fi
    
    echo -e "${BLUE}📊 Comandos Útiles:${NC}"
    echo -e "   Ver logs:      ${YELLOW}docker-compose -f docker-compose-gpt.yml logs -f${NC}"
    echo -e "   Ver estado:    ${YELLOW}docker-compose -f docker-compose-gpt.yml ps${NC}"
    echo -e "   Detener:       ${YELLOW}docker-compose -f docker-compose-gpt.yml down${NC}"
    echo -e "   Reiniciar:     ${YELLOW}docker-compose -f docker-compose-gpt.yml restart${NC}\n"
    
    echo -e "${BLUE}📚 Documentación:${NC}"
    echo -e "   Lee ${YELLOW}DESPLIEGUE_GCP.md${NC} para más información\n"
}

# Manejo de errores
trap 'print_error "El script falló en la línea $LINENO"' ERR

# Menú principal
main() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════╗
    ║                                               ║
    ║     Despliegue Automático - MISW4411         ║
    ║     RAG Application en GCP                   ║
    ║                                               ║
    ╚═══════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
    
    # Ejecutar pasos
    check_directory
    check_docker
    check_config
    stop_existing
    build_images
    start_services
    check_status
    test_endpoints
    show_info
}

# Verificar si se quiere ver logs
if [ "$1" = "--logs" ] || [ "$1" = "-l" ]; then
    docker-compose -f docker-compose-gpt.yml logs -f
    exit 0
fi

# Verificar si se quiere detener
if [ "$1" = "--stop" ] || [ "$1" = "-s" ]; then
    print_info "Deteniendo servicios..."
    docker-compose -f docker-compose-gpt.yml down
    print_success "Servicios detenidos"
    exit 0
fi

# Verificar si se quiere solo el estado
if [ "$1" = "--status" ]; then
    docker-compose -f docker-compose-gpt.yml ps
    exit 0
fi

# Ayuda
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Uso: $0 [OPCIÓN]"
    echo ""
    echo "Opciones:"
    echo "  (ninguna)     Ejecutar despliegue completo"
    echo "  -l, --logs    Ver logs en tiempo real"
    echo "  -s, --stop    Detener todos los servicios"
    echo "  --status      Ver estado de los servicios"
    echo "  -h, --help    Mostrar esta ayuda"
    echo ""
    exit 0
fi

# Ejecutar script principal
main

