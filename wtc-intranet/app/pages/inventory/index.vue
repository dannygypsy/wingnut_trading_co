<script setup lang="ts">
useHead({ title: 'Inventory' })

const category = ref('')
const lowStock = ref(false)

const { data, pending } = useFetch('/api/inventory', {
  query: computed(() => ({
    ...(category.value && { category: category.value }),
    ...(lowStock.value && { lowStock: 'true' }),
  }))
})

const { data: categories } = await useFetch('/api/inventory/categories')

const summary = computed(() => data.value?.summary ?? {
  totalItems: 0, totalQuantity: 0, totalCostValue: 0, totalRetailValue: 0, potentialProfit: 0
})

const lowStockItems = computed(() => data.value?.lowStockItems ?? [])

// Group flat inventory into product → size → batches
const grouped = computed(() => {
  const items = data.value?.inventory ?? []
  const productMap = new Map<string, {
    key: string
    name: string
    full_name: string
    product_id: string | null
    category: string
    sizes: Map<string, any[]>
  }>()

  for (const item of items) {
    const productKey = item.product_id || item.name
    if (!productMap.has(productKey)) {
      productMap.set(productKey, {
        key: productKey,
        name: item.name,
        full_name: item.full_name,
        product_id: item.product_id,
        category: item.category,
        sizes: new Map()
      })
    }
    const product = productMap.get(productKey)!
    const sizeKey = item.size || ''
    if (!product.sizes.has(sizeKey)) product.sizes.set(sizeKey, [])
    product.sizes.get(sizeKey)!.push(item)
  }

  return Array.from(productMap.values()).map(product => {
    const allBatches = Array.from(product.sizes.values()).flat()
    const totalRemaining = allBatches.reduce((s, i) => s + i.remaining, 0)
    const totalPurchased = allBatches.reduce((s, i) => s + i.num_purchased, 0)
    const totalRetail = allBatches.reduce((s, i) => s + i.total_retail, 0)
    const stockPct = totalPurchased > 0 ? Math.round((totalRemaining / totalPurchased) * 100) : 0

    const sizeOrder = ['XS','S','M','L','XL','2XL','3XL','4XL']
    const sizes = Array.from(product.sizes.entries())
        .sort(([a], [b]) => {
          const ai = sizeOrder.indexOf(a), bi = sizeOrder.indexOf(b)
          return (ai === -1 ? 99 : ai) - (bi === -1 ? 99 : bi)
        })
        .map(([sizeKey, batches]) => {
          const sRemaining = batches.reduce((s, i) => s + i.remaining, 0)
          const sPurchased = batches.reduce((s, i) => s + i.num_purchased, 0)
          const sRetail = batches.reduce((s, i) => s + i.total_retail, 0)
          const sPct = sPurchased > 0 ? Math.round((sRemaining / sPurchased) * 100) : 0
          return { sizeKey, batches, sRemaining, sPurchased, sRetail, sPct }
        })

    return { ...product, sizes, totalRemaining, totalPurchased, totalRetail, stockPct }
  })
})

// Expand/collapse state
const expandedProducts = ref<Set<string>>(new Set())
const expandedSizes = ref<Set<string>>(new Set())

function toggleProduct(key: string) {
  if (expandedProducts.value.has(key)) {
    expandedProducts.value.delete(key)
    // collapse all sizes under this product too
    expandedSizes.value.forEach(sk => {
      if (sk.startsWith(key + '::')) expandedSizes.value.delete(sk)
    })
  } else {
    expandedProducts.value.add(key)
  }
  expandedProducts.value = new Set(expandedProducts.value)
}

function toggleSize(productKey: string, sizeKey: string) {
  const k = `${productKey}::${sizeKey}`
  if (expandedSizes.value.has(k)) {
    expandedSizes.value.delete(k)
  } else {
    expandedSizes.value.add(k)
  }
  expandedSizes.value = new Set(expandedSizes.value)
}

function formatCurrency(n: number) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(n)
}

function stockClass(pct: number) {
  if (pct < 25) return 'text-red-600 font-semibold'
  if (pct < 50) return 'text-amber-600'
  return 'text-wtc-text-secondary'
}

