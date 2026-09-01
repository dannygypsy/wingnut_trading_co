<script setup lang="ts">
useHead({ title: 'Order Details' })
const route = useRoute()
const id = route.params.id as string

const confirmDelete = ref(false)
const deleting = ref(false)

interface Customization {
  id: string
  name: string
  retail: number
  cost: number
  customization_profit: number
}

interface OrderItem {
  id: string
  name: string
  quantity: number
  retail: number
  cost: number
  item_profit: number
  category: string | null
  type: string | null
  size: string | null
  customizations: Customization[]
}

interface OrderDetail {
  id: string
  customer: string | null
  created_at: string
  total: number
  status: string
  payment_method: string | null
  discount_desc: string | null
  discount_percent: number | null
  totalProfit: number
  items: OrderItem[]
}

const { data: order } = await useFetch<OrderDetail>(`/api/orders/${id}`)

function formatCurrency(amount: number) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric',
    hour: 'numeric', minute: '2-digit'
  })
}

const statusColors: Record<string, string> = {
  pending: 'bg-amber-100 text-amber-700',
  completed: 'bg-emerald-100 text-emerald-700',
  delivered: 'bg-blue-100 text-blue-700',
  canceled: 'bg-red-100 text-red-700',
}

const margin = computed(() => {
  if (!order.value || order.value.total === 0) return '0'
  return ((order.value.totalProfit / order.value.total) * 100).toFixed(1)
})

