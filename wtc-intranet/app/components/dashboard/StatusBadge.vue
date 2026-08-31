<script setup lang="ts">
const props = defineProps<{ status: string }>()

const config = computed(() => {
  const map: Record<string, { label: string; classes: string }> = {
    pending:   { label: 'Pending',   classes: 'bg-amber-100 text-amber-700' },
    completed: { label: 'Completed', classes: 'bg-emerald-100 text-emerald-700' },
    delivered: { label: 'Delivered', classes: 'bg-blue-100 text-blue-700' },
    canceled:  { label: 'Canceled',  classes: 'bg-red-100 text-red-700' },
  }
  return map[props.status] ?? { label: props.status, classes: 'bg-gray-100 text-gray-600' }
})
</script>

<template>
  <span class="px-2.5 py-1 rounded-full text-xs font-semibold" :class="config.classes">
    {{ config.label }}
  </span>
</template>