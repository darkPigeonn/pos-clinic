<template>
  <div class="bg-white w-64 h-screen shadow-lg">
    <div class="p-4 border-b">
      <h1 class="text-xl font-bold">Clinic POS</h1>
    </div>
    <nav class="p-4">
      <NuxtLink to="/" class="block py-2 px-4 rounded hover:bg-gray-100">
        Dashboard
      </NuxtLink>
      <NuxtLink to="/pos" class="block py-2 px-4 rounded hover:bg-gray-100">
        Point of Sale
      </NuxtLink>
      <NuxtLink to="/inventory" class="block py-2 px-4 rounded hover:bg-gray-100">
        Inventory
      </NuxtLink>
      <NuxtLink to="/shifts" class="block py-2 px-4 rounded hover:bg-gray-100">
        Shifts
      </NuxtLink>
      <NuxtLink to="/reports" class="block py-2 px-4 rounded hover:bg-gray-100">
        Reports
      </NuxtLink>
    </nav>
    <div class="absolute bottom-0 w-64 p-4 border-t">
      <button @click="handleLogout" class="w-full py-2 px-4 bg-red-500 text-white rounded hover:bg-red-600">
        Logout
      </button>
    </div>
  </div>
</template>

<script setup>
const client = useSupabaseClient()
const router = useRouter()

const handleLogout = async () => {
  await client.auth.signOut()
  router.push('/auth/login')
}
</script>