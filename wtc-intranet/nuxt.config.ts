// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  future: {
    compatibilityVersion: 4,
  },
  compatibilityDate: '2026-08-31',
  devtools: { enabled: true },
  css: ['@fortawesome/fontawesome-svg-core/styles.css'],
  modules: [
    '@nuxtjs/tailwindcss',
    '@vueuse/nuxt',
  ],
  app: {
    head: {
      title: 'Wingnut Trading Co',
      titleTemplate: '%s | Wingnut Trading Co'
    }
  }
})
