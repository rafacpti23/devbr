#!/bin/bash

# DevBr - Deploy Docker Swarm
# Desenvolvido por: Ramel Tecnologia - Rafa Martins
# Site: ramelseg.com.br

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[DevBr Swarm]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
    exit 1
}

show_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
    ____             ____        ____                           
   |  _ \  _____   _|  _ \ _ __ / ___|_      ____ _ _ __ _ __ ___  
   | | | |/ _ \ \ / / |_) | '__\___ \ \ /\ / / _` | '__| '_ ` _ \ 
   | |_| |  __/\ V /|  _ <| |   ___) \ V  V / (_| | |  | | | | | |
   |____/ \___| \_/ |_| \_\_|  |____/ \_/\_/ \__,_|_|  |_| |_| |_|
                                                                  
   Docker Swarm Deployment 🐳
   
   Desenvolvido por: Ramel Tecnologia
   Autor: Rafa Martins
   Site: ramelseg.com.br
   
EOF
    echo -e "${NC}"
}

# Verificar se Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker não está instalado. Por favor, instale o Docker primeiro."
    fi
    
    if ! docker info &> /dev/null; then
        error "Docker não está rodando ou você não tem permissões adequadas."
    fi
    
    log "Docker verificado com sucesso!"
}

# Coletar informações
collect_swarm_info() {
    log "Coletando informações para Docker Swarm..."
    
    echo -n "Digite o domínio principal (ex: devbr.meusite.com.br): "
    read -r DOMAIN
    
    if [[ -z "$DOMAIN" ]]; then
        error "Domínio é obrigatório!"
    fi
    
    echo -n "Digite seu email para certificados SSL: "
    read -r EMAIL
    
    if [[ -z "$EMAIL" ]]; then
        error "Email é obrigatório!"
    fi
    
    echo -n "Digite a senha para Redis [devbr123]: "
    read -r REDIS_PASSWORD
    REDIS_PASSWORD=${REDIS_PASSWORD:-devbr123}
    
    echo -n "Digite a senha para PostgreSQL [devbr123]: "
    read -r POSTGRES_PASSWORD
    POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-devbr123}
    
    echo -n "Número de réplicas do DevBr [2]: "
    read -r REPLICAS
    REPLICAS=${REPLICAS:-2}
    
    log "Configurações coletadas:"
    log "Domínio: $DOMAIN"
    log "Email: $EMAIL"
    log "Réplicas: $REPLICAS"
}

# Inicializar Docker Swarm
init_swarm() {
    log "Verificando Docker Swarm..."
    
    if ! docker info | grep -q "Swarm: active"; then
        log "Inicializando Docker Swarm..."
        docker swarm init
    else
        log "Docker Swarm já está ativo!"
    fi
}

# Criar redes
create_networks() {
    log "Criando redes Docker..."
    
    # Rede para aplicação
    if ! docker network ls | grep -q devbr-network; then
        docker network create --driver overlay --attachable devbr-network
        log "Rede devbr-network criada!"
    fi
    
    # Rede para Traefik
    if ! docker network ls | grep -q traefik-public; then
        docker network create --driver overlay traefik-public
        log "Rede traefik-public criada!"
    fi
}

# Criar diretórios necessários
create_directories() {
    log "Criando estrutura de diretórios..."
    
    mkdir -p {data,logs,nginx/{conf.d,ssl,logs},traefik/letsencrypt,postgres/init}
    
    # Definir permissões
    chmod 600 traefik/letsencrypt 2>/dev/null || true
    
    log "Diretórios criados!"
}

# Criar arquivo de configuração do ambiente
create_env_file() {
    log "Criando arquivo de ambiente..."
    
    cat > .env << EOF
# DevBr - Configurações Docker Swarm
DOMAIN=$DOMAIN
EMAIL=$EMAIL
REDIS_PASSWORD=$REDIS_PASSWORD
POSTGRES_DB=devbr
POSTGRES_USER=devbr
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
REPLICAS=$REPLICAS

# Configurações da aplicação
NODE_ENV=production
PORT=3000
VITE_APP_DOMAIN=$DOMAIN
EOF
    
    log "Arquivo .env criado!"
}