async function deleteOrder() {
  deleting.value = true
  try {
    await $fetch(`/api/orders/${route.params.id}`, { method: 'DELETE' })
    navigateTo('/orders')
  } catch {
    deleting.value = false
    confirmDelete.value = false
  }
}
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 py-8" v-if="order">

    <!-- Header -->
    <div class="flex items-center gap-4 mb-8">
      <NuxtLink to="/orders" class="text-wtc-text-secondary hover:text-wtc-teal transition-colors">
        <FaIcon :icon="['fas', 'chevron-left']" />
      </NuxtLink>
      <div class="flex-1">
        <div class="flex items-center gap-3">
          <h1 class="text-3xl font-black text-wtc-text-primary tracking-tight">Order Details</h1>
          <span :class="statusColors[order.status]" class="px-3 py-1 rounded-full text-xs font-semibold">
            {{ order.status }}
          </span>
        </div>
        <p class="text-sm text-wtc-text-secondary mt-1 font-mono">{{ order.id }}</p>
      </div>
      <p class="text-sm text-wtc-text-secondary hidden md:block">{{ formatDate(order.created_at) }}</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

      <!-- Items (left, 2 cols) -->
      <div class="lg:col-span-2 space-y-4">
        <div class="bg-white rounded-2xl border border-wtc-border overflow-hidden">
          <div class="px-6 py-4 border-b border-wtc-border">
            <h2 class="font-bold text-wtc-text-primary">Order Items</h2>
          </div>

          <div class="divide-y divide-wtc-border">
            <div v-for="item in order.items" :key="item.id">

              <!-- Item row -->
              <div class="flex justify-between items-start px-6 py-4 bg-wtc-bg/50">
                <div>
                  <p class="font-semibold text-wtc-text-primary">{{ item.name }}</p>
                  <p class="text-xs text-wtc-text-secondary mt-0.5">
                    <span v-if="item.category">{{ item.category }}</span>
                    <span v-if="item.type"> · {{ item.type }}</span>
                    <span v-if="item.size"> · {{ item.size }}</span>
                    · Qty: {{ item.quantity }}
                  </p>
                </div>
                <div class="text-right shrink-0 ml-4">
                  <p class="font-bold text-wtc-text-primary">{{ formatCurrency(item.retail * item.quantity) }}</p>
                  <p class="text-xs text-wtc-text-secondary">Cost: {{ formatCurrency(item.cost * item.quantity) }}</p>
                  <p class="text-xs font-semibold text-emerald-600">Profit: {{ formatCurrency(item.item_profit) }}</p>
                </div>
              </div>

              <!-- Customizations -->
              <div v-if="item.customizations.length > 0" class="divide-y divide-wtc-border/50">
                <div
                    v-for="c in item.customizations"
                    :key="c.id"
                    class="flex justify-between items-start pl-10 pr-6 py-3"
                >
                  <div class="flex items-start gap-2">
                    <div class="w-1.5 h-1.5 rounded-full bg-wtc-teal mt-1.5 shrink-0"></div>
                    <p class="text-sm text-wtc-text-primary">{{ c.name }}</p>
                  </div>
                  <div class="text-right shrink-0 ml-4">
                    <p class="text-sm font-semibold text-wtc-text-primary">{{ formatCurrency(c.retail) }}</p>
                    <p class="text-xs text-wtc-text-secondary">Cost: {{ formatCurrency(c.cost) }}</p>
                    <p class="text-xs font-semibold text-emerald-600">Profit: {{ formatCurrency(c.customization_profit) }}</p>
                  </div>
                </div>
              </div>
              <div v-else class="pl-10 pr-6 py-3">
                <p class="text-xs text-wtc-text-secondary italic">No decals</p>
              </div>

            </div>
          </div>
        </div>
      </div>

      <!-- Sidebar (right, 1 col) -->
      <div class="space-y-4">

        <!-- Customer -->
        <div class="bg-white rounded-2xl border border-wtc-border p-5">
          <h3 class="font-bold text-wtc-text-primary mb-4">Customer</h3>
          <div class="space-y-3">
            <div>
              <p class="text-xs text-wtc-text-secondary uppercase tracking-wider font-semibold">Name</p>
              <p class="text-wtc-text-primary font-medium mt-0.5">{{ order.customer || '—' }}</p>
            </div>
            <div>
              <p class="text-xs text-wtc-text-secondary uppercase tracking-wider font-semibold">Date</p>
              <p class="text-wtc-text-primary mt-0.5">{{ formatDate(order.created_at) }}</p>
            </div>
          </div>
        </div>

        <!-- Payment -->
        <div class="bg-white rounded-2xl border border-wtc-border p-5">
          <h3 class="font-bold text-wtc-text-primary mb-4">Payment</h3>
          <div class="space-y-3">
            <div class="flex justify-between">
              <span class="text-wtc-text-secondary text-sm">Method</span>
              <span class="font-medium text-wtc-text-primary text-sm">{{ order.payment_method || '—' }}</span>
            </div>
            <div v-if="order.discount_desc" class="flex justify-between border-t border-wtc-border pt-3">
              <span class="text-wtc-text-secondary text-sm">{{ order.discount_desc }}</span>
              <span class="text-red-500 font-semibold text-sm">-{{ order.discount_percent }}%</span>
            </div>
          </div>
        </div>

        <!-- Financial Summary -->
        <div class="bg-wtc-teal-light rounded-2xl border border-wtc-border p-5">
          <h3 class="font-bold text-wtc-text-primary mb-4">Financial Summary</h3>
          <div class="space-y-3">
            <div class="flex justify-between">
              <span class="text-wtc-text-secondary text-sm">Total Revenue</span>
              <span class="font-bold text-wtc-text-primary">{{ formatCurrency(order.total) }}</span>
            </div>
            <div class="flex justify-between border-t border-wtc-border pt-3">
              <span class="text-wtc-text-secondary text-sm">Net Profit</span>
              <span class="font-bold text-emerald-600">{{ formatCurrency(order.totalProfit) }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-wtc-text-secondary text-sm">Margin</span>
              <span class="font-semibold text-wtc-text-primary">{{ margin }}%</span>
            </div>
          </div>
        </div>

      </div>
    </div>
    <!-- Danger Zone -->
    <div class="mt-8 rounded-2xl border border-red-200 bg-red-50 p-5">
      <p class="text-sm font-bold text-red-700 mb-1">Danger Zone</p>
      <p class="text-xs text-red-500 mb-4">Permanently deletes this order and all its items. There is no undo.</p>

      <div v-if="!confirmDelete">
        <button
            @click="confirmDelete = true"
            class="px-4 py-2 rounded-xl bg-white border border-red-300 text-red-600 text-sm font-semibold hover:bg-red-100 transition-colors"
        >
          Delete This Order
        </button>
      </div>

      <div v-else class="flex items-center gap-3">
        <p class="text-sm font-semibold text-red-700">Are you absolutely sure? This cannot be undone.</p>
        <button
            @click="deleteOrder"
            :disabled="deleting"
            class="px-4 py-2 rounded-xl bg-red-600 text-white text-sm font-semibold hover:bg-red-700 disabled:opacity-50 transition-colors"
        >
          {{ deleting ? 'Deleting…' : 'Yes, Delete It' }}
        </button>
        <button
            @click="confirmDelete = false"
            class="px-4 py-2 rounded-xl border border-wtc-border text-sm font-semibold text-wtc-text-secondary hover:bg-white transition-colors"
        >
          Cancel
        </button>
      </div>
    </div>
  </div>
</template>