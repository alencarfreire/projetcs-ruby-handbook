import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Ruby Projects Handbook',
  description: 'Projetos de bolso: do HTTP puro ao Rails',
  lang: 'pt-BR',

  srcExclude: ['projects/**/*.rb'],

  // README.md no GitHub. No site, /projects/foo/ precisa de index.html.
  rewrites: {
    'projects/:name/README.md': 'projects/:name/index.md'
  },

  base: '/projetcs-ruby-handbook/',

  head: [
    ['meta', { property: 'og:locale', content: 'pt_BR' }],
    ['meta', { property: 'og:title', content: 'Ruby Projects Handbook' }],
    ['meta', { property: 'og:url', content: 'https://alencarfreire.github.io/projetcs-ruby-handbook/' }]
  ],

  themeConfig: {
    nav: [
      { text: 'Início', link: '/' },
      { text: 'Projetos', link: '/projetos' },
      { text: 'Roadmap', link: '/roadmap' },
      { text: 'GitHub', link: 'https://github.com/alencarfreire/projetcs-ruby-handbook' }
    ],

    sidebar: [
      {
        text: 'Projetos',
        collapsed: false,
        items: [
          { text: 'Pasta, comandos e fonte', link: '/projetos' },
          { text: '01 — HTTP puro', link: '/projects/01-http-api/' },
          { text: '02 — Pet hotel HTML', link: '/projects/02-pet-hotel/' },
          { text: '03 — API-only', link: '/projects/03-pet-hotel-api/' },
          { text: '04 — Hotwire', link: '/projects/04-pet-hotel-hotwire/' },
          { text: '05 — Sidekiq', link: '/projects/05-pet-hotel-sidekiq/' },
          { text: '06 — Action Cable', link: '/projects/06-pet-hotel-cable/' },
          { text: '07 — Docker Compose', link: '/projects/07-pet-hotel-docker/' },
          { text: '09 — Roda', link: '/projects/09-roda-routing/' },
          { text: '10 — Sequel', link: '/projects/10-sequel-sqlite/' },
          { text: '11 — A pragmática', link: '/projects/11-roda-pragmatic/' },
          { text: '12 — B hash_routes', link: '/projects/12-roda-modular/' },
          { text: '14 — Ingressos', link: '/projects/14-ingressos/' },
          { text: '15 — Docker ingressos', link: '/projects/15-ingressos-docker/' }
        ]
      },
      {
        text: '1. HTTP API pura',
        collapsed: true,
        items: [
          { text: '1.1 O problema e o recorte', link: '/docs/01-http-api/01-o-problema' },
          { text: '1.2 Servidor HTTP com stdlib', link: '/docs/01-http-api/02-servidor-http' },
          { text: '1.3 Rotas na mão', link: '/docs/01-http-api/03-rotas' },
          { text: '1.4 JSON request/response', link: '/docs/01-http-api/04-json' },
          { text: '1.5 Store em memória', link: '/docs/01-http-api/05-store' },
          { text: '1.6 Status codes', link: '/docs/01-http-api/06-status-codes' },
          { text: '1.7 Como rodar e testar com curl', link: '/docs/01-http-api/07-como-rodar' },
          { text: 'Código completo', link: '/docs/01-http-api/codigo' }
        ]
      },
      {
        text: '2. Pet hotel em Rails',
        collapsed: true,
        items: [
          { text: '2.1 O problema e o recorte', link: '/docs/02-pet-hotel/01-o-problema' },
          { text: '2.2 Models e migrations', link: '/docs/02-pet-hotel/02-models' },
          { text: '2.3 Auth com has_secure_password', link: '/docs/02-pet-hotel/03-auth' },
          { text: '2.4 Owners e pets', link: '/docs/02-pet-hotel/04-owners-pets' },
          { text: '2.5 Estadia', link: '/docs/02-pet-hotel/05-estadia' },
          { text: '2.6 Validações', link: '/docs/02-pet-hotel/06-validacoes' },
          { text: '2.7 Request specs', link: '/docs/02-pet-hotel/07-request-specs' },
          { text: '2.8 Como rodar', link: '/docs/02-pet-hotel/08-como-rodar' },
          { text: 'Código (models e auth)', link: '/docs/02-pet-hotel/codigo' }
        ]
      },
      {
        text: '3. Pet hotel API-only',
        collapsed: false,
        items: [
          { text: '3.1 O problema e o recorte', link: '/docs/03-pet-hotel-api/01-o-problema' },
          { text: '3.2 api_only', link: '/docs/03-pet-hotel-api/02-api-only' },
          { text: '3.3 Token Bearer', link: '/docs/03-pet-hotel-api/03-token' },
          { text: '3.4 JSON', link: '/docs/03-pet-hotel-api/04-json' },
          { text: '3.5 Check-in e 4xx', link: '/docs/03-pet-hotel-api/05-status-codes' },
          { text: '3.6 401 vs 404', link: '/docs/03-pet-hotel-api/06-401-vs-404' },
          { text: '3.7 Request specs', link: '/docs/03-pet-hotel-api/07-request-specs' },
          { text: '3.8 Como rodar', link: '/docs/03-pet-hotel-api/08-como-rodar' },
          { text: 'Código (token e JSON)', link: '/docs/03-pet-hotel-api/codigo' }
        ]
      },
      {
        text: '4. Hotwire',
        collapsed: true,
        items: [
          { text: '4.1 O problema e o recorte', link: '/docs/04-pet-hotel-hotwire/01-o-problema' },
          { text: '4.2 Drive vs Frame vs Stream', link: '/docs/04-pet-hotel-hotwire/02-drive-frame-stream' },
          { text: '4.3 Frame da ocupação', link: '/docs/04-pet-hotel-hotwire/03-frame' },
          { text: '4.4 Stream', link: '/docs/04-pet-hotel-hotwire/04-stream' },
          { text: '4.5 Outra aba', link: '/docs/04-pet-hotel-hotwire/05-outra-aba' },
          { text: '4.6 Como rodar', link: '/docs/04-pet-hotel-hotwire/06-como-rodar' },
          { text: 'Código (quadro)', link: '/docs/04-pet-hotel-hotwire/codigo' }
        ]
      },
      {
        text: '5. Sidekiq',
        collapsed: true,
        items: [
          { text: '5.1 O que não cabe no request', link: '/docs/05-pet-hotel-sidekiq/01-o-problema' },
          { text: '5.2 Três processos', link: '/docs/05-pet-hotel-sidekiq/02-tres-processos' },
          { text: '5.3 Lembrete', link: '/docs/05-pet-hotel-sidekiq/03-lembrete' },
          { text: '5.4 Relatório diário', link: '/docs/05-pet-hotel-sidekiq/04-relatorio' },
          { text: '5.5 Falha e idempotência', link: '/docs/05-pet-hotel-sidekiq/05-falha' },
          { text: '5.6 Specs de job', link: '/docs/05-pet-hotel-sidekiq/06-specs' },
          { text: '5.7 Como rodar', link: '/docs/05-pet-hotel-sidekiq/07-como-rodar' },
          { text: 'Código (jobs)', link: '/docs/05-pet-hotel-sidekiq/codigo' }
        ]
      },
      {
        text: '6. Action Cable',
        collapsed: true,
        items: [
          { text: '6.1 Outra aba', link: '/docs/06-pet-hotel-cable/01-o-problema' },
          { text: '6.2 Connection', link: '/docs/06-pet-hotel-cable/02-connection' },
          { text: '6.3 Channel', link: '/docs/06-pet-hotel-cable/03-channel' },
          { text: '6.4 Broadcast', link: '/docs/06-pet-hotel-cable/04-broadcast' },
          { text: '6.5 Specs', link: '/docs/06-pet-hotel-cable/05-specs' },
          { text: '6.6 Como rodar', link: '/docs/06-pet-hotel-cable/06-como-rodar' },
          { text: 'Código (channel)', link: '/docs/06-pet-hotel-cable/codigo' }
        ]
      },
      {
        text: '7. Docker Compose',
        collapsed: true,
        items: [
          { text: '7.1 Empacotar', link: '/docs/07-pet-hotel-docker/01-o-problema' },
          { text: '7.2 Dockerfile', link: '/docs/07-pet-hotel-docker/02-dockerfile' },
          { text: '7.3 Compose', link: '/docs/07-pet-hotel-docker/03-compose' },
          { text: '7.4 Env, volume, rede', link: '/docs/07-pet-hotel-docker/04-env-volume' },
          { text: '7.5 Como rodar', link: '/docs/07-pet-hotel-docker/05-como-rodar' },
          { text: 'Código (compose)', link: '/docs/07-pet-hotel-docker/codigo' }
        ]
      },
      {
        text: '8. System design',
        collapsed: true,
        items: [
          { text: '8.1 O problema em escala', link: '/docs/08-system-design/01-o-problema' },
          { text: '8.2 Recorte do quadro', link: '/docs/08-system-design/02-recorte-quadro' },
          { text: '8.3 Request, job, websocket', link: '/docs/08-system-design/03-request-job-ws' },
          { text: '8.4 Consistência', link: '/docs/08-system-design/04-consistencia' },
          { text: '8.5 Falhas', link: '/docs/08-system-design/05-falhas' },
          { text: '8.6 Exercício de desenho', link: '/docs/08-system-design/06-exercicio' }
        ]
      },
      {
        text: '9. Roda sozinho',
        collapsed: false,
        items: [
          { text: '9.1 O problema e o recorte', link: '/docs/09-roda/01-o-problema' },
          { text: '9.2 Rack', link: '/docs/09-roda/02-rack' },
          { text: '9.3 A árvore', link: '/docs/09-roda/03-arvore' },
          { text: '9.4 Plugins', link: '/docs/09-roda/04-plugins' },
          { text: '9.5 Halt, JSON', link: '/docs/09-roda/05-halt-json' },
          { text: '9.6 Como rodar', link: '/docs/09-roda/06-como-rodar' },
          { text: 'Código', link: '/docs/09-roda/codigo' }
        ]
      },
      {
        text: '10. Sequel sozinho',
        collapsed: true,
        items: [
          { text: '10.1 O problema e o recorte', link: '/docs/10-sequel/01-o-problema' },
          { text: '10.2 Conexão', link: '/docs/10-sequel/02-conexao' },
          { text: '10.3 Migrations', link: '/docs/10-sequel/03-migrations' },
          { text: '10.4 Dataset Hash', link: '/docs/10-sequel/04-dataset-hash' },
          { text: '10.5 Model', link: '/docs/10-sequel/05-model' },
          { text: '10.6 Como rodar', link: '/docs/10-sequel/06-como-rodar' },
          { text: 'Código', link: '/docs/10-sequel/codigo' }
        ]
      },
      {
        text: '11. A pragmática',
        collapsed: true,
        items: [
          { text: '11.1 Arquitetura A', link: '/docs/11-roda-pragmatic/01-o-problema' },
          { text: '11.2 Boot', link: '/docs/11-roda-pragmatic/02-boot' },
          { text: '11.3 Rodauth JWT', link: '/docs/11-roda-pragmatic/03-rodauth' },
          { text: '11.4 CRUD eventos', link: '/docs/11-roda-pragmatic/04-crud' },
          { text: '11.5 Status', link: '/docs/11-roda-pragmatic/05-status' },
          { text: '11.6 Quando A dói', link: '/docs/11-roda-pragmatic/06-quando-a-doi' },
          { text: '11.7 Como rodar', link: '/docs/11-roda-pragmatic/07-como-rodar' },
          { text: 'Código', link: '/docs/11-roda-pragmatic/codigo' }
        ]
      },
      {
        text: '12. B hash_routes',
        collapsed: true,
        items: [
          { text: '12.1 Arquitetura B', link: '/docs/12-roda-modular/01-o-problema' },
          { text: '12.2 Plugin', link: '/docs/12-roda-modular/02-plugin' },
          { text: '12.3 app.rb magro', link: '/docs/12-roda-modular/03-app-magro' },
          { text: '12.4 Ramos', link: '/docs/12-roda-modular/04-ramos' },
          { text: '12.5 O(1)', link: '/docs/12-roda-modular/05-o1' },
          { text: '12.6 Como rodar', link: '/docs/12-roda-modular/06-como-rodar' },
          { text: 'Código', link: '/docs/12-roda-modular/codigo' }
        ]
      },
      {
        text: '13. C e D',
        collapsed: true,
        items: [
          { text: '13.1 Mapa A/B/C/D', link: '/docs/13-roda-arquiteturas/01-mapa' },
          { text: '13.2 Hexagonal', link: '/docs/13-roda-arquiteturas/02-hexagonal' },
          { text: '13.3 dry-rb', link: '/docs/13-roda-arquiteturas/03-dry-rb' },
          { text: '13.4 Como escolher', link: '/docs/13-roda-arquiteturas/04-escolher' },
          { text: '13.5 Exercício', link: '/docs/13-roda-arquiteturas/05-exercicio' }
        ]
      },
      {
        text: '14. Ingressos',
        collapsed: false,
        items: [
          { text: '14.1 O produto', link: '/docs/14-ingressos/01-o-problema' },
          { text: '14.2 Schema', link: '/docs/14-ingressos/02-schema' },
          { text: '14.3 ReservarLote', link: '/docs/14-ingressos/03-reservar' },
          { text: '14.4 Webhook', link: '/docs/14-ingressos/04-webhook' },
          { text: '14.5 Testes', link: '/docs/14-ingressos/05-testes' },
          { text: '14.6 Jobs e Postgres', link: '/docs/14-ingressos/06-ops-app' },
          { text: '14.7 Como rodar', link: '/docs/14-ingressos/07-como-rodar' },
          { text: 'Código', link: '/docs/14-ingressos/codigo' }
        ]
      },
      {
        text: '15. Ops e deploy',
        collapsed: true,
        items: [
          { text: '15.1 Empacotar', link: '/docs/15-ingressos-ops/01-o-problema' },
          { text: '15.2 Compose', link: '/docs/15-ingressos-ops/02-compose' },
          { text: '15.3 Produção', link: '/docs/15-ingressos-ops/03-producao' },
          { text: 'Código', link: '/docs/15-ingressos-ops/codigo' }
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