# Criar configuração do Nginx
create_nginx_config() {
    log "Criando configuração do Nginx..."
    
    cat > nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    include /etc/nginx/conf.d/*.conf;
}
EOF
    
    cat > nginx/conf.d/devbr.conf << EOF
upstream devbr_backend {
    server devbr:3000;
}

server {
    listen 80;
    server_name $DOMAIN;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    location / {
        proxy_pass http://devbr_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF
    
    log "Configuração do Nginx criada!"
}

# Criar Docker Compose para Swarm
create_swarm_compose() {
    log "Criando Docker Compose para Swarm..."
    
    cat > docker-compose.swarm.yml << 'EOF'
version: '3.8'

services:
  devbr:
    image: rameltecnologia/devbr:latest
    networks:
      - devbr-network
    environment:
      - NODE_ENV=production
      - PORT=3000
      - VITE_APP_DOMAIN=${DOMAIN}
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
    volumes:
      - devbr-data:/app/data
      - devbr-logs:/app/logs
    deploy:
      replicas: ${REPLICAS:-2}
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      rollback_config:
        parallelism: 1
        delay: 5s
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    networks:
      - devbr-network
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - nginx-logs:/var/log/nginx
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == manager
    depends_on:
      - devbr

  redis:
    image: redis:7-alpine
    networks:
      - devbr-network
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis-data:/data
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == manager
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:15-alpine
    networks:
      - devbr-network
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./postgres/init:/docker-entrypoint-initdb.d
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == manager
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  devbr-data:
    driver: local
  devbr-logs:
    driver: local
  nginx-logs:
    driver: local
  redis-data:
    driver: local
  postgres-data:
    driver: local

networks:
  devbr-network:
    driver: overlay
    attachable: true
EOF
    
    log "Docker Compose para Swarm criado!"
}

# Build da imagem Docker
build_image() {
    log "Construindo imagem Docker..."
    
    if [[ ! -f "Dockerfile" ]]; then
        create_dockerfile
    fi
    
    docker build -t rameltecnologia/devbr:latest .
    
    log "Imagem Docker construída!"
}

# Criar Dockerfile
create_dockerfile() {
    log "Criando Dockerfile..."
    
    cat > Dockerfile << 'EOF'
FROM node:20-alpine

# Instalar dependências do sistema
RUN apk add --no-cache curl

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs
RUN adduser -S devbr -u 1001

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm ci --only=production && npm cache clean --force

# Copiar código da aplicação
COPY . .

# Alterar proprietário dos arquivos
RUN chown -R devbr:nodejs /app
USER devbr

# Expor porta
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Comando de inicialização
CMD ["npm", "start"]
EOF
    
    log "Dockerfile criado!"
}

# Deploy no Swarm
deploy_swarm() {
    log "Fazendo deploy no Docker Swarm..."
    
    # Deploy da stack
    docker stack deploy -c docker-compose.swarm.yml devbr
    
    log "Deploy realizado! Aguardando serviços..."
    
    # Aguardar serviços ficarem prontos
    sleep 30
    
    # Verificar status dos serviços
    docker stack services devbr
}

# Configurar SSL
setup_swarm_ssl() {
    log "Configurando SSL para Swarm..."
    
    warn "Para configurar SSL, você precisa:"
    warn "1. Apontar o domínio $DOMAIN para este servidor"
    warn "2. Executar o comando de certificado SSL manualmente"
    
    echo -e "${YELLOW}Comando para obter certificado SSL:${NC}"
    echo "docker run --rm -v \$(pwd)/nginx/ssl:/etc/letsencrypt/live/$DOMAIN certbot/certbot certonly --standalone -d $DOMAIN --email $EMAIL --agree-tos --non-interactive"
}

# Verificar deployment
verify_swarm_deployment() {
    log "Verificando deployment..."
    
    echo -e "${BLUE}Status dos serviços:${NC}"
    docker stack services devbr
    
    echo -e "${BLUE}Status dos containers:${NC}"
    docker stack ps devbr
    
    log "Verificação concluída!"
}

# Mostrar informações finais
show_swarm_final_info() {
    echo -e "${GREEN}"
    cat << EOF

🎉 DevBr Docker Swarm deployado com sucesso!

📋 Informações do deployment:
   • Stack: devbr
   • Domínio: $DOMAIN
   • Réplicas: $REPLICAS
   • Redes: devbr-network

🔗 Acesso:
   • HTTP: http://$DOMAIN
   • HTTPS: https://$DOMAIN (após configurar SSL)

🛠️  Comandos úteis:
   • Ver serviços: docker stack services devbr
   • Ver containers: docker stack ps devbr
   • Logs: docker service logs devbr_devbr
   • Escalar: docker service scale devbr_devbr=$REPLICAS
   • Atualizar: docker service update devbr_devbr
   • Remover: docker stack rm devbr

📊 Monitoramento:
   • Traefik Dashboard: http://$DOMAIN:8080
   • Logs Nginx: docker service logs devbr_nginx

🏢 Desenvolvido por:
   Ramel Tecnologia - Rafa Martins
   Site: ramelseg.com.br

EOF
    echo -e "${NC}"
}

# Função principal
main() {
    show_banner
    check_docker
    collect_swarm_info
    init_swarm
    create_networks
    create_directories
    create_env_file
    create_nginx_config
    create_swarm_compose
    build_image
    deploy_swarm
    setup_swarm_ssl
    verify_swarm_deployment
    show_swarm_final_info
}

# Executar deployment
main "$@"