<script setup lang="ts">
const route = useRoute()

const links = [
  { label: 'Dashboard', to: '/', icon: ['fas', 'house'] },
  { label: 'Cash Flow', to: '/cash-flow', icon: ['fas', 'money-bill-wave'] },
  { label: 'Orders', to: '/orders', icon: ['fas', 'shopping-cart'] },
  { label: 'Inventory', to: '/inventory', icon: ['fas', 'boxes'] },
]

function isActive(to: string) {
  if (to === '/') return route.path === '/'
  return route.path.startsWith(to)
}
</script>

<template>
  <nav class="sticky top-0 z-50 bg-white border-b border-wtc-border">
    <div class="max-w-6xl mx-auto px-4 h-14 flex items-center gap-6">

      <!-- Logo -->
      <NuxtLink to="/" class="flex items-center gap-2 shrink-0">
        <img src="/ponyLogo.png" alt="WTC" class="h-7 w-auto" />
        <div class="flex flex-col leading-none">
          <span class="font-black text-wtc-text-primary tracking-tight text-sm">WINGNUT</span>
          <span class="font-semibold text-wtc-text-secondary tracking-widest text-xs">TRADING CO</span>
        </div>
      </NuxtLink>

      <!-- Nav Links -->
      <div class="flex items-center gap-1 flex-1">
        <NuxtLink
            v-for="link in links"
            :key="link.to"
            :to="link.to"
            class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-semibold transition-colors"
            :class="isActive(link.to)
            ? 'bg-wtc-teal-light text-wtc-teal'
            : 'text-wtc-text-secondary hover:bg-wtc-bg hover:text-wtc-text-primary'"
        >
          <FaIcon :icon="link.icon" class="text-xs" />
          <span class="hidden sm:inline">{{ link.label }}</span>
        </NuxtLink>
      </div>

      <!-- User Menu -->
      <UserMenu />
    </div>
  </nav>
</template>