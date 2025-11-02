#!/bin/bash

# DevBr - Setup GitHub Repository
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
    echo -e "${GREEN}[GitHub Setup]${NC} $1"
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
    ____             ____        _____ _ _   _   _       _     
   |  _ \  _____   _|  _ \ _ __ / ____(_) | | | | |_   _| |__  
   | | | |/ _ \ \ / / |_) | '__| |  __| | |_| | | | | | | '_ \ 
   | |_| |  __/\ V /|  _ <| |  | |_| | |  _  | |_| |_| | |_) |
   |____/ \___| \_/ |_| \_\_|   \____|_|_| |_|\___\__,_|_.__/ 
                                                              
   GitHub Repository Setup 🐙
   
   Desenvolvido por: Ramel Tecnologia
   Autor: Rafa Martins
   Site: ramelseg.com.br
   
EOF
    echo -e "${NC}"
}

# Verificar se Git está instalado
check_git() {
    if ! command -v git &> /dev/null; then
        error "Git não está instalado. Por favor, instale o Git primeiro."
    fi
    
    if ! command -v gh &> /dev/null; then
        warn "GitHub CLI não está instalado. Algumas funcionalidades podem não funcionar."
        warn "Instale com: curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
        warn "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
        warn "sudo apt update && sudo apt install gh"
    fi
    
    log "Git verificado com sucesso!"
}

# Configurar Git
setup_git() {
    log "Configurando Git..."
    
    # Verificar se já está configurado
    if ! git config --global user.name &> /dev/null; then
        echo -n "Digite seu nome para o Git: "
        read -r GIT_NAME
        git config --global user.name "$GIT_NAME"
    fi
    
    if ! git config --global user.email &> /dev/null; then
        echo -n "Digite seu email para o Git: "
        read -r GIT_EMAIL
        git config --global user.email "$GIT_EMAIL"
    fi
    
    log "Git configurado!"
}

# Inicializar repositório
init_repository() {
    log "Inicializando repositório Git..."
    
    # Verificar se já é um repositório
    if [[ ! -d ".git" ]]; then
        git init
        log "Repositório Git inicializado!"
    else
        log "Repositório Git já existe!"
    fi
}

# Criar .gitignore
create_gitignore() {
    log "Criando .gitignore..."
    
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Production builds
dist/
build/
.next/
out/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache
.cache
.parcel-cache

# Next.js build output
.next

# Nuxt.js build / generate output
.nuxt

# Gatsby files
.cache/
public

# Storybook build outputs
.out
.storybook-out

# Temporary folders
tmp/
temp/

# Docker
.dockerignore

# Local data
data/
uploads/
storage/

# SSL certificates
*.pem
*.crt
*.key

# Backup files
*.backup
*.bak

# Database
*.sqlite
*.db

# Convex
.env.local
convex/_generated/

# DevBr specific
nginx/ssl/
traefik/letsencrypt/
postgres/data/
redis/data/
EOF
    
    log ".gitignore criado!"
}

