<template>
  <div class="flex">
    <!-- Burger Button for Mobile -->
    <button @click="toggleSidebar" class="md:hidden absolute top-4 right-4 z-50 p-2 bg-white shadow-lg rounded-md">
      <span v-if="!isOpen">&#9776;</span>
      <span v-else>&times;</span>
    </button>
    
    <!-- Sidebar -->
    <div 
      :class="[
        'bg-white h-screen shadow-lg ',
        isOpen ? 'w-64' : 'w-0 md:w-64',
        isOpen ? 'visible' : 'invisible md:visible'
      ]"
    >
      <div class="p-4 border-b flex items-center justify-between">
        <h1 class="text-xl font-bold ">Karunia Jaya Medika</h1>
      </div>
      <nav class="p-4">
        <NuxtLink to="/" class="flex items-center py-2 px-4 rounded hover:bg-gray-100">          
          <span class="ml-2 md:inline-block">Dashboard</span>
        </NuxtLink>
        <NuxtLink to="/pos" class="flex items-center py-2 px-4 rounded hover:bg-gray-100">
          <span class="ml-2 md:inline-block">Kasir</span>
        </NuxtLink>
        <NuxtLink to="/purchases" class="flex items-center py-2 px-4 rounded hover:bg-gray-100">
          <span class="ml-2 md:inline-block">Pembelian</span>
        </NuxtLink>
        <NuxtLink to="/inventory" class="flex items-center py-2 px-4 rounded hover:bg-gray-100">
          <span class="ml-2 md:inline-block">Stok Barang</span>
        </NuxtLink>
        <NuxtLink to="/shifts" class="flex items-center py-2 px-4 rounded hover:bg-gray-100">
          <span class="ml-2 md:inline-block">Shift</span>
        </NuxtLink>
        <NuxtLink to="/reports" class="flex items-center py-2 px-4 rounded hover:bg-gray-100">
          <span class="ml-2 md:inline-block">Laporan</span>
        </NuxtLink>
        <NuxtLink v-if="role === 'admin'" to="/partners" class="flex items-center py-2 px-4 rounded hover:bg-gray-100">
          <span class="ml-2 md:inline-block">Klinik</span>
        </NuxtLink>
        <NuxtLink v-if="role === 'admin'" to="/users" class="flex items-center py-2 px-4 rounded hover:bg-gray-100">
          <span class="ml-2 md:inline-block">Pengguna</span>
        </NuxtLink>
      </nav>
      <div class="absolute bottom-0 p-4 border-t">
        <button @click.prevent="handleLogout" class="w-full flex items-center py-2 px-4 bg-red-500 text-white rounded hover:bg-red-600">
          <span class="ml-2 md:inline-block">Keluar</span>
        </button>
      </div>
    </div>

    <!-- Content Area -->
    <div :class="['flex-1 transition-all duration-300', isOpen ? 'ml-64' : 'ml-0 md:ml-16']">
      <slot />
    </div>
  </div>
</template>

<script setup>

const client = useSupabaseClient()
const router = useRouter()
const isOpen = ref(false)

import { useUserRole } from '~/composables/useUserRole';
const role = ref('guest');

const toggleSidebar = () => {
  isOpen.value = !isOpen.value
}

onMounted(async () => {

  role.value = await useUserRole();
  router.afterEach(() => {
    isOpen.value = false
  })
})


const handleLogout = async () => {
  await client.auth.signOut()
  router.push('/auth/login')
}
</script>
