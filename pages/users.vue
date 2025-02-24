<template>
  <div class="p-6" v-if="!loadingPage">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Pengguna</h1>
        <div class="flex gap-4">
            <!-- <button class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
                Tambah Pengguna
            </button> -->
        </div>
    </div>
    <div class="bg-white rounded-lg shadow">
        <div class="p-4 border-b">
            <div class="flex gap-4">
                <input type="text" placeholder="Cari pengguna..." class="flex-1 rounded-lg border-gray-300">
            </div>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nama</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Klinik</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aksi</th>
                    </tr>
                </thead>
                <tbody class="bg-white">
                    <tr v-for="user in dataUser" :key="user.id">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ user.name }}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ user.email }}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ user.role }}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ user.partner_name }}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <button @click="showEditModal = true; editUser = user" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
                                Edit
                            </button>
                            <button class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700">
                                Hapus
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
  </div>
  <div v-else>
    <LoadingBar />
  </div>

  <!-- modal edit -->
  <div 
  class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center" 
  v-if="showEditModal"
>
  <div class="bg-white rounded-lg p-6 w-full max-w-md">
    <h2 class="text-2xl font-bold mb-4 text-gray-800 max-w-4xl text-center">Edit Pengguna</h2>
    <form @submit.prevent="handleEditUser">
      <div class="mb-4">
        <label for="name" class="block text-sm font-medium text-gray-700">Nama</label>
        <input 
          type="text" v-model="editUser.name" 
          class="p-2 mt-1 block w-full rounded-md border border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        >
      </div>
      <div class="mb-4">
        <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
        <input 
          type="email" v-model="editUser.email" 
          class="p-2 mt-1 block w-full rounded-md border border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        >
      </div>
      <div class="mb-4">
        <label for="role" class="block text-sm font-medium text-gray-700">Role</label>
        <select 
          v-model="editUser.role" 
          class="p-2 mt-1 block w-full rounded-md border border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        >
          <option value="admin">Admin</option>
          <option value="user">Perawat</option>
        </select>
      </div>
      <div class="mb-4">
        <label for="partner_id" class="block text-sm font-medium text-gray-700">Klinik</label>
        <select 
          v-model="editUser.partner_id" 
          class="p-2 mt-1 block w-full rounded-md border border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        >
          <option v-for="partner in dataPartner" :key="partner.id" :value="partner.id">
            {{ partner.name }}
          </option>
        </select>
      </div>
      <div class="flex justify-end gap-4">
        <button 
          type="submit" 
          class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          Simpan
        </button>
        <button 
          type="button" @click="showEditModal = false" 
          class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700"
        >
          Batal
        </button>
      </div>
    </form>
  </div>
</div>

</template>

<script setup>
const loadingPage = ref(true)
const dataUser = ref([])
const dataPartner = ref([])
const client = useSupabaseClient()
const search = ref('')
const showEditModal = ref(false)
const editUser = ref({
    name: '',
    email: '',
    role: '',
    partner_id: ''
})
onMounted(async () => {
  const { data, error } = await client
    .from('users')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error(error)
  } else {
    dataUser.value = data
  }
  const { data: partnerData, error: partnerError } = await client
    .from('partners')
    .select('*')

  if (partnerError) {
    console.error(partnerError)
  } else {
    dataPartner.value = partnerData
  }
  
  loadingPage.value = false
})

// function
const handleEditUser = async () => {
    loadingPage.value = true
  const { data, error } = await client
    .from('users')
    .update(editUser.value)
    .eq('id', editUser.value.id)

  if (error) {
    console.error(error)
  } else {
    alert('Pengguna berhasil diubah')
    showEditModal.value = false
  }
}


</script>