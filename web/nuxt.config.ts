export default defineNuxtConfig({
  devtools: { enabled: true },

  modules: [
    '@nuxtjs/supabase',
    '@pinia/nuxt',
    '@nuxtjs/tailwindcss',
    '@nuxtjs/color-mode',
    '@vueuse/nuxt',
    '@nuxtjs/sitemap',
    '@nuxt/eslint',
  ],

  colorMode: {
    classSuffix: '',
    preference: 'system',
    fallback: 'light',
  },

  supabase: {
    redirectOptions: {
      login: '/auth',
      callback: '/auth/callback',
      exclude: ['/auth/*', '/'],
    },
  },

  pinia: {
    storesDirs: ['./stores/**'],
  },

  typescript: {
    strict: true,
  },

  site: {
    url: 'https://monasafe.com',
  },

  sitemap: {
    exclude: [
      '/auth/**',
      '/onboarding/**',
      '/dashboard/**',
      '/transactions/**',
      '/recurring/**',
      '/stats/**',
      '/settings/**',
    ],
  },

  app: {
    pageTransition: { name: 'page', mode: 'out-in' },
    head: {
      htmlAttrs: { lang: 'fr' },
      title: 'Monasafe — Gestion de finances personnelles',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Gérez vos finances personnelles simplement avec Monasafe : suivi de comptes, transactions, budgets, récurrences et statistiques.' },
        { name: 'theme-color', content: '#1B5E5A' },
        { name: 'author', content: 'Lucas MARTINELLE' },
        // Open Graph
        { property: 'og:type', content: 'website' },
        { property: 'og:url', content: 'https://monasafe.com' },
        { property: 'og:title', content: 'Monasafe — Gestion de finances personnelles' },
        { property: 'og:description', content: 'Gérez vos finances personnelles simplement avec Monasafe : suivi de comptes, transactions, budgets, récurrences et statistiques.' },
        { property: 'og:image', content: 'https://monasafe.com/og.png' },
        { property: 'og:locale', content: 'fr_FR' },
        { property: 'og:site_name', content: 'Monasafe' },
        // Twitter Card
        { name: 'twitter:card', content: 'summary' },
        { name: 'twitter:title', content: 'Monasafe — Gestion de finances personnelles' },
        { name: 'twitter:description', content: 'Gérez vos finances personnelles simplement avec Monasafe.' },
        { name: 'twitter:image', content: 'https://monasafe.com/og.png' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
        { rel: 'icon', type: 'image/png', sizes: '96x96', href: '/favicon-96x96.png' },
        { rel: 'apple-touch-icon', sizes: '180x180', href: '/apple-touch-icon.png' },
        { rel: 'manifest', href: '/site.webmanifest' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Poppins:wght@500;600;700&display=swap',
        },
      ],
    },
  },

  runtimeConfig: {
    public: {
      supabaseUrl: '',
      supabaseKey: '',
    },
  },

  css: ['~/assets/css/main.css'],

  compatibilityDate: '2024-11-01',
})
