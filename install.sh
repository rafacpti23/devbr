#!/bin/bash

# DevBr - Instalador Automático
# Desenvolvido por: Ramel Tecnologia - Rafa Martins
# Site: ramelseg.com.br
# Versão adaptada do Chef para o mercado brasileiro

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log() {
    echo -e "${GREEN}[DevBr]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
    exit 1
}

# Banner
show_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
    ____             ____       
   |  _ \  _____   _|  _ \ _ __ 
   | | | |/ _ \ \ / / |_) | '__|
   | |_| |  __/\ V /|  _ <| |   
   |____/ \___| \_/ |_| \_\_|   
                                
   Desenvolvimento Brasil 🇧🇷
   
   Desenvolvido por: Ramel Tecnologia
   Autor: Rafa Martins
   Site: ramelseg.com.br
   
EOF
    echo -e "${NC}"
}

# Verificar se está rodando como root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Este script não deve ser executado como root. Execute como usuário normal."
    fi
}

# Verificar dependências do sistema
check_dependencies() {
    log "Verificando dependências do sistema..."
    
    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        warn "Node.js não encontrado. Instalando..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Verificar npm
    if ! command -v npm &> /dev/null; then
        error "npm não encontrado. Por favor, instale o Node.js primeiro."
    fi
    
    # Verificar Git
    if ! command -v git &> /dev/null; then
        warn "Git não encontrado. Instalando..."
        sudo apt-get update
        sudo apt-get install -y git
    fi
    
    # Verificar Docker (opcional)
    if ! command -v docker &> /dev/null; then
        warn "Docker não encontrado. Será necessário para instalação com Docker."
    fi
    
    log "Dependências verificadas com sucesso!"
}

# Coletar informações do usuário
collect_info() {
    log "Coletando informações de configuração..."
    
    echo -n "Digite o domínio para o DevBr (ex: devbr.meusite.com.br): "
    read -r DOMAIN
    
    if [[ -z "$DOMAIN" ]]; then
        error "Domínio é obrigatório!"
    fi
    
    echo -n "Digite a porta para o DevBr [3000]: "
    read -r PORT
    PORT=${PORT:-3000}
    
    echo -n "Deseja configurar SSL/HTTPS? (s/n) [s]: "
    read -r SSL_ENABLED
    SSL_ENABLED=${SSL_ENABLED:-s}
    
    echo -n "Digite seu email para certificados SSL: "
    read -r EMAIL
    
    if [[ "$SSL_ENABLED" == "s" && -z "$EMAIL" ]]; then
        error "Email é obrigatório para certificados SSL!"
    fi
    
    log "Configurações coletadas:"
    log "Domínio: $DOMAIN"
    log "Porta: $PORT"
    log "SSL: $SSL_ENABLED"
    log "Email: $EMAIL"
}

# Instalar DevBr
install_devbr() {
    log "Instalando DevBr..."
    
    # Criar diretório de instalação
    INSTALL_DIR="$HOME/devbr"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        warn "Diretório $INSTALL_DIR já existe. Removendo..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Clonar repositório
    log "Clonando repositório..."
    git clone https://github.com/rameltecnologia/devbr.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Instalar dependências
    log "Instalando dependências..."
    npm install
    
    # Configurar variáveis de ambiente
    log "Configurando variáveis de ambiente..."
    cp .env.example .env.local
    
    # Atualizar .env.local com as configurações
    sed -i "s/VITE_APP_DOMAIN=.*/VITE_APP_DOMAIN=$DOMAIN/" .env.local
    sed -i "s/PORT=.*/PORT=$PORT/" .env.local
    
    log "DevBr instalado com sucesso!"
}

# Configurar Nginx como proxy reverso
setup_nginx() {
    log "Configurando Nginx como proxy reverso..."
    
    # Instalar Nginx se não estiver instalado
    if ! command -v nginx &> /dev/null; then
        log "Instalando Nginx..."
        sudo apt-get update
        sudo apt-get install -y nginx
    fi
    
    # Criar configuração do Nginx
    sudo tee /etc/nginx/sites-available/devbr << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
    
    # Ativar site
    sudo ln -sf /etc/nginx/sites-available/devbr /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl reload nginx
    
    log "Nginx configurado com sucesso!"
}

# Configurar SSL com Certbot
setup_ssl() {
    if [[ "$SSL_ENABLED" == "s" ]]; then
        log "Configurando SSL com Let's Encrypt..."
        
        # Instalar Certbot
        if ! command -v certbot &> /dev/null; then
            log "Instalando Certbot..."
            sudo apt-get update
            sudo apt-get install -y certbot python3-certbot-nginx
        fi
        
        # Obter certificado SSL
        sudo certbot --nginx -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive
        
        log "SSL configurado com sucesso!"
    fi
}

# Criar serviço systemd
create_service() {
    log "Criando serviço systemd..."
    
    sudo tee /etc/systemd/system/devbr.service << EOF
[Unit]
Description=DevBr - Desenvolvimento Brasil
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$INSTALL_DIR
Environment=NODE_ENV=production
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # Recarregar systemd e iniciar serviço
    sudo systemctl daemon-reload
    sudo systemctl enable devbr
    sudo systemctl start devbr
    
    log "Serviço DevBr criado e iniciado!"
}

# Verificar instalação
verify_installation() {
    log "Verificando instalação..."
    
    # Verificar se o serviço está rodando
    if sudo systemctl is-active --quiet devbr; then
        log "✅ Serviço DevBr está rodando"
    else
        error "❌ Serviço DevBr não está rodando"
    fi
    
    # Verificar se o Nginx está rodando
    if sudo systemctl is-active --quiet nginx; then
        log "✅ Nginx está rodando"
    else
        error "❌ Nginx não está rodando"
    fi
    
    # Testar conectividade
    log "Testando conectividade..."
    sleep 5
    
    if curl -s "http://localhost:$PORT" > /dev/null; then
        log "✅ DevBr está respondendo na porta $PORT"
    else
        warn "⚠️  DevBr pode não estar respondendo ainda (aguarde alguns segundos)"
    fi
}

# Mostrar informações finais
show_final_info() {
    echo -e "${GREEN}"
    cat << EOF

🎉 DevBr instalado com sucesso!

📋 Informações da instalação:
   • Domínio: $DOMAIN
   • Porta local: $PORT
   • SSL: $SSL_ENABLED
   • Diretório: $INSTALL_DIR

🔗 Acesso:
   • Local: http://localhost:$PORT
   • Público: http://$DOMAIN
EOF
    
    if [[ "$SSL_ENABLED" == "s" ]]; then
        echo "   • HTTPS: https://$DOMAIN"
    fi
    
    cat << EOF

🛠️  Comandos úteis:
   • Verificar status: sudo systemctl status devbr
   • Parar serviço: sudo systemctl stop devbr
   • Iniciar serviço: sudo systemctl start devbr
   • Reiniciar serviço: sudo systemctl restart devbr
   • Ver logs: sudo journalctl -u devbr -f

📁 Arquivos de configuração:
   • DevBr: $INSTALL_DIR/.env.local
   • Nginx: /etc/nginx/sites-available/devbr
   • Serviço: /etc/systemd/system/devbr.service

🏢 Desenvolvido por:
   Ramel Tecnologia - Rafa Martins
   Site: ramelseg.com.br

EOF
    echo -e "${NC}"
}

# Função principal
main() {
    show_banner
    check_root
    check_dependencies
    collect_info
    install_devbr
    setup_nginx
    setup_ssl
    create_service
    verify_installation
    show_final_info
}

# Executar instalação
main "$@"