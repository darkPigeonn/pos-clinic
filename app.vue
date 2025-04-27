<template>
  <div class="min-h-screen bg-gray-100">
    <NuxtLoadingIndicator />
    <Loading />
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
const router = useRouter()
const client = useSupabaseClient()
// Add global middleware
definePageMeta({
  middleware: ['auth']
})

onMounted(async () => {
  console.log(user.value?.email);
  if (user.value?.email === 'prasetyostefanusdwi@gmail.com') {
    alert('Anda tidak memiliki akses ke halaman ini')
    await client.auth.signOut()
    router.push('/auth/login')
  }
})


</script>