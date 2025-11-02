# DevBr - Desenvolvimento Brasil 🇧🇷

<div align="center">
  <img src="public/devbr-logo.svg" alt="DevBr Logo" width="200"/>
  
  **Agente de IA para Desenvolvimento Full-Stack Brasileiro**
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Node.js](https://img.shields.io/badge/Node.js-20+-green.svg)](https://nodejs.org/)
  [![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com/)
  [![Português](https://img.shields.io/badge/Idioma-Português-green.svg)](README.md)
</div>

---

## 🏢 Desenvolvido por

**Ramel Tecnologia**  
**Autor:** Rafa Martins  
**Site:** [ramelseg.com.br](https://ramelseg.com.br)  
**Email:** rafa@ramelseg.com.br

*Versão adaptada do Chef especialmente para desenvolvedores brasileiros*

---

## 📋 Sobre o DevBr

O DevBr é uma versão personalizada e traduzida para português brasileiro do Chef, um poderoso agente de IA para desenvolvimento full-stack. Esta adaptação foi criada especialmente para atender às necessidades da comunidade de desenvolvedores brasileiros, oferecendo:

- ✅ **Interface 100% em português brasileiro**
- ✅ **Design amigável com cores suaves**
- ✅ **Templates e receitas adaptadas para o mercado brasileiro**
- ✅ **Documentação completa em português**
- ✅ **Suporte técnico em português**

## 🚀 Instalação Rápida

### Opção 1: Instalação Automática (Recomendada)

```bash
# Baixar e executar o instalador automático
curl -fsSL https://raw.githubusercontent.com/rameltecnologia/devbr/main/install.sh | bash
```

O instalador automático irá:
- ✅ Verificar dependências
- ✅ Instalar o DevBr
- ✅ Configurar proxy reverso (Nginx)
- ✅ Configurar SSL/HTTPS
- ✅ Criar serviço systemd
- ✅ Iniciar automaticamente

### Opção 2: Instalação Manual

```bash
# Clonar o repositório
git clone https://github.com/rameltecnologia/devbr.git
cd devbr

# Instalar dependências
npm install

# Configurar ambiente
cp .env.example .env.local

# Iniciar em desenvolvimento
npm run dev

# Ou iniciar em produção
npm run build
npm start
```

### Opção 3: Docker Compose

```bash
# Clonar o repositório
git clone https://github.com/rameltecnologia/devbr.git
cd devbr

# Configurar variáveis de ambiente
cp .env.example .env

# Iniciar com Docker Compose
docker-compose up -d
```

### Opção 4: Docker Swarm (Produção)

```bash
# Baixar e executar o deploy para Swarm
curl -fsSL https://raw.githubusercontent.com/rameltecnologia/devbr/main/docker-swarm-deploy.sh | bash
```

---

## 🛠️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env.local` com as seguintes configurações:

```env
# Configurações básicas
NODE_ENV=production
PORT=3000
VITE_APP_DOMAIN=seu-dominio.com.br

# Configurações do Convex (obrigatório)
VITE_CONVEX_URL=https://seu-projeto.convex.cloud
CONVEX_DEPLOYMENT=seu-deployment
CONVEX_OAUTH_CLIENT_ID=seu-client-id

# Configurações do WorkOS (autenticação)
VITE_WORKOS_CLIENT_ID=seu-workos-client-id
WORKOS_REDIRECT_URI=https://seu-dominio.com.br/auth/callback

# Configurações opcionais
REDIS_URL=redis://localhost:6379
DATABASE_URL=postgresql://user:pass@localhost:5432/devbr
```

### Configuração do Proxy Reverso

O instalador automático configura o Nginx automaticamente. Para configuração manual:

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

---

## 🐳 Docker

### Construir Imagem

```bash
docker build -t rameltecnologia/devbr:latest .
```

### Executar Container

```bash
docker run -d \
  --name devbr \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e VITE_APP_DOMAIN=seu-dominio.com.br \
  rameltecnologia/devbr:latest
```

### Docker Compose Completo

```yaml
version: '3.8'

services:
  devbr:
    image: rameltecnologia/devbr:latest
    container_name: devbr-app
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - VITE_APP_DOMAIN=seu-dominio.com.br
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    container_name: devbr-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - devbr
```

---

## 🔧 Comandos Úteis

### Desenvolvimento

```bash
# Instalar dependências
npm install

# Iniciar em modo desenvolvimento
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

# Verificar status do serviço
sudo systemctl status devbr

# Ver logs
sudo journalctl -u devbr -f

# Reiniciar serviço
sudo systemctl restart devbr
```

### Docker

```bash
# Ver logs do container
docker logs devbr-app -f

# Entrar no container
docker exec -it devbr-app sh

# Verificar saúde do container
docker inspect devbr-app | grep Health

# Atualizar imagem
docker pull rameltecnologia/devbr:latest
docker-compose up -d
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

## 🎨 Personalização

### Cores e Tema

O DevBr utiliza um esquema de cores amigável inspirado no design Lovable:

- **Verde primário:** `#22c55e` (confiança e crescimento)
- **Laranja accent:** `#f97316` (energia e criatividade)
- **Tons neutros:** Para melhor legibilidade

### Modificar Cores

Edite o arquivo `app/styles/variables.css`:

```css
:root {
  --devbr-primary-500: #22c55e;
  --devbr-accent-500: #f97316;
  --devbr-secondary-500: #64748b;
}
```

### Adicionar Receitas

Edite `app/components/chat/MessageInput.tsx` para adicionar novas receitas:

```tsx
<MenuItemComponent action={() => insertTemplate('Sua nova receita...')}>
  <div className="flex w-full items-center gap-2">
    <SeuIcon className="size-4 text-content-secondary" />
    Nome da Receita
  </div>
</MenuItemComponent>
```

---

## 🔒 Segurança

### SSL/HTTPS

O instalador automático configura SSL usando Let's Encrypt. Para configuração manual:

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d seu-dominio.com.br

# Renovação automática
sudo crontab -e
# Adicionar: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Firewall

```bash
# Configurar UFW
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Backup

```bash
# Backup dos dados
tar -czf devbr-backup-$(date +%Y%m%d).tar.gz \
  ~/devbr/data \
  ~/devbr/.env.local \
  /etc/nginx/sites-available/devbr

# Backup do banco (se usando PostgreSQL)
pg_dump devbr > devbr-db-backup-$(date +%Y%m%d).sql
```

---

## 📊 Monitoramento

### Health Check

O DevBr inclui um endpoint de saúde:

```bash
curl http://localhost:3000/api/health
```

### Logs

```bash
# Logs da aplicação
tail -f ~/devbr/logs/app.log

# Logs do sistema
sudo journalctl -u devbr -f

# Logs do Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Métricas

Para monitoramento avançado, considere usar:

- **Prometheus + Grafana**
- **ELK Stack (Elasticsearch, Logstash, Kibana)**
- **New Relic ou DataDog**

---

## 🆘 Solução de Problemas

### Problemas Comuns

**1. Porta já em uso**
```bash
# Verificar qual processo está usando a porta
sudo lsof -i :3000

# Parar o processo
sudo kill -9 PID
```

**2. Permissões de arquivo**
```bash
# Corrigir permissões
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

Para ativar logs detalhados:

```bash
# Definir nível de log
export LOG_LEVEL=debug

# Ou no .env.local
echo "LOG_LEVEL=debug" >> .env.local
```

---

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. **Fork** o repositório
2. **Crie** uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. **Commit** suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. **Push** para a branch (`git push origin feature/nova-feature`)
5. **Abra** um Pull Request

### Diretrizes

- Mantenha o código em português nos comentários
- Siga os padrões de código existentes
- Adicione testes para novas funcionalidades
- Atualize a documentação quando necessário

---

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 🙏 Agradecimentos

- **Convex Team** - Pela plataforma incrível
- **Chef Team** - Pelo projeto original
- **Comunidade brasileira de desenvolvedores** - Pelo feedback e suporte

---

## 📞 Suporte

Para suporte técnico:

- **Email:** rafa@ramelseg.com.br
- **Site:** [ramelseg.com.br](https://ramelseg.com.br)
- **Issues:** [GitHub Issues](https://github.com/rameltecnologia/devbr/issues)

---

<div align="center">
  <p><strong>DevBr - Desenvolvendo o futuro do Brasil, uma linha de código por vez! 🚀🇧🇷</strong></p>
  
  <p>
    <a href="https://ramelseg.com.br">
      <img src="https://img.shields.io/badge/Ramel-Tecnologia-blue?style=for-the-badge" alt="Ramel Tecnologia"/>
    </a>
  </p>
</div>