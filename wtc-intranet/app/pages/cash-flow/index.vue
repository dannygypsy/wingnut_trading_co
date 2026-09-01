<script setup lang="ts">
useHead({ title: 'Cash Flow' })
const startDate = ref('')
const endDate = ref('')
const typeFilter = ref('')

const { data, pending } = useFetch('/api/cash-flow', {
  query: computed(() => ({
    ...(startDate.value && { startDate: startDate.value }),
    ...(endDate.value && { endDate: endDate.value }),
    ...(typeFilter.value && { type: typeFilter.value })
  }))
})

const summary = computed(() => data.value?.summary ?? {
  totalIncome: 0, totalExpenses: 0, netCashFlow: 0, transactionCount: 0
})
const transactions = computed(() => data.value?.transactions ?? [])
const hasFilters = computed(() => !!(startDate.value || endDate.value || typeFilter.value))

function clearFilters() {
  startDate.value = ''
  endDate.value = ''
  typeFilter.value = ''
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function formatCurrency(amount: number) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 py-8">

    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-3xl font-black text-wtc-text-primary tracking-tight">Cash Flow</h1>
        <p class="text-sm text-wtc-text-secondary mt-1">Track all money in and out of the business</p>
      </div>
      <NuxtLink
          to="/cash-flow/add"
          class="flex items-center gap-2 bg-wtc-teal hover:bg-wtc-teal-dark text-white font-semibold px-4 py-2.5 rounded-xl transition-colors text-sm"
      >
        <FaIcon :icon="['fas', 'plus']" />
        Add Transaction
      </NuxtLink>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      <DashboardStatCard
          label="Total Income"
          :value="formatCurrency(summary.totalIncome)"
          :icon="['fas', 'arrow-trend-up']"
          accent="teal"
      />
      <DashboardStatCard
          label="Total Expenses"
          :value="formatCurrency(summary.totalExpenses)"
          :icon="['fas', 'arrow-trend-down']"
          accent="danger"
      />
      <DashboardStatCard
          :label="summary.netCashFlow >= 0 ? 'Net Profit' : 'Net Loss'"
          :value="(summary.netCashFlow >= 0 ? '+' : '') + formatCurrency(summary.netCashFlow)"
          :icon="['fas', 'scale-balanced']"
          :accent="summary.netCashFlow >= 0 ? 'teal' : 'danger'"
      />
      <DashboardStatCard
          label="Transactions"
          :value="summary.transactionCount"
          :icon="['fas', 'receipt']"
          accent="mid"
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
        <div class="flex-1 min-w-[130px]">
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Type</label>
          <select
              v-model="typeFilter"
              class="w-full h-11.5 appearance-none rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
          >
            <option value="">All Types</option>
            <option value="income">Income</option>
            <option value="expense">Expense</option>
          </select>
        </div>
        <button
            v-if="hasFilters"
            @click="clearFilters"
            class="self-center px-4 py-2 rounded-xl border border-wtc-border text-sm font-semibold text-wtc-text-secondary hover:bg-wtc-bg transition-colors"
        >
          Clear
        </button>
      </div>
    </div>

    <!-- Transactions Table -->
    <div class="bg-white rounded-2xl border border-wtc-border overflow-hidden">
      <div class="px-6 py-4 border-b border-wtc-border flex items-center justify-between">
        <h2 class="font-bold text-wtc-text-primary">Transactions</h2>
        <span class="text-xs text-wtc-text-secondary">
          {{ pending ? 'Loading...' : `${transactions.length} result${transactions.length !== 1 ? 's' : ''}` }}
        </span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-wtc-bg border-b border-wtc-border">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Date</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Type</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Category</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Description</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider hidden md:table-cell">Vendor</th>
            <th class="px-6 py-3 text-right text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Amount</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider hidden lg:table-cell">Payment</th>
            <th class="px-6 py-3"></th>
          </tr>
          </thead>
          <tbody class="divide-y divide-wtc-border">
          <tr v-if="transactions.length === 0">
            <td colspan="8" class="px-6 py-16 text-center text-wtc-text-secondary">
              No transactions found
            </td>
          </tr>
          <tr
              v-for="txn in transactions"
              :key="txn.id"
              class="hover:bg-wtc-teal-light/40 transition-colors"
          >
            <td class="px-6 py-4 text-wtc-text-secondary whitespace-nowrap">{{ formatDate(txn.transaction_date) }}</td>
            <td class="px-6 py-4">
                <span
                    class="px-2.5 py-1 rounded-full text-xs font-semibold"
                    :class="txn.type === 'income' ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'"
                >
                  {{ txn.type }}
                </span>
            </td>
            <td class="px-6 py-4 text-wtc-text-primary font-medium">{{ txn.category }}</td>
            <td class="px-6 py-4 text-wtc-text-primary max-w-[200px] truncate">{{ txn.description }}</td>
            <td class="px-6 py-4 text-wtc-text-secondary hidden md:table-cell">{{ txn.vendor || '—' }}</td>
            <td
                class="px-6 py-4 text-right font-bold whitespace-nowrap"
                :class="txn.type === 'income' ? 'text-emerald-600' : 'text-red-600'"
            >
              {{ txn.type === 'income' ? '+' : '-' }}{{ formatCurrency(txn.amount) }}
            </td>
            <td class="px-6 py-4 text-wtc-text-secondary hidden lg:table-cell">{{ txn.payment_method || '—' }}</td>
            <td class="px-6 py-4">
              <NuxtLink
                  :to="`/cash-flow/${txn.id}/edit`"
                  class="text-wtc-teal hover:text-wtc-teal-dark transition-colors"
              >
                <FaIcon :icon="['fas', 'pencil']" />
              </NuxtLink>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>