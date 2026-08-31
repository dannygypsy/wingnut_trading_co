<script setup lang="ts">
defineProps<{
  title: string
  description: string
  icon: string[]
  to: string
}>()
</script>

<template>
  <NuxtLink :to="to" class="flex items-center gap-4 bg-white rounded-2xl border border-wtc-border p-5 hover:shadow-md transition-shadow cursor-pointer group">
    <div class="w-12 h-12 rounded-xl bg-wtc-teal-light flex items-center justify-center shrink-0">
      <FaIcon :icon="icon" class="text-xl text-wtc-teal" />
    </div>
    <div class="flex-1 min-w-0">
      <p class="font-bold text-wtc-text-primary">{{ title }}</p>
      <p class="text-sm text-wtc-text-secondary">{{ description }}</p>
    </div>
    <FaIcon :icon="['fas', 'chevron-right']" class="text-wtc-border group-hover:text-wtc-teal transition-colors shrink-0" />
  </NuxtLink>
</template>