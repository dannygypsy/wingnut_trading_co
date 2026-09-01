<script setup lang="ts">
useHead({ title: 'Dashboard' })

const { data: dashboard, pending } = await useFetch('/api/dashboard')

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return 'Good morning'
  if (hour < 17) return 'Good afternoon'
  return 'Good evening'
})

const formatCurrency = (val: number) =>
    Number(val || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })

const formatDate = (date: string) =>
    new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' })
</script>

<template>

  <main class="max-w-7xl mx-auto px-4 sm:px-6 py-8">

    <!-- Loading -->
    <div v-if="pending" class="flex items-center justify-center py-24">
      <div class="w-8 h-8 border-4 border-wtc-teal-light border-t-wtc-teal rounded-full animate-spin" />
    </div>

    <div v-else class="space-y-8">

      <!-- Stat Cards -->
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <DashboardStatCard
            label="Revenue This Week"
            :value="'$' + formatCurrency(dashboard?.weeklyRevenue ?? 0)"
            :icon="['fas', 'money-bill-wave']"
            accent="teal"
        />
        <DashboardStatCard
            label="Orders This Week"
            :value="dashboard?.weeklyOrderCount ?? 0"
            :icon="['fas', 'shopping-cart']"
            accent="mid"
        />
        <DashboardStatCard
            label="Items In Stock"
            :value="(dashboard?.totalInventoryRemaining ?? 0).toLocaleString()"
            :icon="['fas', 'boxes']"
            accent="dark"
        />
        <DashboardStatCard
            label="Low Stock Alerts"
            :value="dashboard?.lowStockCount ?? 0"
            :icon="['fas', 'triangle-exclamation']"
            :accent="(dashboard?.lowStockCount ?? 0) > 0 ? 'warning' : 'dark'"
        />
      </div>

      <!-- Sections + Recent Orders -->
      <div class="grid grid-cols-1 lg:grid-cols-5 gap-6">

        <!-- Section Navigation -->
        <div class="lg:col-span-2 space-y-4">
          <h2 class="text-xs font-bold uppercase tracking-widest text-wtc-text-secondary">Sections</h2>
          <DashboardSectionCard
              title="Cash Flow"
              description="Track income and expenses"
              :icon="['fas', 'money-bill-wave']"
              to="/cash-flow"
          />
          <DashboardSectionCard
              title="Orders"
              description="Manage customer orders"
              :icon="['fas', 'shopping-cart']"
              to="/orders"
          />
          <DashboardSectionCard
              title="Inventory"
              description="View and manage stock"
              :icon="['fas', 'boxes']"
              to="/inventory"
          />
        </div>

        <!-- Recent Orders -->
        <div class="lg:col-span-3">
          <h2 class="text-xs font-bold uppercase tracking-widest text-wtc-text-secondary mb-4">Recent Orders</h2>
          <div class="bg-white rounded-2xl border border-wtc-border overflow-hidden">
            <template v-if="dashboard?.recentOrders?.length">
              <NuxtLink
                  v-for="order in dashboard.recentOrders"
                  :key="order.id"
                  :to="`/orders/order/${order.id}`"
                  class="flex items-center justify-between px-5 py-4 hover:bg-wtc-bg transition-colors border-b border-wtc-border last:border-b-0"
              >
                <div>
                  <p class="text-sm font-semibold text-wtc-text-primary">
                    {{ order.customer || 'Walk-in' }}
                  </p>
                  <p class="text-xs text-wtc-text-secondary mt-0.5">
                    {{ formatDate(order.created_at) }} · {{ order._count.items }} item{{ order._count.items !== 1 ? 's' : '' }}
                  </p>
                </div>
                <div class="flex items-center gap-3">
                  <span class="text-sm font-bold text-wtc-text-primary">${{ formatCurrency(order.total) }}</span>
                  <DashboardStatusBadge :status="order.status" />
                </div>
              </NuxtLink>
            </template>
            <div v-else class="py-16 text-center text-sm text-wtc-text-secondary">
              No recent orders
            </div>
            <div class="px-5 py-3 border-t border-wtc-border">
              <NuxtLink to="/orders" class="text-sm font-bold text-wtc-teal hover:text-wtc-teal-dark transition-colors">
                View all orders →
              </NuxtLink>
            </div>
          </div>
        </div>

      </div>
    </div>
  </main>
</template>