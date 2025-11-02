# 🚀 Guia de Instalação - DevBr

**Desenvolvido por:** Ramel Tecnologia - Rafa Martins  
**Site:** [ramelseg.com.br](https://ramelseg.com.br)

---

## 📋 Pré-requisitos

Antes de instalar o DevBr, certifique-se de ter:

- **Node.js 18+** - [Download](https://nodejs.org/)
- **Git** - [Download](https://git-scm.com/)
- **Docker** (opcional) - [Download](https://docker.com/)

---

## 🖥️ Instalação no Windows

### Opção 1: PowerShell (Recomendada)

```powershell
# Clonar o repositório
git clone https://github.com/rameltecnologia/devbr.git
cd devbr

# Executar setup automático
.\setup-devbr.ps1
```

### Opção 2: Manual

```powershell
# Instalar dependências
npm install

# Configurar ambiente
copy .env.example .env.local

# Iniciar aplicação
npm run dev
```

---

## 🐧 Instalação no Linux

### Opção 1: Instalação Automática (Recomendada)

```bash
# Download e execução do instalador
curl -fsSL https://raw.githubusercontent.com/rameltecnologia/devbr/main/install.sh | bash
```

### Opção 2: Manual

```bash
# Clonar repositório
git clone https://github.com/rameltecnologia/devbr.git
cd devbr

# Tornar scripts executáveis
chmod +x install.sh docker-swarm-deploy.sh scripts/setup-github.sh

# Executar instalação
./install.sh
```

---

## 🐳 Instalação com Docker

### Docker Compose (Desenvolvimento)

```bash
# Clonar repositório
git clone https://github.com/rameltecnologia/devbr.git
cd devbr

# Configurar ambiente
cp .env.example .env

# Iniciar com Docker
docker-compose up -d
```

### Docker Swarm (Produção)

```bash
# Download e execução do deploy
curl -fsSL https://raw.githubusercontent.com/rameltecnologia/devbr/main/docker-swarm-deploy.sh | bash
```

---

## ⚙️ Configuração

### 1. Variáveis de Ambiente

Edite o arquivo `.env.local`:

```env
# Configurações básicas
NODE_ENV=production
PORT=3000
VITE_APP_DOMAIN=seu-dominio.com.br

# Convex (obrigatório)
VITE_CONVEX_URL=https://seu-projeto.convex.cloud
CONVEX_DEPLOYMENT=seu-deployment
CONVEX_OAUTH_CLIENT_ID=seu-client-id

# WorkOS (autenticação)
VITE_WORKOS_CLIENT_ID=seu-workos-client-id
WORKOS_REDIRECT_URI=https://seu-dominio.com.br/auth/callback
```

### 2. Configuração do Convex

1. Acesse [Convex Dashboard](https://dashboard.convex.dev/)
2. Crie um novo projeto
3. Configure as variáveis de ambiente
4. Deploy das funções: `npx convex deploy`

### 3. Configuração do WorkOS

1. Acesse [WorkOS Dashboard](https://dashboard.workos.com/)
2. Crie uma nova aplicação
3. Configure OAuth e redirecionamentos
4. Obtenha as chaves de API

---

## 🌐 Configuração de Produção

### Nginx (Proxy Reverso)

```nginx
server {
    listen 80;
    server_name seu-dominio.com.br;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### SSL/HTTPS

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d seu-dominio.com.br
```

### Serviço Systemd

```ini
[Unit]
Description=DevBr - Desenvolvimento Brasil
After=network.target

[Service]
Type=simple
User=devbr
WorkingDirectory=/home/devbr/devbr
Environment=NODE_ENV=production
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

---

## 🔧 Comandos Úteis

### Desenvolvimento

```bash
# Instalar dependências
npm install

# Iniciar em desenvolvimento
npm run dev

# Executar testes
npm test

# Verificar tipos
npm run typecheck

# Lint e formatação
npm run lint
npm run lint:fix
```

### Produção

```bash
# Build para produção
npm run build

# Iniciar em produção
npm start

# Verificar status (Linux)
sudo systemctl status devbr

# Ver logs (Linux)
sudo journalctl -u devbr -f
```

### Docker

```bash
# Build da imagem
docker build -t rameltecnologia/devbr:latest .

# Executar container
docker run -d --name devbr -p 3000:3000 rameltecnologia/devbr:latest

# Ver logs
docker logs devbr -f

# Parar container
docker stop devbr

# Remover container
docker rm devbr
```

### Docker Swarm

```bash
# Ver serviços
docker stack services devbr

# Ver containers
docker stack ps devbr

# Escalar serviço
docker service scale devbr_devbr=3

# Ver logs
docker service logs devbr_devbr -f

# Atualizar serviço
docker service update devbr_devbr

# Remover stack
docker stack rm devbr
```

---

## 🔍 Verificação da Instalação

### 1. Verificar Aplicação

```bash
# Testar endpoint de saúde
curl http://localhost:3000/api/health

# Verificar resposta
curl -I http://localhost:3000
```

### 2. Verificar Serviços (Linux)

```bash
# Status do DevBr
sudo systemctl status devbr

# Status do Nginx
sudo systemctl status nginx

# Verificar portas
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :80
```

### 3. Verificar Docker

```bash
# Containers rodando
docker ps

# Logs da aplicação
docker logs devbr-app

# Saúde do container
docker inspect devbr-app | grep Health
```

---

## 🆘 Solução de Problemas

### Problemas Comuns

**1. Porta já em uso**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux
sudo lsof -i :3000
sudo kill -9 <PID>
```

**2. Permissões de arquivo (Linux)**
```bash
sudo chown -R $USER:$USER ~/devbr
chmod +x ~/devbr/install.sh
```

**3. Problemas de SSL**
```bash
# Verificar certificados
sudo certbot certificates

# Renovar certificados
sudo certbot renew --dry-run
```

**4. Container não inicia**
```bash
# Verificar logs
docker logs devbr-app

# Verificar recursos
docker stats devbr-app

# Reiniciar container
docker restart devbr-app
```

### Logs de Debug

```bash
# Ativar logs detalhados
export LOG_LEVEL=debug

# Ou no .env.local
echo "LOG_LEVEL=debug" >> .env.local
```

---

## 📞 Suporte

Para suporte técnico:

- **Email:** rafa@ramelseg.com.br
- **Site:** [ramelseg.com.br](https://ramelseg.com.br)
- **Issues:** [GitHub Issues](https://github.com/rameltecnologia/devbr/issues)

---

## 📄 Próximos Passos

Após a instalação:

1. ✅ **Configure suas chaves de API**
2. ✅ **Teste a aplicação localmente**
3. ✅ **Configure domínio e SSL**
4. ✅ **Configure backup automático**
5. ✅ **Configure monitoramento**

---

<div align="center">
  <p><strong>DevBr - Desenvolvendo o futuro do Brasil! 🚀🇧🇷</strong></p>
  
  <p>
    <strong>Ramel Tecnologia - Rafa Martins</strong><br>
    <a href="https://ramelseg.com.br">ramelseg.com.br</a>
  </p>
</div>