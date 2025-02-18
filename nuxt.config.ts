// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: [
    '@nuxtjs/supabase',
    '@pinia/nuxt',
    '@nuxtjs/tailwindcss'
  ],
  supabase: {
    redirectOptions: {
      login: '/auth/login',
      callback: '/confirm',
      exclude: ['/',  '/auth/register'],
    }
  },
  app: {
    head: {
      title: 'Karunia Jaya Medika',
      meta: [
        { name: 'description', content: 'Clinic Point of Sale System' }
      ]
    }
  }
})