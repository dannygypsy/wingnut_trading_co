<script setup lang="ts">
</script>

<template>
  <header class="bg-white border-b border-wtc-border sticky top-0 z-10">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">

      <!-- Left: Logo + Wordmark -->
      <NuxtLink to="/" class="flex items-center gap-3">
        <img src="/ponyLogo.png" alt="Wingnut" class="h-10 w-auto" />
        <div>
          <p class="text-xl font-black tracking-[0.15em] leading-none text-wtc-teal">WINGNUT</p>
          <p class="text-[10px] font-medium tracking-[0.12em] uppercase mt-0.5 text-wtc-teal opacity-60">
            Trading Company
          </p>
        </div>
      </NuxtLink>

      <!-- Right: User menu -->
      <UserMenu />

    </div>
  </header>
</template>