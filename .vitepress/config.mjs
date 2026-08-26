import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Ruby Projects Handbook',
  description: 'Projetos de bolso: do HTTP puro ao Rails',
  lang: 'pt-BR',

  ignoreDeadLinks: true,
  srcExclude: ['projects/**'],

  base: '/projetcs-ruby-handbook/',

  head: [
    ['meta', { property: 'og:locale', content: 'pt_BR' }],
    ['meta', { property: 'og:title', content: 'Ruby Projects Handbook' }],
    ['meta', { property: 'og:url', content: 'https://alencarfreire.github.io/projetcs-ruby-handbook/' }]
  ],

  themeConfig: {
    nav: [
      { text: 'Início', link: '/' },
      { text: 'Roadmap', link: '/roadmap' },
      { text: 'GitHub', link: 'https://github.com/alencarfreire/projetcs-ruby-handbook' }
    ],

    sidebar: [
      {
        text: '1. HTTP API pura',
        collapsed: false,
        items: [
          { text: '1.1 O problema e o recorte', link: '/docs/01-http-api/01-o-problema' },
          { text: '1.2 Servidor HTTP com stdlib', link: '/docs/01-http-api/02-servidor-http' },
          { text: '1.3 Rotas na mão', link: '/docs/01-http-api/03-rotas' },
          { text: '1.4 JSON request/response', link: '/docs/01-http-api/04-json' },
          { text: '1.5 Store em memória', link: '/docs/01-http-api/05-store' },
          { text: '1.6 Status codes', link: '/docs/01-http-api/06-status-codes' },
          { text: '1.7 Como rodar e testar com curl', link: '/docs/01-http-api/07-como-rodar' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/alencarfreire/projetcs-ruby-handbook' }
    ],

    footer: {
      message: 'Publicado sob a licença MIT',
      copyright: 'Feito com 🤖 por Vinícius Freire'
    },

    search: {
      provider: 'local',
      options: {
        translations: {
          button: {
            buttonText: 'Buscar',
            buttonAriaLabel: 'Buscar'
          },
          modal: {
            noResultsText: 'Sem resultados para',
            resetButtonTitle: 'Limpar busca',
            footer: {
              selectText: 'selecionar',
              navigateText: 'navegar',
              closeText: 'fechar'
            }
          }
        }
      }
    },

    outline: {
      level: [2, 3],
      label: 'Nesta página'
    },

    docFooter: {
      prev: 'Anterior',
      next: 'Próxima'
    },

    darkModeSwitchLabel: 'Tema',
    lightModeSwitchTitle: 'Mudar para o tema claro',
    darkModeSwitchTitle: 'Mudar para o tema escuro',
    sidebarMenuLabel: 'Menu',
    returnToTopLabel: 'Voltar ao topo'
  }
})