const hasFilters = computed(() => !!(category.value || lowStock.value))
function clearFilters() {
  category.value = ''
  lowStock.value = false
}

// Label printing — via backend lpr (local only)
async function printLabel(inventoryId: string) {
  const input = prompt('How many labels?', '1')
  if (input === null) return
  const quantity = parseInt(input) || 1
  try {
    await $fetch('/api/wtc/labels/print', { method: 'POST', body: { inventoryId, quantity } })
  } catch (err: any) {
    if ((err as any).status === 503) {
      alert('Label printing is only available on the local server.')
    } else {
      alert('Print error: ' + err.message)
    }
  }
}
</script>


<template>
  <div class="max-w-6xl mx-auto px-4 py-8">

    <!-- Header -->
    <div class="mb-8 flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-black text-wtc-text-primary tracking-tight">Inventory</h1>
        <p class="text-sm text-wtc-text-secondary mt-1">Stock levels, values, and label printing</p>
      </div>
      <NuxtLink to="/inventory/add"
                class="flex items-center gap-2 px-4 py-2 rounded-xl bg-wtc-teal text-white text-sm font-semibold hover:bg-wtc-teal-dark transition-colors">
        <FaIcon :icon="['fas', 'plus']" />
        Add Item
      </NuxtLink>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
      <DashboardStatCard label="Total Items" :value="summary.totalItems" :icon="['fas', 'boxes']" accent="mid" />
      <DashboardStatCard label="Total Quantity" :value="summary.totalQuantity" :icon="['fas', 'boxes']" accent="mid" />
      <DashboardStatCard label="Cost Value" :value="formatCurrency(summary.totalCostValue)" :icon="['fas', 'money-bill-wave']" accent="mid" />
      <DashboardStatCard label="Retail Value" :value="formatCurrency(summary.totalRetailValue)" :icon="['fas', 'money-bill-wave']" accent="teal" />
      <DashboardStatCard label="Potential Profit" :value="formatCurrency(summary.potentialProfit)" :icon="['fas', 'arrow-trend-up']" accent="teal" />
    </div>

    <!-- Low Stock Alert -->
    <div v-if="lowStockItems.length > 0" class="mb-6 rounded-2xl border border-amber-200 bg-amber-50 p-4">
      <div class="flex items-start gap-3">
        <FaIcon :icon="['fas', 'triangle-exclamation']" class="text-amber-500 mt-0.5 shrink-0" />
        <div>
          <p class="text-sm font-bold text-amber-800">Low Stock Alert</p>
          <p class="text-xs text-amber-700 mb-2">{{ lowStockItems.length }} item{{ lowStockItems.length !== 1 ? 's' : '' }} running low — consider restocking soon.</p>
          <div class="flex flex-wrap gap-2">
            <span v-for="item in lowStockItems.slice(0, 5)" :key="item.name + item.size"
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800">
              {{ item.name }}{{ item.size ? ' ' + item.size : '' }} ({{ item.stock_percentage }}%)
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-2xl border border-wtc-border p-4 mb-6">
      <div class="flex flex-wrap gap-3 items-start">
        <div class="flex-1 min-w-[160px]">
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Category</label>
          <div class="relative">
            <select v-model="category"
                    class="appearance-none h-10 w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal">
              <option value="">All Categories</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.name">{{ cat.name }}</option>
            </select>
            <FaIcon :icon="['fas', 'chevron-down']" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-wtc-text-secondary" />
          </div>
        </div>
        <div class="flex flex-col justify-end self-end pb-1">
          <label class="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" v-model="lowStock" class="w-4 h-4 rounded accent-wtc-teal" />
            <span class="text-sm font-semibold text-wtc-text-primary">Low Stock Only</span>
          </label>
        </div>
        <button v-if="hasFilters" @click="clearFilters"
                class="self-end px-4 py-2 rounded-xl border border-wtc-border text-sm font-semibold text-wtc-text-secondary hover:bg-wtc-bg transition-colors">
          Clear
        </button>
      </div>
    </div>

    <!-- Inventory Table -->
    <div class="bg-white rounded-2xl border border-wtc-border overflow-hidden">
      <div class="px-6 py-4 border-b border-wtc-border flex items-center justify-between">
        <h2 class="font-bold text-wtc-text-primary">Inventory Items</h2>
        <span class="text-xs text-wtc-text-secondary">
          {{ pending ? 'Loading…' : `${grouped.length} product${grouped.length !== 1 ? 's' : ''}` }}
        </span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-wtc-bg border-b border-wtc-border">
          <tr>
            <th class="px-4 py-3 w-8"></th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Name</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Size</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider hidden md:table-cell">Category</th>
            <th class="px-4 py-3 text-right text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider hidden lg:table-cell">Cost</th>
            <th class="px-4 py-3 text-right text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider hidden lg:table-cell">Retail</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Stock</th>
            <th class="px-4 py-3 text-right text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Value</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Actions</th>
          </tr>
          </thead>
          <tbody class="divide-y divide-wtc-border">

          <tr v-if="grouped.length === 0">
            <td colspan="9" class="px-6 py-16 text-center text-wtc-text-secondary">No inventory items found</td>
          </tr>

          <template v-for="product in grouped" :key="product.key">

            <!-- PRODUCT ROW -->
            <tr @click="toggleProduct(product.key)"
                class="hover:bg-wtc-teal-light/40 transition-colors cursor-pointer bg-white">
              <td class="px-4 py-4">
                <FaIcon :icon="['fas', 'chevron-right']"
                        class="text-xs text-wtc-text-secondary transition-transform duration-200"
                        :class="expandedProducts.has(product.key) ? 'rotate-90' : ''" />
              </td>
              <td class="px-4 py-4">
                <p class="font-bold text-wtc-text-primary">{{ product.name }}</p>
                <p class="text-xs text-wtc-text-secondary">{{ product.full_name }}</p>
                <p v-if="product.product_id" class="text-xs text-wtc-text-secondary font-mono">{{ product.product_id.substring(0, 8) }}…</p>
              </td>
              <td class="px-4 py-4 text-xs text-wtc-text-secondary italic">
                {{ product.sizes.length > 1 ? `${product.sizes.length} sizes` : (product.sizes[0]?.sizeKey || '—') }}
              </td>
              <td class="px-4 py-4 text-wtc-text-secondary hidden md:table-cell">{{ product.category }}</td>
              <td class="px-4 py-4 text-right hidden lg:table-cell"><span class="text-xs text-wtc-text-secondary italic">varies</span></td>
              <td class="px-4 py-4 text-right hidden lg:table-cell"><span class="text-xs text-wtc-text-secondary italic">varies</span></td>
              <td class="px-4 py-4">
                  <span :class="stockClass(product.stockPct)">
                    {{ product.totalRemaining }} <span class="text-xs">({{ product.stockPct }}%)</span>
                  </span>
              </td>
              <td class="px-4 py-4 text-right font-semibold text-wtc-text-primary">{{ formatCurrency(product.totalRetail) }}</td>
              <td class="px-4 py-4"></td>
            </tr>

            <!-- SIZE ROWS -->
            <template v-if="expandedProducts.has(product.key)" v-for="size in product.sizes" :key="product.key + size.sizeKey">
              <tr @click="size.batches.length > 1 ? toggleSize(product.key, size.sizeKey) : null"
                  class="bg-wtc-bg border-b border-wtc-border transition-colors"
                  :class="size.batches.length > 1 ? 'hover:bg-wtc-teal-light/40 cursor-pointer' : ''">
                <td class="px-4 py-3 pl-8">
                  <FaIcon v-if="size.batches.length > 1" :icon="['fas', 'chevron-right']"
                          class="text-xs text-wtc-text-secondary transition-transform duration-200"
                          :class="expandedSizes.has(`${product.key}::${size.sizeKey}`) ? 'rotate-90' : ''" />
                </td>
                <td class="px-4 py-3">
                  <div class="pl-3 border-l-2 border-wtc-teal-mid">
                    <span class="text-xs text-wtc-text-secondary">{{ size.batches.length }} batch{{ size.batches.length !== 1 ? 'es' : '' }}</span>
                  </div>
                </td>
                <td class="px-4 py-3 font-bold text-wtc-text-primary">{{ size.sizeKey || '—' }}</td>
                <td class="px-4 py-3 text-wtc-text-secondary hidden md:table-cell">{{ product.category }}</td>
                <td class="px-4 py-3 text-right hidden lg:table-cell">
                  <span v-if="size.batches.length === 1" class="text-xs">{{ formatCurrency(size.batches[0].cost) }}</span>
                  <span v-else class="text-xs text-wtc-text-secondary italic">varies</span>
                </td>
                <td class="px-4 py-3 text-right hidden lg:table-cell">
                  <span v-if="size.batches.length === 1" class="text-xs">{{ formatCurrency(size.batches[0].retail) }}</span>
                  <span v-else class="text-xs text-wtc-text-secondary italic">varies</span>
                </td>
                <td class="px-4 py-3">
                    <span :class="stockClass(size.sPct)">
                      {{ size.sRemaining }} <span class="text-xs">({{ size.sPct }}%)</span>
                    </span>
                </td>
                <td class="px-4 py-3 text-right font-semibold text-wtc-text-primary">{{ formatCurrency(size.sRetail) }}</td>
                <td class="px-4 py-3" @click.stop>
                  <div v-if="size.batches.length === 1" class="flex items-center gap-2">
                    <NuxtLink :to="`/inventory/${size.batches[0].id}/edit`"
                              class="text-wtc-teal hover:text-wtc-teal-dark transition-colors">
                      <FaIcon :icon="['fas', 'pencil']" />
                    </NuxtLink>
                    <button @click="printLabel(size.batches[0].id)"
                            class="text-wtc-teal hover:text-wtc-teal-dark transition-colors"
                            title="Print Label">
                      <FaIcon :icon="['fas', 'tag']" />
                    </button>
                  </div>
                </td>
              </tr>

              <!-- BATCH ROWS -->
              <template v-if="expandedSizes.has(`${product.key}::${size.sizeKey}`)">
                <tr v-for="(batch, idx) in size.batches" :key="batch.id"
                    class="bg-wtc-teal-light/20 border-b border-wtc-border">
                  <td class="px-4 py-3"></td>
                  <td class="px-4 py-3">
                    <div class="pl-8 border-l-2 border-wtc-teal-mid">
                      <p class="text-xs font-semibold text-wtc-teal uppercase tracking-wide">Batch {{ idx + 1 }}</p>
                      <p class="text-xs text-wtc-text-secondary">
                        {{ new Date(batch.purchased_on).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) }}
                      </p>
                    </div>
                  </td>
                  <td class="px-4 py-3 font-bold text-wtc-text-primary">{{ batch.size || '—' }}</td>
                  <td class="px-4 py-3 text-wtc-text-secondary hidden md:table-cell">{{ batch.category }}</td>
                  <td class="px-4 py-3 text-right text-xs hidden lg:table-cell">{{ formatCurrency(batch.cost) }}</td>
                  <td class="px-4 py-3 text-right text-xs hidden lg:table-cell">{{ formatCurrency(batch.retail) }}</td>
                  <td class="px-4 py-3">
                      <span :class="stockClass(batch.stock_percentage)">
                        {{ batch.remaining }} <span class="text-xs">({{ batch.stock_percentage }}%)</span>
                      </span>
                  </td>
                  <td class="px-4 py-3 text-right font-semibold text-wtc-text-primary">{{ formatCurrency(batch.total_retail) }}</td>
                  <td class="px-4 py-3">
                    <div class="flex items-center gap-2">
                      <NuxtLink :to="`/inventory/${batch.id}/edit`"
                                class="text-wtc-teal hover:text-wtc-teal-dark transition-colors">
                        <FaIcon :icon="['fas', 'pencil']" />
                      </NuxtLink>
                      <button @click="printLabel(batch.id)"
                              class="text-wtc-teal hover:text-wtc-teal-dark transition-colors"
                              title="Print Label">
                        <FaIcon :icon="['fas', 'tag']" />
                      </button>
                    </div>
                  </td>
                </tr>
              </template>

            </template>

          </template>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</template>