# Criar arquivos de configuração do GitHub
create_github_files() {
    log "Criando arquivos de configuração do GitHub..."
    
    # Criar diretório .github
    mkdir -p .github/{workflows,ISSUE_TEMPLATE,PULL_REQUEST_TEMPLATE}
    
    # Workflow de CI/CD
    cat > .github/workflows/ci.yml << 'EOF'
name: CI/CD DevBr

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run type check
      run: npm run typecheck
    
    - name: Run lint
      run: npm run lint

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Use Node.js 20.x
      uses: actions/setup-node@v4
      with:
        node-version: 20.x
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build application
      run: npm run build

  docker:
    needs: [test, build]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          rameltecnologia/devbr:latest
          rameltecnologia/devbr:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
EOF

    # Template de Issue
    cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Relatório de Bug
about: Criar um relatório para nos ajudar a melhorar
title: '[BUG] '
labels: bug
assignees: ''
---

**Descreva o bug**
Uma descrição clara e concisa do que é o bug.

**Para Reproduzir**
Passos para reproduzir o comportamento:
1. Vá para '...'
2. Clique em '....'
3. Role para baixo até '....'
4. Veja o erro

**Comportamento Esperado**
Uma descrição clara e concisa do que você esperava que acontecesse.

**Screenshots**
Se aplicável, adicione screenshots para ajudar a explicar seu problema.

**Ambiente (por favor, complete as seguintes informações):**
 - OS: [ex: Ubuntu 20.04]
 - Browser [ex: chrome, safari]
 - Versão [ex: 22]
 - Node.js [ex: 20.0.0]

**Informações Adicionais**
Adicione qualquer outro contexto sobre o problema aqui.
EOF

    # Template de Feature Request
    cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Solicitação de Funcionalidade
about: Sugira uma ideia para este projeto
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

**Sua solicitação de funcionalidade está relacionada a um problema? Por favor, descreva.**
Uma descrição clara e concisa de qual é o problema. Ex: Eu sempre fico frustrado quando [...]

**Descreva a solução que você gostaria**
Uma descrição clara e concisa do que você quer que aconteça.

**Descreva alternativas que você considerou**
Uma descrição clara e concisa de quaisquer soluções ou funcionalidades alternativas que você considerou.

**Contexto adicional**
Adicione qualquer outro contexto ou screenshots sobre a solicitação de funcionalidade aqui.
EOF

    # Template de Pull Request
    cat > .github/PULL_REQUEST_TEMPLATE/pull_request_template.md << 'EOF'
## Descrição

Por favor, inclua um resumo da mudança e qual issue é corrigida. Por favor, inclua também motivação e contexto relevantes. Liste quaisquer dependências que são necessárias para esta mudança.

Fixes # (issue)

## Tipo de mudança

Por favor, delete opções que não são relevantes.

- [ ] Bug fix (mudança não-breaking que corrige um issue)
- [ ] Nova funcionalidade (mudança não-breaking que adiciona funcionalidade)
- [ ] Breaking change (fix ou funcionalidade que causaria funcionalidade existente não funcionar como esperado)
- [ ] Esta mudança requer uma atualização de documentação

## Como isso foi testado?

Por favor, descreva os testes que você executou para verificar suas mudanças. Forneça instruções para que possamos reproduzir. Por favor, liste também quaisquer detalhes relevantes para sua configuração de teste

- [ ] Test A
- [ ] Test B

**Configuração de Teste**:
* Versão do firmware:
* Hardware:
* Toolchain:
* SDK:

## Checklist:

- [ ] Meu código segue as diretrizes de estilo deste projeto
- [ ] Eu realizei uma auto-revisão do meu próprio código
- [ ] Eu comentei meu código, particularmente em áreas difíceis de entender
- [ ] Eu fiz mudanças correspondentes na documentação
- [ ] Minhas mudanças não geram novos warnings
- [ ] Eu adicionei testes que provam que meu fix é efetivo ou que minha funcionalidade funciona
- [ ] Testes unitários novos e existentes passam localmente com minhas mudanças
- [ ] Quaisquer mudanças dependentes foram merged e publicadas em módulos downstream
EOF

    log "Arquivos de configuração do GitHub criados!"
}

# Criar LICENSE
create_license() {
    log "Criando arquivo LICENSE..."
    
    cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 Ramel Tecnologia - Rafa Martins

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
    
    log "Arquivo LICENSE criado!"
}

# Criar CHANGELOG
create_changelog() {
    log "Criando CHANGELOG..."
    
    cat > CHANGELOG.md << 'EOF'
# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Não Lançado]

### Adicionado
- Configuração inicial do projeto
- Interface em português brasileiro
- Sistema de instalação automática
- Suporte a Docker e Docker Swarm
- Documentação completa

## [1.0.0] - 2024-01-XX

### Adicionado
- Primeira versão do DevBr
- Tradução completa para português brasileiro
- Nova identidade visual com cores amigáveis
- Instalador automático
- Suporte a Docker Swarm
- Configuração de proxy reverso
- SSL/HTTPS automático
- Documentação em português

### Modificado
- Interface adaptada para desenvolvedores brasileiros
- Cores e tema personalizados
- Templates e receitas localizadas

### Corrigido
- Problemas de compatibilidade
- Questões de performance
- Bugs de interface

[Não Lançado]: https://github.com/rameltecnologia/devbr/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/rameltecnologia/devbr/releases/tag/v1.0.0
EOF
    
    log "CHANGELOG criado!"
}

