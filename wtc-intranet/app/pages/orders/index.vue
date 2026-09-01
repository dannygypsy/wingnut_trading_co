<script setup lang="ts">
useHead({ title: 'Orders' })
const startDate = ref('')
const endDate = ref('')
const search = ref('')
const statusOverrides = reactive<Record<string, string>>({}) // For changing status color

const { data, pending } = useFetch('/api/orders', {
  query: computed(() => ({
    ...(startDate.value && { startDate: startDate.value }),
    ...(endDate.value && { endDate: endDate.value }),
    ...(search.value && { search: search.value })
  }))
})

const summary = computed(() => data.value?.summary ?? { totalOrders: 0, grossRevenue: 0, netProfit: 0 })
const orders = computed(() => data.value?.orders ?? [])
const hasFilters = computed(() => !!(startDate.value || endDate.value || search.value))

function clearFilters() {
  startDate.value = ''
  endDate.value = ''
  search.value = ''
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function formatCurrency(amount: number) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const statusSelectColors: Record<string, string> = {
  pending: 'bg-amber-100 text-amber-700',
  completed: 'bg-emerald-100 text-emerald-700',
  delivered: 'bg-blue-100 text-blue-700',
  canceled: 'bg-red-100 text-red-700',
}

async function updateStatus(order: any, newStatus: string) {
  const prev = statusOverrides[order.id] ?? order.status
  statusOverrides[order.id] = newStatus
  try {
    await $fetch(`/api/orders/${order.id}/status`, { method: 'PATCH', body: { status: newStatus } })
  } catch {
    statusOverrides[order.id] = prev
  }
}
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 py-8">

    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-black text-wtc-text-primary tracking-tight">Orders</h1>
      <p class="text-sm text-wtc-text-secondary mt-1">Sales performance and order management</p>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
      <DashboardStatCard
          label="Total Orders"
          :value="summary.totalOrders"
          :icon="['fas', 'shopping-cart']"
          accent="mid"
      />
      <DashboardStatCard
          label="Gross Revenue"
          :value="formatCurrency(summary.grossRevenue)"
          :icon="['fas', 'money-bill-wave']"
          accent="teal"
      />
      <DashboardStatCard
          label="Net Profit"
          :value="formatCurrency(summary.netProfit)"
          :icon="['fas', 'arrow-trend-up']"
          :accent="summary.netProfit >= 0 ? 'teal' : 'danger'"
      />
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-2xl border border-wtc-border p-4 mb-6">
      <div class="flex flex-wrap gap-3 items-start">
        <div class="flex-1 min-w-[130px]">
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Start Date</label>
          <input
              v-model="startDate"
              type="date"
              class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
          />
        </div>
        <div class="flex-1 min-w-[130px]">
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">End Date</label>
          <input
              v-model="endDate"
              type="date"
              class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
          />
        </div>
        <div class="flex-1 min-w-[200px]">
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Search by Decal</label>
          <div class="relative">
            <FaIcon :icon="['fas', 'magnifying-glass']" class="absolute left-3 top-1/2 -translate-y-1/2 text-xs text-wtc-text-secondary" />
            <input
                v-model="search"
                type="text"
                placeholder="Decal name..."
                class="w-full rounded-xl border border-wtc-border bg-wtc-bg pl-8 pr-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
            />
          </div>
        </div>
        <button
            v-if="hasFilters"
            @click="clearFilters"
            class="self-end px-4 py-2 rounded-xl border border-wtc-border text-sm font-semibold text-wtc-text-secondary hover:bg-wtc-bg transition-colors"
        >
          Clear
        </button>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="bg-white rounded-2xl border border-wtc-border overflow-hidden">
      <div class="px-6 py-4 border-b border-wtc-border flex items-center justify-between">
        <h2 class="font-bold text-wtc-text-primary">Orders</h2>
        <span class="text-xs text-wtc-text-secondary">
          {{ pending ? 'Loading...' : `${orders.length} result${orders.length !== 1 ? 's' : ''}` }}
        </span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-wtc-bg border-b border-wtc-border">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Order</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Customer</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider hidden md:table-cell">Date</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider hidden lg:table-cell">Items</th>
            <th class="px-6 py-3 text-right text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Total</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Status</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider hidden lg:table-cell">Payment</th>
          </tr>
          </thead>
          <tbody class="divide-y divide-wtc-border">
          <tr v-if="orders.length === 0">
            <td colspan="8" class="px-6 py-16 text-center text-wtc-text-secondary">No orders found</td>
          </tr>
          <tr
              v-for="order in orders"
              :key="order.id"
              class="hover:bg-wtc-teal-light/40 transition-colors cursor-pointer"
              @click="navigateTo(`/orders/${order.id}`)"
          >
            <td class="px-6 py-4 font-mono text-xs text-wtc-text-secondary">{{ order.id.substring(0, 8) }}…</td>
            <td class="px-6 py-4 font-medium text-wtc-text-primary">{{ order.customer || '—' }}</td>
            <td class="px-6 py-4 text-wtc-text-secondary hidden md:table-cell whitespace-nowrap">{{ formatDate(order.created_at) }}</td>
            <td class="px-6 py-4 text-wtc-text-secondary hidden lg:table-cell text-xs">
              {{ order.item_count }} item{{ order.item_count !== 1 ? 's' : '' }},
              {{ order.customization_count }} decal{{ order.customization_count !== 1 ? 's' : '' }}
            </td>
            <td class="px-6 py-4 text-right font-bold text-wtc-text-primary whitespace-nowrap">{{ formatCurrency(order.total) }}</td>
            <td class="px-6 py-4">
              <div class="relative inline-block">
                <select
                    :value="statusOverrides[order.id] ?? order.status"
                    @change="updateStatus(order, ($event.target as HTMLSelectElement).value)"
                    :class="statusSelectColors[statusOverrides[order.id] ?? order.status]"
                    class="appearance-none pl-3 pr-6 py-1 rounded-full text-xs font-semibold border-0 cursor-pointer focus:outline-none focus:ring-2 focus:ring-wtc-teal"
                >
                  <option value="pending">pending</option>
                  <option value="completed">completed</option>
                  <option value="delivered">delivered</option>
                  <option value="canceled">canceled</option>
                </select>
                <FaIcon :icon="['fas', 'chevron-down']" class="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 text-[9px]" />
              </div>
            </td>
            <td class="px-6 py-4 text-wtc-text-secondary hidden lg:table-cell">{{ order.payment_method || '—' }}</td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>