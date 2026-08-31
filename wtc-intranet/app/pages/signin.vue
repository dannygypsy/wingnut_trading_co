<script setup lang="ts">
definePageMeta({ layout: false })

const username = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function signIn() {
  error.value = ''
  loading.value = true
  try {
    await $fetch('/api/auth/signin', {
      method: 'POST',
      body: { username: username.value, password: password.value }
    })
    await navigateTo('/')
  } catch {
    error.value = 'Invalid username or password'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-wtc-bg flex items-center justify-center px-4">
    <div class="w-full max-w-sm">

      <!-- Wordmark -->
      <div class="text-center mb-10">
        <p class="text-3xl font-black tracking-[0.15em] text-wtc-teal leading-none">WINGNUT</p>
        <p class="text-xs font-medium tracking-[0.12em] uppercase mt-1 text-wtc-teal opacity-60">
          Trading Company
        </p>
      </div>

      <!-- Card -->
      <div class="bg-white rounded-2xl border border-wtc-border p-8 space-y-5">
        <h1 class="text-lg font-bold text-wtc-text-primary">Sign in</h1>

        <!-- Error -->
        <p v-if="error" class="text-sm text-red-600 bg-red-50 rounded-xl px-4 py-3">
          {{ error }}
        </p>

        <!-- Username -->
        <div class="space-y-1.5">
          <label class="text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Username</label>
          <input
              v-model="username"
              type="text"
              autocomplete="username"
              class="w-full px-4 py-3 rounded-xl border border-wtc-border bg-wtc-bg text-wtc-text-primary text-sm focus:outline-none focus:ring-2 focus:ring-wtc-teal focus:border-transparent transition"
              @keyup.enter="signIn"
          />
        </div>

        <!-- Password -->
        <div class="space-y-1.5">
          <label class="text-xs font-semibold text-wtc-text-secondary uppercase tracking-wider">Password</label>
          <input
              v-model="password"
              type="password"
              autocomplete="current-password"
              class="w-full px-4 py-3 rounded-xl border border-wtc-border bg-wtc-bg text-wtc-text-primary text-sm focus:outline-none focus:ring-2 focus:ring-wtc-teal focus:border-transparent transition"
              @keyup.enter="signIn"
          />
        </div>

        <!-- Submit -->
        <button
            @click="signIn"
            :disabled="loading"
            class="w-full py-3 rounded-xl bg-wtc-teal text-white font-bold text-sm tracking-wide hover:bg-wtc-teal-dark transition-colors disabled:opacity-50"
        >
          {{ loading ? 'Signing in...' : 'Sign In' }}
        </button>

        <!-- Divider -->
        <div class="flex items-center gap-3">
          <div class="flex-1 h-px bg-wtc-border" />
          <span class="text-xs text-wtc-text-secondary">or</span>
          <div class="flex-1 h-px bg-wtc-border" />
        </div>

        <!-- Apple (placeholder for now) -->
        <button
            class="w-full py-3 rounded-xl bg-black text-white font-bold text-sm flex items-center justify-center gap-2 hover:bg-gray-900 transition-colors"
        >
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.7 9.05 7.42c1.29.07 2.18.74 2.94.8 1.12-.21 2.18-.9 3.39-.77 1.44.17 2.53.73 3.21 1.87-2.93 1.83-2.23 5.85.46 6.97-.57 1.57-1.32 3.12-2 3.99zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
          </svg>
          Sign in with Apple
        </button>
      </div>
    </div>
  </div>
</template>