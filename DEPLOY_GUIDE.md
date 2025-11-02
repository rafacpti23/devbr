# Guia de Deploy do Chef

Este guia te ajudará a fazer o deploy do sistema Chef localmente e em produção.

## 🚀 Deploy Local (Desenvolvimento)

### 1. Pré-requisitos

- Node.js 20.19.0 (conforme .nvmrc)
- pnpm (gerenciador de pacotes)
- Uma conta Convex (gratuita)
- Chaves de API de pelo menos um provedor de IA

### 2. Configuração Inicial

```bash
# 1. Instalar pnpm globalmente
npm install -g pnpm

# 2. Instalar dependências
pnpm install

# 3. Configurar Convex (primeira vez)
npx convex dev --once
# Siga as instruções para criar um projeto Convex
```

### 3. Configuração de Variáveis de Ambiente

Edite o arquivo `.env.local` e adicione suas chaves de API:

```env
# Configurações do Convex (geradas automaticamente)
VITE_CONVEX_URL=http://127.0.0.1:3210
CONVEX_DEPLOYMENT=anonymous:seu-deployment

# Configurações do WorkOS (já configuradas)
VITE_WORKOS_CLIENT_ID=client_01K0YV0SNPRYJ5AV4AS0VG7T1J
VITE_WORKOS_REDIRECT_URI=http://127.0.0.1:5173
VITE_WORKOS_API_HOSTNAME=apiauth.convex.dev
WORKOS_CLIENT_ID=client_01K0YV0SNPRYJ5AV4AS0VG7T1J

# Configurações de desenvolvimento
DISABLE_USAGE_REPORTING=1
DISABLE_BEDROCK=1

# OBRIGATÓRIO: Adicione pelo menos uma chave de API
OPENAI_API_KEY=sk-sua-chave-openai-aqui
# OU
ANTHROPIC_API_KEY=sua-chave-anthropic-aqui
# OU
GOOGLE_API_KEY=sua-chave-google-aqui
# OU
XAI_API_KEY=sua-chave-xai-aqui
```

### 4. Executar o Sistema

Abra dois terminais:

**Terminal 1 - Backend Convex:**

```bash
npx convex dev
```

**Terminal 2 - Frontend:**

```bash
pnpm run dev
```

### 5. Acessar o Sistema

- Acesse: http://127.0.0.1:5173
- **IMPORTANTE**: Use 127.0.0.1, não localhost
- Aguarde alguns segundos e recarregue a página se necessário

## 🌐 Deploy em Produção (Vercel)

### 1. Configuração do Convex para Produção

```bash
# 1. Fazer login no Convex
npx convex login

# 2. Criar projeto de produção
npx convex deploy --prod
```

### 2. Configurar OAuth Application

1. Acesse o [Convex Dashboard](https://dashboard.convex.dev/team/settings/applications/oauth-apps)
2. Crie uma OAuth Application
3. Configure as Redirect URIs para seu domínio de produção

### 3. Configurar Variáveis de Ambiente no Convex

No dashboard do Convex, vá em Settings → Environment Variables e configure:

```env
BIG_BRAIN_HOST=https://api.convex.dev
CONVEX_OAUTH_CLIENT_ID=valor-do-oauth-setup
CONVEX_OAUTH_CLIENT_SECRET=valor-do-oauth-setup
WORKOS_CLIENT_ID=client_01K0YV0SNPRYJ5AV4AS0VG7T1J
```

### 4. Deploy no Vercel

```bash
# 1. Instalar Vercel CLI
npm install -g vercel

# 2. Fazer login no Vercel
vercel login

# 3. Fazer deploy
vercel --prod
```

### 5. Configurar Variáveis de Ambiente no Vercel

No dashboard do Vercel, configure:

```env
VITE_CONVEX_URL=sua-url-convex-de-producao
CONVEX_DEPLOYMENT=seu-deployment-de-producao
VITE_WORKOS_CLIENT_ID=client_01K0YV0SNPRYJ5AV4AS0VG7T1J
VITE_WORKOS_REDIRECT_URI=https://seu-dominio.vercel.app
VITE_WORKOS_API_HOSTNAME=apiauth.convex.dev
OPENAI_API_KEY=sua-chave-openai
# Adicione outras chaves de API conforme necessário
```

## 🔧 Comandos Úteis

```bash
# Build para produção
pnpm run build

# Executar testes
pnpm run test

# Linting e formatação
pnpm run lint:fix

# Verificação de tipos
pnpm run typecheck

# Rebuild do template
pnpm run rebuild-template
```

## 🐛 Troubleshooting

### Erro: "No environment variables for model providers are set"

- Adicione pelo menos uma chave de API (OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.)

### Erro: "WORKOS_CLIENT_ID is used but not set"

- Adicione `WORKOS_CLIENT_ID=client_01K0YV0SNPRYJ5AV4AS0VG7T1J` ao .env.local

### Página não carrega corretamente

- Use http://127.0.0.1:5173 em vez de localhost
- Aguarde alguns segundos e recarregue a página

### Problemas de autenticação

- Verifique se as configurações do WorkOS estão corretas
- Certifique-se de que as Redirect URIs estão configuradas corretamente

## 📚 Recursos Adicionais

- [Documentação do Chef](https://docs.convex.dev/chef)
- [Guia de Prompts](https://stack.convex.dev/chef-cookbook-tips-working-with-ai-app-builders)
- [Convex Dashboard](https://dashboard.convex.dev)
- [Repositório no GitHub](https://github.com/get-convex/chef)

## 🔑 Obtendo Chaves de API

### OpenAI

1. Acesse https://platform.openai.com/api-keys
2. Crie uma nova chave de API
3. Adicione ao .env.local como `OPENAI_API_KEY=sk-...`

### Anthropic

1. Acesse https://console.anthropic.com/
2. Vá em API Keys
3. Crie uma nova chave
4. Adicione ao .env.local como `ANTHROPIC_API_KEY=...`

### Google AI

1. Acesse https://aistudio.google.com/app/apikey
2. Crie uma nova chave de API
3. Adicione ao .env.local como `GOOGLE_API_KEY=...`

### xAI (Grok)

1. Acesse https://console.x.ai/
2. Vá em API Keys
3. Crie uma nova chave
4. Adicione ao .env.local como `XAI_API_KEY=...`
