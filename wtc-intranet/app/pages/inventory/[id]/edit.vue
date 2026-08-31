<script setup lang="ts">
const route = useRoute()
const id = route.params.id as string

interface InventoryItem {
  id: string
  product_id: string | null
  category: string
  name: string
  size: string | null
  full_name: string
  type: string | null
  cost: number
  retail: number
  purchased_on: string
  num_purchased: number
  remaining: number
}

const { data: item } = await useFetch<InventoryItem>(`/api/inventory/${id}`)
const { data: categories } = await useFetch('/api/inventory/categories')

const form = reactive({
  product_id: item.value?.product_id || '',
  category: item.value?.category || '',
  name: item.value?.name || '',
  size: item.value?.size || '',
  full_name: item.value?.full_name || '',
  type: item.value?.type || '',
  cost: item.value?.cost?.toString() || '',
  retail: item.value?.retail?.toString() || '',
  purchased_on: item.value?.purchased_on
      ? new Date(item.value.purchased_on).toISOString().split('T')[0]
      : '',
  num_purchased: item.value?.num_purchased?.toString() || '',
  remaining: item.value?.remaining?.toString() || '',
})

const submitting = ref(false)
const confirmDelete = ref(false)
const deleting = ref(false)

async function submit() {
  submitting.value = true
  try {
    await $fetch(`/api/inventory/${id}`, { method: 'PUT' as const, body: form })
    navigateTo('/inventory')
  } catch {
    submitting.value = false
  }
}

async function deleteItem() {
  deleting.value = true
  try {
    await $fetch(`/api/inventory/${id}`, { method: 'DELETE' as const })
    navigateTo('/inventory')
  } catch {
    deleting.value = false
    confirmDelete.value = false
  }
}
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-8">
    <div class="mb-6 flex items-center gap-3">
      <NuxtLink to="/inventory" class="text-wtc-text-secondary hover:text-wtc-teal transition-colors">
        <FaIcon :icon="['fas', 'chevron-left']" />
      </NuxtLink>
      <div>
        <h1 class="text-2xl font-black text-wtc-text-primary tracking-tight">Edit Inventory Item</h1>
        <p class="text-sm text-wtc-text-secondary font-mono">{{ item?.full_name }}</p>
      </div>
    </div>

    <form @submit.prevent="submit" class="bg-white rounded-2xl border border-wtc-border p-6 space-y-4">

      <!-- Product ID -->
      <div>
        <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Product ID</label>
        <input v-model="form.product_id" type="text"
               class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal font-mono" />
      </div>

      <!-- Name + Full Name -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Name <span class="text-red-500">*</span></label>
          <input v-model="form.name" type="text" required
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Full Name <span class="text-red-500">*</span></label>
          <input v-model="form.full_name" type="text" required
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
      </div>

      <!-- Category + Type + Size -->
      <div class="grid grid-cols-3 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Category <span class="text-red-500">*</span></label>
          <div class="relative">
            <select v-model="form.category" required
                    class="appearance-none h-10 w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal">
              <option value="">Select...</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.name">{{ cat.name }}</option>
            </select>
            <FaIcon :icon="['fas', 'chevron-down']" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-wtc-text-secondary" />
          </div>
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Type</label>
          <div class="relative">
            <select v-model="form.type"
                    class="appearance-none h-10 w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal">
              <option value="">None</option>
              <option value="blank">Blank</option>
              <option value="transfer">Transfer</option>
              <option value="other">Other</option>
            </select>
            <FaIcon :icon="['fas', 'chevron-down']" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-wtc-text-secondary" />
          </div>
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Size</label>
          <div class="relative">
            <select v-model="form.size"
                    class="appearance-none h-10 w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal">
              <option value="">N/A</option>
              <option>XS</option>
              <option>S</option>
              <option>M</option>
              <option>L</option>
              <option>XL</option>
              <option>2XL</option>
              <option>3XL</option>
              <option>4XL</option>
            </select>
            <FaIcon :icon="['fas', 'chevron-down']" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-wtc-text-secondary" />
          </div>
        </div>
      </div>

      <!-- Cost + Retail -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Cost <span class="text-red-500">*</span></label>
          <input v-model="form.cost" type="number" step="0.01" min="0" required
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Retail <span class="text-red-500">*</span></label>
          <input v-model="form.retail" type="number" step="0.01" min="0" required
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
      </div>

      <!-- Purchased On + Num Purchased + Remaining -->
      <div class="grid grid-cols-3 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Purchased On <span class="text-red-500">*</span></label>
          <input v-model="form.purchased_on" type="date" required
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Purchased <span class="text-red-500">*</span></label>
          <input v-model="form.num_purchased" type="number" min="1" required
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Remaining <span class="text-red-500">*</span></label>
          <input v-model="form.remaining" type="number" min="0" required
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
      </div>

      <!-- Actions -->
      <div class="flex items-center justify-end gap-3 pt-2">
        <NuxtLink to="/inventory" class="px-4 py-2 rounded-xl border border-wtc-border text-sm font-semibold text-wtc-text-secondary hover:bg-wtc-bg transition-colors">
          Cancel
        </NuxtLink>
        <button type="submit" :disabled="submitting"
                class="px-6 py-2 rounded-xl bg-wtc-teal text-white text-sm font-semibold hover:bg-wtc-teal-dark disabled:opacity-50 transition-colors">
          {{ submitting ? 'Saving…' : 'Save Changes' }}
        </button>
      </div>

    </form>

    <!-- Danger Zone -->
    <div class="mt-8 rounded-2xl border border-red-200 bg-red-50 p-5">
      <p class="text-sm font-bold text-red-700 mb-1">Danger Zone</p>
      <p class="text-xs text-red-500 mb-4">Permanently deletes this inventory item. Cannot be undone.</p>

      <div v-if="!confirmDelete">
        <button @click="confirmDelete = true"
                class="px-4 py-2 rounded-xl bg-white border border-red-300 text-red-600 text-sm font-semibold hover:bg-red-100 transition-colors">
          Delete This Item
        </button>
      </div>

      <div v-else class="flex items-center gap-3">
        <p class="text-sm font-semibold text-red-700">Are you sure? This cannot be undone.</p>
        <button @click="deleteItem" :disabled="deleting"
                class="px-4 py-2 rounded-xl bg-red-600 text-white text-sm font-semibold hover:bg-red-700 disabled:opacity-50 transition-colors">
          {{ deleting ? 'Deleting…' : 'Yes, Delete It' }}
        </button>
        <button @click="confirmDelete = false"
                class="px-4 py-2 rounded-xl border border-wtc-border text-sm font-semibold text-wtc-text-secondary hover:bg-white transition-colors">
          Cancel
        </button>
      </div>
    </div>

  </div>
</template>