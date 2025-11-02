# DevBr - Setup Principal PowerShell
# Desenvolvido por: Ramel Tecnologia - Rafa Martins
# Site: ramelseg.com.br

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("install", "docker", "swarm", "github", "all")]
    [string]$Action = "all"
)

# Cores para output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

function Write-Log {
    param([string]$Message)
    Write-Host "[DevBr] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[AVISO] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERRO] $Message" -ForegroundColor Red
    exit 1
}

function Show-Banner {
    Write-Host @"
    ____             ____       
   |  _ \  _____   _|  _ \ _ __ 
   | | | |/ _ \ \ / / |_) | '__|
   | |_| |  __/\ V /|  _ <| |   
   |____/ \___| \_/ |_| \_\_|   
                                
   Desenvolvimento Brasil 🇧🇷
   
   Desenvolvido por: Ramel Tecnologia
   Autor: Rafa Martins
   Site: ramelseg.com.br
   
"@ -ForegroundColor Blue
}

function Test-Prerequisites {
    Write-Log "Verificando pré-requisitos..."
    
    # Verificar Node.js
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Error "Node.js não encontrado. Instale em: https://nodejs.org/"
    }
    
    # Verificar npm
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Error "npm não encontrado. Instale o Node.js primeiro."
    }
    
    # Verificar Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git não encontrado. Instale em: https://git-scm.com/"
    }
    
    Write-Log "Pré-requisitos verificados!"
}

function Install-DevBr {
    Write-Log "Instalando DevBr..."
    
    # Instalar dependências
    npm install
    
    # Copiar arquivo de ambiente
    if (-not (Test-Path ".env.local")) {
        Copy-Item ".env.example" ".env.local"
        Write-Log "Arquivo .env.local criado. Configure suas variáveis de ambiente."
    }
    
    # Build da aplicação
    npm run build
    
    Write-Log "DevBr instalado com sucesso!"
}

function Setup-Docker {
    Write-Log "Configurando Docker..."
    
    # Verificar Docker
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker não encontrado. Instale em: https://docker.com/"
    }
    
    # Build da imagem
    docker build -t rameltecnologia/devbr:latest .
    
    Write-Log "Imagem Docker criada!"
    Write-Log "Execute: docker-compose up -d"
}

function Setup-DockerSwarm {
    Write-Log "Configurando Docker Swarm..."
    
    Write-Warn "Para Docker Swarm, execute em um sistema Linux:"
    Write-Warn "bash docker-swarm-deploy.sh"
    
    Write-Log "Arquivos de configuração criados!"
}

function Setup-GitHub {
    Write-Log "Configurando GitHub..."
    
    # Verificar se é um repositório Git
    if (-not (Test-Path ".git")) {
        git init
        Write-Log "Repositório Git inicializado!"
    }
    
    # Adicionar arquivos
    git add .
    
    # Commit inicial
    $commitMessage = @"
🎉 Initial commit - DevBr v1.0.0

- ✅ Interface 100% em português brasileiro
- ✅ Nova identidade visual com cores amigáveis
- ✅ Sistema de instalação automática
- ✅ Suporte completo a Docker e Docker Swarm
- ✅ Configuração de proxy reverso e SSL
- ✅ Documentação completa em português

Desenvolvido por: Ramel Tecnologia - Rafa Martins
Site: ramelseg.com.br
"@
    
    git commit -m $commitMessage
    
    Write-Log "Commit inicial realizado!"
    Write-Log "Configure o repositório remoto com: git remote add origin <URL>"
}

function Show-Instructions {
    Write-Host @"

🎉 DevBr configurado com sucesso!

📋 Próximos passos:

1. 🔧 Configurar ambiente:
   - Edite o arquivo .env.local
   - Configure suas chaves de API

2. 🚀 Executar aplicação:
   - Desenvolvimento: npm run dev
   - Produção: npm start

3. 🐳 Docker (opcional):
   - docker-compose up -d

4. 🐙 GitHub (opcional):
   - Configure repositório remoto
   - git push -u origin main

5. 🌐 Produção:
   - Linux: bash install.sh
   - Docker Swarm: bash docker-swarm-deploy.sh

🔗 Acesso:
   • Local: http://localhost:3000

🛠️  Comandos úteis:
   • Instalar: .\setup-devbr.ps1 -Action install
   • Docker: .\setup-devbr.ps1 -Action docker
   • GitHub: .\setup-devbr.ps1 -Action github

🏢 Desenvolvido por:
   Ramel Tecnologia - Rafa Martins
   Site: ramelseg.com.br

"@ -ForegroundColor Green
}

# Função principal
function Main {
    Show-Banner
    Test-Prerequisites
    
    switch ($Action) {
        "install" {
            Install-DevBr
        }
        "docker" {
            Setup-Docker
        }
        "swarm" {
            Setup-DockerSwarm
        }
        "github" {
            Setup-GitHub
        }
        "all" {
            Install-DevBr
            Setup-Docker
            Setup-DockerSwarm
            Setup-GitHub
        }
    }
    
    Show-Instructions
}

# Executar
Main