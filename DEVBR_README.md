# DevBr - Desenvolvimento Brasil 🇧🇷

## Sobre o DevBr

O DevBr é uma versão personalizada e traduzida para português brasileiro do Chef, um agente de IA para desenvolvimento full-stack. Esta versão foi criada especialmente para desenvolvedores brasileiros, oferecendo uma experiência mais amigável e acessível.

## 🎨 Principais Mudanças Realizadas

### 1. **Nova Identidade Visual**

- **Logo personalizada**: Criada uma nova logomarca com cores amigáveis (verde e laranja)
- **Favicon customizado**: Ícone personalizado para o navegador
- **Esquema de cores Lovable**: Paleta de cores mais suave e amigável
  - Verde primário: `#22c55e` (confiança e crescimento)
  - Laranja accent: `#f97316` (energia e criatividade)
  - Tons neutros suaves para melhor legibilidade

### 2. **Tradução Completa para Português**

- Interface totalmente traduzida
- Mensagens de erro e sucesso em português
- Tooltips e descrições localizadas
- Placeholders e textos de ajuda traduzidos

### 3. **Melhorias na Experiência do Usuário**

- **Gradientes suaves**: Fundos com gradientes sutis
- **Animações amigáveis**: Transições suaves e efeitos hover
- **Scrollbars personalizadas**: Barras de rolagem com as cores do tema
- **Efeitos de foco**: Indicadores visuais mais claros

## 🚀 Funcionalidades Traduzidas

### Interface Principal

- ✅ Header e navegação
- ✅ Botões de ação (Baixar, Compartilhar, Publicar)
- ✅ Menu lateral e configurações
- ✅ Campo de entrada de mensagens
- ✅ Receitas e templates

### Componentes Específicos

- ✅ **Botão de Download**: "Baixar Código"
- ✅ **Botão de Compartilhamento**: "Compartilhar projeto"
- ✅ **Botão de Deploy**: "Publicar" com estados (Construindo, Empacotando, Publicando)
- ✅ **Menu do usuário**: "Configurações e Uso", "Sair"
- ✅ **Entrada de texto**: Placeholders contextuais em português

### Receitas e Templates

- ✅ "Criar editor de texto colaborativo"
- ✅ "Adicionar chat com IA"
- ✅ "Adicionar upload de arquivos"
- ✅ "Adicionar busca de texto"

## 🎨 Paleta de Cores DevBr

### Cores Primárias

```css
--devbr-primary-500: #22c55e /* Verde principal */ --devbr-accent-500: #f97316 /* Laranja accent */
  --devbr-secondary-500: #64748b /* Cinza neutro */;
```

### Tema Claro

- Fundo principal: Branco puro
- Fundo secundário: Tons suaves de cinza
- Acentos: Verde e laranja vibrantes

### Tema Escuro

- Fundo principal: Cinza escuro suave
- Fundo secundário: Tons de cinza médio
- Acentos: Verde e laranja mais claros

## 📁 Arquivos Modificados

### Principais

- `app/root.tsx` - Favicon e título
- `app/routes/_index.tsx` - Meta tags e gradiente de fundo
- `app/components/header/Header.tsx` - Logo e textos do header
- `package.json` - Nome e descrição do projeto

### Estilos

- `app/styles/variables.css` - Paleta de cores DevBr
- `app/styles/devbr-theme.css` - Estilos personalizados (novo)
- `app/styles/index.css` - Importação dos novos estilos

### Componentes

- `app/components/header/DownloadButton.tsx`
- `app/components/header/ShareButton.tsx`
- `app/components/header/DeployButton.tsx`
- `app/components/chat/MessageInput.tsx`
- `app/components/sidebar/Menu.client.tsx`

### Assets

- `public/devbr-logo.svg` - Nova logomarca (novo)
- `public/devbr-favicon.svg` - Novo favicon (novo)

### Utilitários

- `app/lib/i18n/pt-br.ts` - Sistema de traduções (novo)

## 🛠️ Como Usar

1. **Instalação**:

   ```bash
   npm install
   ```

2. **Desenvolvimento**:

   ```bash
   npm run dev
   ```

3. **Build**:

   ```bash
   npm run build
   ```

4. **Verificação de tipos**:
   ```bash
   npm run typecheck
   ```

## 🌟 Características Especiais

### Design Amigável

- **Cores suaves**: Paleta inspirada no design Lovable
- **Transições suaves**: Animações que melhoram a experiência
- **Feedback visual**: Indicadores claros de estado e ações

### Acessibilidade

- **Contraste adequado**: Cores que atendem padrões de acessibilidade
- **Foco visível**: Indicadores claros para navegação por teclado
- **Textos legíveis**: Tipografia otimizada para leitura

### Performance

- **CSS otimizado**: Estilos organizados e eficientes
- **Gradientes leves**: Efeitos visuais sem impacto na performance
- **Animações suaves**: Transições que não afetam a responsividade

## 🎯 Próximos Passos

Para continuar melhorando o DevBr, considere:

1. **Tradução completa**: Finalizar tradução de componentes restantes
2. **Documentação**: Criar guias em português
3. **Templates brasileiros**: Adicionar exemplos específicos para o mercado brasileiro
4. **Integração local**: Conectar com serviços brasileiros populares

## 🤝 Contribuição

Este projeto foi criado para a comunidade brasileira de desenvolvedores. Contribuições são bem-vindas para:

- Melhorar traduções
- Adicionar novos recursos
- Otimizar a experiência do usuário
- Criar templates específicos para o Brasil

---

**DevBr** - Desenvolvendo o futuro do Brasil, uma linha de código por vez! 🚀🇧🇷
