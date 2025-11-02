FROM node:20-alpine

# Metadados da imagem
LABEL maintainer="Rafa Martins <rafa@ramelseg.com.br>"
LABEL description="DevBr - Desenvolvimento Brasil"
LABEL version="1.0.0"
LABEL vendor="Ramel Tecnologia"

# Instalar dependências do sistema
RUN apk add --no-cache \
    curl \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S devbr -u 1001 -G nodejs

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm ci --only=production && \
    npm cache clean --force

# Copiar código da aplicação
COPY . .

# Criar diretórios necessários
RUN mkdir -p data logs && \
    chown -R devbr:nodejs /app

# Alterar para usuário não-root
USER devbr

# Expor porta
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Comando de inicialização
CMD ["npm", "start"]