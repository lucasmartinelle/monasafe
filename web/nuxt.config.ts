export default defineNuxtConfig({
  devtools: { enabled: true },

  modules: [
    '@nuxtjs/supabase',
    '@pinia/nuxt',
    '@nuxtjs/tailwindcss',
    '@vueuse/nuxt',
  ],

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

  app: {
    head: {
      title: 'SimpleFlow',
      meta: [
        { name: 'description', content: 'Gestion de finances personnelles' },
        { name: 'theme-color', content: '#1B5E5A' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
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
