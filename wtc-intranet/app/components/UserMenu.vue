<script setup lang="ts">
const open = ref(false)

async function signOut() {
  await $fetch('/api/auth/signout', { method: 'POST' })
  navigateTo('/signin')
}
</script>

<template>
  <div class="relative">
    <button @click="open = !open" class="w-9 h-9 rounded-full bg-wtc-teal-light flex items-center justify-center hover:bg-wtc-teal hover:text-white transition-colors text-wtc-teal">
      <FaIcon :icon="['fas', 'user']" />
    </button>

    <div v-if="open" class="absolute right-0 mt-2 w-40 bg-white rounded-xl border border-wtc-border shadow-lg z-50">
      <button @click="signOut" class="flex items-center gap-2 w-full px-4 py-3 text-sm text-wtc-text-primary hover:bg-wtc-teal-light rounded-xl transition-colors">
        <FaIcon :icon="['fas', 'right-from-bracket']" class="text-wtc-text-secondary" />
        Sign Out
      </button>
    </div>
  </div>
</template>