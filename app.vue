<template>
  <div class="min-h-screen bg-gray-100">
    <NuxtLoadingIndicator />
    <div v-if="!user">
      <NuxtPage />
    </div>
    <div v-else class="flex h-screen">
      <Sidebar />
      <main class="flex-1 overflow-y-auto">
        <NuxtPage />
      </main>
    </div>
  </div>
</template>

<script setup>
const user = useSupabaseUser()

// Add global middleware
definePageMeta({
  middleware: ['auth']
})
</script>