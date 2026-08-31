<script setup lang="ts">
const { data: categories } = await useFetch('/api/inventory/categories')

const form = reactive({
  product_id: '',
  category: '',
  name: '',
  size: '',
  full_name: '',
  type: '',
  cost: '',
  retail: '',
  purchased_on: '',
  num_purchased: '',
})

const submitting = ref(false)

async function submit() {
  submitting.value = true
  try {
    await $fetch('/api/inventory', { method: 'POST', body: form })
    navigateTo('/inventory')
  } catch {
    submitting.value = false
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
        <h1 class="text-2xl font-black text-wtc-text-primary tracking-tight">Add Inventory Item</h1>
        <p class="text-sm text-wtc-text-secondary">Add a new item or restock an existing one</p>
      </div>
    </div>

    <form @submit.prevent="submit" class="bg-white rounded-2xl border border-wtc-border p-6 space-y-4">

      <!-- Product ID -->
      <div>
        <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Product ID <span class="normal-case font-normal">(leave blank to generate)</span></label>
        <input v-model="form.product_id" type="text" placeholder="e.g. existing product UUID"
               class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
      </div>

      <!-- Name + Full Name -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Name <span class="text-red-500">*</span></label>
          <input v-model="form.name" type="text" required placeholder="e.g. Gildan Softstyle"
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Full Name <span class="text-red-500">*</span></label>
          <input v-model="form.full_name" type="text" required placeholder="e.g. Gildan Softstyle T-Shirt"
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
          <input v-model="form.cost" type="number" step="0.01" min="0" required placeholder="0.00"
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Retail <span class="text-red-500">*</span></label>
          <input v-model="form.retail" type="number" step="0.01" min="0" required placeholder="0.00"
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
      </div>

      <!-- Purchased On + Quantity -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Purchased On <span class="text-red-500">*</span></label>
          <input v-model="form.purchased_on" type="date" required
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Quantity <span class="text-red-500">*</span></label>
          <input v-model="form.num_purchased" type="number" min="1" required placeholder="0"
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
          {{ submitting ? 'Saving…' : 'Add Item' }}
        </button>
      </div>

    </form>
  </div>
</template>