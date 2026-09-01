<script setup lang="ts">
useHead({ title: 'Add Inventory' })

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

// Live product search
let searchTimer: ReturnType<typeof setTimeout> | null = null
const searchResults = ref<any[]>([])
const selectedProduct = ref<any>(null)
const showSuggestions = ref(false)

function onNameInput(value: string) {
  if (searchTimer) clearTimeout(searchTimer)
  if (value.length < 3) {
    showSuggestions.value = false
    searchResults.value = []
    return
  }
  searchTimer = setTimeout(async () => {
    const data = await $fetch<{ results: any[] }>(`/api/inventory/search?q=${encodeURIComponent(value)}`)
    const seen = new Set<string>()
    searchResults.value = (data.results || []).filter(r => {
      if (!r.product_id || seen.has(r.product_id)) return false
      seen.add(r.product_id)
      return true
    })
    showSuggestions.value = searchResults.value.length > 0
  }, 350)
}

function selectProduct(r: any) {
  selectedProduct.value = r
  showSuggestions.value = false
  form.product_id = r.product_id
  form.name = r.name || ''
  form.full_name = r.full_name || ''
  form.category = r.category || ''
  form.retail = r.retail ? Number(r.retail).toFixed(2) : ''
  form.type = r.type || ''
  if (r.size) form.size = r.size
}

function clearProduct() {
  selectedProduct.value = null
  form.product_id = ''
}

// Profit margin preview
const margin = computed(() => {
  const cost = parseFloat(form.cost) || 0
  const retail = parseFloat(form.retail) || 0
  return retail - cost
})
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
                 maxlength="23"
                 @input="onNameInput(form.name)"
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
          <p class="mt-1 text-xs text-wtc-text-secondary">{{ form.name.length }}/23 characters</p>
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Full Name <span class="text-red-500">*</span></label>
          <input v-model="form.full_name" type="text" required placeholder="e.g. Gildan Softstyle T-Shirt"
                 class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal" />
        </div>
      </div>

      <!-- Product suggestions -->
      <div v-if="showSuggestions || selectedProduct" class="mt-3 p-3 rounded-xl border border-wtc-teal-mid bg-wtc-teal-light">
        <p class="text-xs font-semibold text-wtc-teal mb-2">Existing product found — reuse product ID?</p>

        <div v-if="selectedProduct" class="flex items-center gap-2 px-3 py-2 bg-white rounded-lg border border-wtc-teal-mid">
          <FaIcon :icon="['fas', 'check']" class="text-wtc-teal text-xs" />
          <span class="text-sm font-semibold text-wtc-text-primary">Using product ID for "{{ selectedProduct.name }}"</span>
          <button type="button" @click="clearProduct" class="ml-auto text-xs text-wtc-text-secondary hover:text-wtc-teal underline">Clear</button>
        </div>

        <div v-else class="flex flex-col gap-1">
          <button v-for="r in searchResults" :key="r.product_id"
                  type="button" @click="selectProduct(r)"
                  class="text-left px-3 py-2 rounded-lg bg-white border border-wtc-teal-mid hover:bg-wtc-teal-light transition-colors text-sm">
            <span class="font-semibold text-wtc-text-primary">{{ r.name }}</span>
            <span v-if="r.size" class="ml-2 text-xs text-wtc-text-secondary">{{ r.size }}</span>
            <span class="ml-2 font-mono text-xs text-wtc-text-secondary">{{ r.product_id?.substring(0, 8) }}…</span>
          </button>
          <button type="button" @click="showSuggestions = false"
                  class="text-left px-3 py-2 rounded-lg bg-white border border-wtc-border hover:bg-wtc-bg transition-colors text-sm text-wtc-text-secondary">
            Create new product ID
          </button>
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

      <!-- Profit Margin Preview -->
      <div class="rounded-xl border border-wtc-teal-mid bg-wtc-teal-light p-4">
        <p class="text-xs font-semibold text-wtc-teal mb-3 uppercase tracking-wider">Profit Margin Preview</p>
        <div class="grid grid-cols-3 gap-4 text-sm">
          <div>
            <span class="text-wtc-text-secondary">Cost</span>
            <p class="font-bold text-wtc-text-primary">${{ (parseFloat(form.cost) || 0).toFixed(2) }}</p>
          </div>
          <div>
            <span class="text-wtc-text-secondary">Retail</span>
            <p class="font-bold text-wtc-text-primary">${{ (parseFloat(form.retail) || 0).toFixed(2) }}</p>
          </div>
          <div>
            <span class="text-wtc-text-secondary">Margin</span>
            <p class="font-bold" :class="margin >= 0 ? 'text-emerald-600' : 'text-red-600'">${{ margin.toFixed(2) }}</p>
          </div>
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