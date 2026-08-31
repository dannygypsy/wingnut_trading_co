<script setup lang="ts">
const router = useRouter()

const form = reactive({
  transaction_date: new Date().toISOString().split('T')[0],
  type: 'expense',
  category: '',
  description: '',
  amount: '',
  payment_method: '',
  vendor: '',
  notes: ''
})

const incomeCategories = ['sales', 'other_income', 'refund', 'other']
const expenseCategories = ['inventory', 'equipment', 'capex', 'operating_expense', 'supplies', 'marketing', 'fees', 'other']

const categories = computed(() => form.type === 'income' ? incomeCategories : expenseCategories)

watch(() => form.type, () => { form.category = '' })

const saving = ref(false)
const error = ref('')

async function submit() {
  if (!form.transaction_date || !form.type || !form.category || !form.description || !form.amount) {
    error.value = 'Please fill in all required fields.'
    return
  }

  saving.value = true
  error.value = ''

  try {
    await $fetch('/api/cash-flow', { method: 'POST', body: form })
    router.push('/cash-flow')
  } catch (e: any) {
    error.value = e?.data?.message ?? 'Something went wrong.'
    saving.value = false
  }
}
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 py-8">

    <!-- Header -->
    <div class="flex items-center gap-4 mb-8">
      <NuxtLink to="/cash-flow" class="text-wtc-text-secondary hover:text-wtc-teal transition-colors">
        <FaIcon :icon="['fas', 'chevron-left']" />
      </NuxtLink>
      <div>
        <h1 class="text-3xl font-black text-wtc-text-primary tracking-tight">Add Transaction</h1>
        <p class="text-sm text-wtc-text-secondary mt-1">Record a new income or expense</p>
      </div>
    </div>

    <!-- Form -->
    <div class="bg-white rounded-2xl border border-wtc-border p-6 space-y-5">

      <!-- Error -->
      <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl px-4 py-3">
        {{ error }}
      </div>

      <!-- Date + Type -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Date <span class="text-red-500">*</span></label>
          <input
              v-model="form.transaction_date"
              type="date"
              class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
          />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Type <span class="text-red-500">*</span></label>
          <select
              v-model="form.type"
              class="w-full h-11.5 appearance-none rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
          >
            <option value="income">Income</option>
            <option value="expense">Expense</option>
          </select>
        </div>
      </div>

      <!-- Category + Amount -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Category <span class="text-red-500">*</span></label>
          <select
              v-model="form.category"
              class="w-full h-11.5 appearance-none rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
          >
            <option value="" disabled>Select category</option>
            <option v-for="cat in categories" :key="cat" :value="cat">
              {{ cat.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()) }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Amount <span class="text-red-500">*</span></label>
          <div class="relative">
            <span class="absolute left-3 top-1/2 -translate-y-1/2 text-wtc-text-secondary text-sm font-semibold">$</span>
            <input
                v-model="form.amount"
                type="number"
                step="0.01"
                min="0"
                placeholder="0.00"
                class="w-full rounded-xl border border-wtc-border bg-wtc-bg pl-7 pr-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
            />
          </div>
        </div>
      </div>

      <!-- Description -->
      <div>
        <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Description <span class="text-red-500">*</span></label>
        <input
            v-model="form.description"
            type="text"
            placeholder="What was this transaction for?"
            class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
        />
      </div>

      <!-- Vendor + Payment Method -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Vendor</label>
          <input
              v-model="form.vendor"
              type="text"
              placeholder="Optional"
              class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
          />
        </div>
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Payment Method</label>
          <input
              v-model="form.payment_method"
              type="text"
              placeholder="Cash, card, etc."
              class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
          />
        </div>
      </div>

      <!-- Notes -->
      <div>
        <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Notes</label>
        <textarea
            v-model="form.notes"
            rows="3"
            placeholder="Any additional details..."
            class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal resize-none"
        />
      </div>

      <!-- Actions -->
      <div class="flex gap-3 pt-2">
        <button
            @click="submit"
            :disabled="saving"
            class="flex-1 bg-wtc-teal hover:bg-wtc-teal-dark disabled:opacity-50 text-white font-semibold py-2.5 rounded-xl transition-colors text-sm"
        >
          {{ saving ? 'Saving...' : 'Save Transaction' }}
        </button>
        <NuxtLink
            to="/cash-flow"
            class="px-5 py-2.5 rounded-xl border border-wtc-border text-sm font-semibold text-wtc-text-secondary hover:bg-wtc-bg transition-colors"
        >
          Cancel
        </NuxtLink>
      </div>

    </div>
  </div>
</template>