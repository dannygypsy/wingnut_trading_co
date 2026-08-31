<script setup lang="ts">
defineProps<{
  label: string
  value: string | number
  icon: string[]
  accent?: 'teal' | 'mid' | 'dark' | 'warning' | 'danger'
}>()
</script>

<template>
  <div class="bg-white rounded-2xl border border-wtc-border p-5 relative overflow-hidden">
    <!-- Colored top bar -->
    <div class="absolute top-0 left-0 right-0 h-1 rounded-t-2xl" :class="{
      'bg-wtc-teal':      accent === 'teal' || !accent,
      'bg-wtc-teal-mid':  accent === 'mid',
      'bg-wtc-teal-dark': accent === 'dark',
      'bg-amber-400':     accent === 'warning',
      'bg-red-500':       accent === 'danger',
    }" />
    <div class="mt-2">
      <p class="text-3xl font-black text-wtc-text-primary tracking-tight">{{ value }}</p>
      <p class="text-xs font-semibold text-wtc-text-secondary mt-1 uppercase tracking-wider">{{ label }}</p>
    </div>
    <div class="absolute top-4 right-4 opacity-80">
      <FaIcon :icon="icon" class="text-2xl text-wtc-teal" />
    </div>
  </div>
</template>