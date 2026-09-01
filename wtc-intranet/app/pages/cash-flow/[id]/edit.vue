<script setup lang="ts">
useHead({ title: 'Edit Cash Flow' })
const route = useRoute()
const router = useRouter()
const id = route.params.id as string

interface CashFlowEntry {
  id: string
  transaction_date: string
  type: string
  category: string
  description: string
  amount: number
  payment_method: string | null
  vendor: string | null
  notes: string | null
  created_by: string
}

const { data, error: fetchError } = await useFetch<CashFlowEntry>(`/api/cash-flow/${id}`)

const form = reactive({
  transaction_date: '',
  type: 'expense',
  category: '',
  description: '',
  amount: '',
  payment_method: '',
  vendor: '',
  notes: ''
})

watch(data, (val) => {
  if (!val) return
  form.transaction_date = val.transaction_date
  form.type = val.type
  form.category = val.category
  form.description = val.description
  form.amount = String(val.amount)
  form.payment_method = val.payment_method ?? ''
  form.vendor = val.vendor ?? ''
  form.notes = val.notes ?? ''
}, { immediate: true })

const incomeCategories = ['sales', 'other_income', 'refund', 'other']
const expenseCategories = ['inventory', 'equipment', 'capex', 'operating_expense', 'supplies', 'marketing', 'fees', 'other']
const categories = computed(() => form.type === 'income' ? incomeCategories : expenseCategories)
watch(() => form.type, () => { form.category = '' })

const saving = ref(false)
const deleting = ref(false)
const confirmDelete = ref(false)
const error = ref('')

async function submit() {
  if (!form.transaction_date || !form.type || !form.category || !form.description || !form.amount) {
    error.value = 'Please fill in all required fields.'
    return
  }
  saving.value = true
  error.value = ''
  try {
    await $fetch(`/api/cash-flow/${id}`, { method: 'PUT', body: form })
    router.push('/cash-flow')
  } catch (e: any) {
    error.value = e?.data?.message ?? 'Something went wrong.'
    saving.value = false
  }
}

async function remove() {
  deleting.value = true
  try {
    await $fetch(`/api/cash-flow/${id}`, { method: 'DELETE' })
    router.push('/cash-flow')
  } catch (e: any) {
    error.value = e?.data?.message ?? 'Could not delete transaction.'
    deleting.value = false
    confirmDelete.value = false
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
        <h1 class="text-3xl font-black text-wtc-text-primary tracking-tight">Edit Transaction</h1>
        <p class="text-sm text-wtc-text-secondary mt-1">Update or remove this entry</p>
      </div>
    </div>

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
          <div class="relative">
            <select
                v-model="form.type"
                class="h-10 w-full appearance-none rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal pr-8"
            >
              <option value="income">Income</option>
              <option value="expense">Expense</option>
            </select>
            <FaIcon :icon="['fas', 'chevron-down']" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-wtc-text-secondary" />
          </div>
        </div>
      </div>

      <!-- Category + Amount -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider mb-1.5">Category <span class="text-red-500">*</span></label>
          <div class="relative">
            <select
                v-model="form.category"
                class="h-10 w-full appearance-none rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal pr-8"
            >
              <option value="" disabled>Select category</option>
              <option v-for="cat in categories" :key="cat" :value="cat">
                {{ cat.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()) }}
              </option>
            </select>
            <FaIcon :icon="['fas', 'chevron-down']" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-wtc-text-secondary" />
          </div>
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
            class="w-full rounded-xl border border-wtc-border bg-wtc-bg px-3 py-2.5 text-sm text-wtc-text-primary focus:outline-none focus:ring-2 focus:ring-wtc-teal"
        />
      </div>

      <!-- Vendor + Payment -->
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
          {{ saving ? 'Saving...' : 'Save Changes' }}
        </button>
        <NuxtLink
            to="/cash-flow"
            class="px-5 py-2.5 rounded-xl border border-wtc-border text-sm font-semibold text-wtc-text-secondary hover:bg-wtc-bg transition-colors"
        >
          Cancel
        </NuxtLink>
      </div>

      <!-- Delete -->
      <div class="border-t border-wtc-border pt-5">
        <div v-if="!confirmDelete">
          <button
              @click="confirmDelete = true"
              class="text-sm text-red-500 hover:text-red-700 font-semibold transition-colors"
          >
            <FaIcon :icon="['fas', 'trash']" class="mr-1.5" />
            Delete Transaction
          </button>
        </div>
        <div v-else class="flex items-center gap-3">
          <p class="text-sm text-wtc-text-secondary flex-1">Are you sure? This can't be undone.</p>
          <button
              @click="remove"
              :disabled="deleting"
              class="px-4 py-2 bg-red-500 hover:bg-red-600 disabled:opacity-50 text-white text-sm font-semibold rounded-xl transition-colors"
          >
            {{ deleting ? 'Deleting...' : 'Yes, Delete' }}
          </button>
          <button
              @click="confirmDelete = false"
              class="px-4 py-2 border border-wtc-border text-sm font-semibold text-wtc-text-secondary rounded-xl hover:bg-wtc-bg transition-colors"
          >
            Cancel
          </button>
        </div>
      </div>

    </div>
  </div>
</template>