# Fazer commit inicial
initial_commit() {
    log "Fazendo commit inicial..."
    
    # Adicionar todos os arquivos
    git add .
    
    # Fazer commit inicial
    git commit -m "🎉 Initial commit - DevBr v1.0.0

- ✅ Interface 100% em português brasileiro
- ✅ Nova identidade visual com cores amigáveis
- ✅ Sistema de instalação automática
- ✅ Suporte completo a Docker e Docker Swarm
- ✅ Configuração de proxy reverso e SSL
- ✅ Documentação completa em português

Desenvolvido por: Ramel Tecnologia - Rafa Martins
Site: ramelseg.com.br"
    
    log "Commit inicial realizado!"
}

# Configurar repositório remoto
setup_remote() {
    log "Configurando repositório remoto..."
    
    echo -n "Digite o nome do repositório no GitHub [devbr]: "
    read -r REPO_NAME
    REPO_NAME=${REPO_NAME:-devbr}
    
    echo -n "Digite seu username do GitHub: "
    read -r GITHUB_USERNAME
    
    if [[ -z "$GITHUB_USERNAME" ]]; then
        error "Username do GitHub é obrigatório!"
    fi
    
    # Adicionar remote
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    
    log "Repositório remoto configurado!"
    log "URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
}

# Criar repositório no GitHub (se GitHub CLI estiver disponível)
create_github_repo() {
    if command -v gh &> /dev/null; then
        log "Criando repositório no GitHub..."
        
        echo -n "Deseja criar o repositório no GitHub automaticamente? (s/n) [s]: "
        read -r CREATE_REPO
        CREATE_REPO=${CREATE_REPO:-s}
        
        if [[ "$CREATE_REPO" == "s" ]]; then
            # Login no GitHub CLI se necessário
            if ! gh auth status &> /dev/null; then
                log "Fazendo login no GitHub CLI..."
                gh auth login
            fi
            
            # Criar repositório
            gh repo create "$REPO_NAME" \
                --description "DevBr - Agente de IA para Desenvolvimento Full-Stack Brasileiro" \
                --homepage "https://ramelseg.com.br" \
                --public \
                --clone=false
            
            log "Repositório criado no GitHub!"
        fi
    else
        warn "GitHub CLI não disponível. Crie o repositório manualmente em:"
        warn "https://github.com/new"
    fi
}

# Push inicial
initial_push() {
    log "Fazendo push inicial..."
    
    # Definir branch principal
    git branch -M main
    
    # Push inicial
    git push -u origin main
    
    log "Push inicial realizado!"
}

# Criar tags
create_tags() {
    log "Criando tags..."
    
    # Tag da versão inicial
    git tag -a v1.0.0 -m "DevBr v1.0.0 - Primeira versão

- Interface 100% em português brasileiro
- Nova identidade visual
- Sistema de instalação automática
- Suporte a Docker e Docker Swarm
- Documentação completa

Desenvolvido por: Ramel Tecnologia - Rafa Martins"
    
    # Push das tags
    git push origin --tags
    
    log "Tags criadas e enviadas!"
}

# Mostrar informações finais
show_final_info() {
    echo -e "${GREEN}"
    cat << EOF

🎉 Repositório GitHub configurado com sucesso!

📋 Informações do repositório:
   • Nome: $REPO_NAME
   • URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME
   • Branch principal: main
   • Versão: v1.0.0

📁 Arquivos criados:
   • README.md - Documentação completa
   • LICENSE - Licença MIT
   • CHANGELOG.md - Histórico de mudanças
   • .gitignore - Arquivos ignorados
   • .github/ - Configurações do GitHub

🔄 Workflows configurados:
   • CI/CD automático
   • Build e testes
   • Docker build e push

📝 Templates criados:
   • Bug report
   • Feature request
   • Pull request

🛠️  Próximos passos:
   1. Configure os secrets no GitHub:
      - DOCKER_USERNAME
      - DOCKER_PASSWORD
   
   2. Ative as GitHub Actions
   
   3. Configure branch protection rules
   
   4. Adicione colaboradores se necessário

🏢 Desenvolvido por:
   Ramel Tecnologia - Rafa Martins
   Site: ramelseg.com.br

EOF
    echo -e "${NC}"
}

# Função principal
main() {
    show_banner
    check_git
    setup_git
    init_repository
    create_gitignore
    create_github_files
    create_license
    create_changelog
    initial_commit
    setup_remote
    create_github_repo
    initial_push
    create_tags
    show_final_info
}

# Executar setup
main "$@"