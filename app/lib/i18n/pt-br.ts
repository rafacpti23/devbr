// Traduções para Português Brasileiro - DevBr
export const translations = {
  // Header e Navegação
  header: {
    title: 'DevBr - Desenvolvimento Brasil',
    subtitle: 'Agente de IA para desenvolvimento full-stack',
    starOnGitHub: '⭐ GitHub',
    userMenu: 'Menu do usuário',
    settings: 'Configurações e Uso',
    logout: 'Sair',
  },

  // Botões de Ação
  actions: {
    download: 'Baixar Código',
    share: 'Compartilhar',
    deploy: 'Publicar',
    newProject: 'Novo projeto',
    save: 'Salvar',
    cancel: 'Cancelar',
    close: 'Fechar',
    copy: 'Copiar',
    edit: 'Editar',
    delete: 'Excluir',
  },

  // Estados de Deploy
  deploy: {
    idle: 'Publicar',
    building: 'Construindo...',
    zipping: 'Empacotando...',
    deploying: 'Publicando...',
    deployed: 'Publicado',
    redeploy: 'Republicar',
    viewSite: 'Ver site',
    tooltipDeploy: 'Clique para publicar sua aplicação',
    tooltipRedeploy: 'Clique para publicar novamente',
  },

  // Compartilhamento
  share: {
    title: 'Compartilhar projeto',
    saving: 'Salvando...',
    saved: 'Salvo',
    saveSettings: 'Salvar configurações',
    setThumbnail: 'Definir Miniatura',
    copyLink: 'Copiar link',
    openInNewTab: 'Abrir em nova aba',
  },

  // Mensagens de Status
  messages: {
    success: {
      linkCopied: 'Link copiado para a área de transferência!',
      settingsSaved: 'Configurações de compartilhamento salvas',
    },
    error: {
      deployFailed: 'Falha ao publicar. Tente novamente.',
      shareFailed: 'Falha ao atualizar configurações de compartilhamento. Tente novamente.',
      snapshotFailed: 'Falha ao criar snapshot. Tente novamente.',
      updateFileFailed: 'Falha ao atualizar conteúdo do arquivo',
    },
  },

  // Terminal
  terminal: {
    devServer: 'Servidor Dev',
    convexDeploy: 'Deploy Convex',
    terminal: 'Terminal',
  },

  // Geral
  general: {
    loading: 'Carregando...',
    error: 'Erro',
    success: 'Sucesso',
    warning: 'Aviso',
    info: 'Informação',
  },
} as const;

export type TranslationKey = keyof typeof translations;
export type NestedTranslationKey<T> = T extends object
  ? { [K in keyof T]: T[K] extends object ? `${string & K}.${NestedTranslationKey<T[K]>}` : string & K }[keyof T]
  : never;

// Helper function para acessar traduções aninhadas
export function t(key: string): string {
  const keys = key.split('.');
  let value: any = translations;

  for (const k of keys) {
    value = value?.[k];
    if (value === undefined) {
      console.warn(`Translation key not found: ${key}`);
      return key;
    }
  }

  return typeof value === 'string' ? value : key;
}
