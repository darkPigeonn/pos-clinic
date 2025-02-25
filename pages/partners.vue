<template>
    <div class="p-6">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Daftar Klinik Mitra</h1>
        <button
          @click="showNewPartnerModal = true"
          class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          Tambah Mitra
        </button>
      </div>
  
      <div class="bg-white rounded-lg shadow">
        <div class="p-4 border-b">
          <div class="flex gap-4">
            <input
              v-model="search"
              type="text"
              placeholder="Cari klinik mitra..."
              class="flex-1 rounded-lg border-gray-300"
            />
            
          </div>
        </div>
  
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nama</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Alamat</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">No. Telp</th>
       
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pemilik Klinik</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nomor Klinik</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal Kontrak</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal Berakhir Kontrak</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Sisa Kontrak</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="item in filteredItems" :key="item.id">
                <td class="px-6 py-4">{{ item.name }}</td>
                <td class="px-6 py-4">{{ item.address }}</td>
                <td class="px-6 py-4">{{ item.phone }}</td>
              
                <td class="px-6 py-4">{{ item.owner_name }}</td>
                <td class="px-6 py-4">{{ item.license_number }}</td>
                <td class="px-6 py-4">{{ item.contract_date }}</td>
                <td class="px-6 py-4">{{ sisaKontrak(item.contract_date, item.contract_range).tanggalAkhir }}</td>
                <td class="px-6 py-4">{{ sisaKontrak(item.contract_date, item.contract_range).sisaKontrak }}</td>
               
                <td class="px-6 py-4">
                  <button
                    @click="editItem(item)"
                    class="text-blue-600 hover:text-blue-800 mr-4"
                  >
                    Edit
                  </button>
                  <button
                    @click="deleteItem(item)"
                    class="text-red-600 hover:text-red-800"
                  >
                    Hapus
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
  
      <!-- New/Edit Product Modal -->
      <div v-if="showNewPartnerModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
        <div class="bg-white rounded-lg p-6 w-full max-w-md">
          <h2 class="text-xl font-bold mb-4">
            {{ editingItem ? 'Ubah Klinik Mitra' : 'Tambah Klinik Mitra' }}
          </h2>
          <form @submit.prevent="saveItem">
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Nama Klinik</label>
                <input
                  v-model="itemForm.name"
                  type="text"
                  required
                  class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray700">Alamat</label>
                <textarea
                  v-model="itemForm.address"
                  type="textarea"
                  required
                  class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                  rows="3"
                ></textarea>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray700">No. Telp</label>
                <input
                  v-model="itemForm.phone"
                  type="text"
                  required
                  class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray700">Email</label>
                <input
                  v-model="itemForm.email"
                  type="email"
                  required
                  class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray700">Pemilik Klinik</label>
                <input
                  v-model="itemForm.owner_name"
                  type="text"
                  required
                  class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray700">Nomor Klinik</label>
                <input
                  v-model="itemForm.license_number"
                  type="text"
                  required
                  class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray700">Tanggal Kontrak</label>
                <input
                  v-model="itemForm.contract_date"
                  type="date"
                  required
                  class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray700">Tanggal Berakhir Kontrak</label>
                <input
                  v-model="itemForm.contract_range"
                  type="number"
                  required
                  class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                />
              </div>
            </div>
            <div class="mt-6 flex justify-end gap-4">
              <button
                type="button"
                @click="showNewPartnerModal = false"
                class="px-4 py-2 border rounded-lg hover:bg-gray-50"
              >
                Batal
              </button>
              <button
                type="submit"
                class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Simpan
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  const client = useSupabaseClient()
  
  const items = ref([])
  const search = ref('')
  const filterType = ref('all')
  const showNewPartnerModal = ref(false)
  const editingItem = ref(null)
  const itemForm = ref({
    name: '',
    address: '',
    phone: '',
    email: '',
    owner_name: '',
    license_number: '',
    contract_date: '',
    contract_range: ''
  })

  const sisaKontrak = function(date1, date2) {
    const currentDate = new Date();
    const contractDate = new Date(date1);
    const contractRange = parseInt(date2);

    // Hitung tanggal akhir kontrak
    const contractEndDate = new Date(contractDate);
    contractEndDate.setFullYear(contractDate.getFullYear() + contractRange);

    // Format tanggal akhir kontrak ke "YYYY-MM-DD"
    const formattedContractEndDate = contractEndDate.toISOString().split('T')[0];

    // Jika kontrak sudah berakhir
    if (currentDate > contractEndDate) {
        return {
            sisaKontrak: "Kontrak sudah berakhir",
            tanggalAkhir: formattedContractEndDate
        };
    }

    // Hitung selisih waktu dalam tahun, bulan, hari
    let years = contractEndDate.getFullYear() - currentDate.getFullYear();
    let months = contractEndDate.getMonth() - currentDate.getMonth();
    let days = contractEndDate.getDate() - currentDate.getDate();

    // Jika hari negatif, pinjam dari bulan sebelumnya
    if (days < 0) {
        const lastMonth = new Date(contractEndDate.getFullYear(), contractEndDate.getMonth(), 0);
        days += lastMonth.getDate();
        months--;
    }

    // Jika bulan negatif, pinjam dari tahun sebelumnya
    if (months < 0) {
        months += 12;
        years--;
    }

    return {
        sisaKontrak: `${years} tahun, ${months} bulan, ${days} hari`,
        tanggalAkhir: formattedContractEndDate
    };
}


  const filteredItems = computed(() => {
    return items.value
      .filter(item => {
        const matchesSearch = item.name.toLowerCase().includes(search.value.toLowerCase())
        const matchesType = filterType.value === 'all' || item.type === filterType.value
        return matchesSearch && matchesType
      })
  })
  
  const fetchItems = async () => {
    const { data } = await client
      .from('partners')
      .select('*')
  
      console.log(data);
      
    items.value = data || []
  }
  
  const editItem = (item) => {
    editingItem.value = item
    itemForm.value = { ...item }
    showNewPartnerModal.value = true
  }
  
  const deleteItem = async (item) => {
    if (!confirm('Apakah Anda yakin ingin menghapus item ini?')) return;
  
    try {
      console.log('Menghapus item dengan ID:', item.id);
  
      const { data, error } = await client
        .from('products')
        .delete()
        .eq('id', item.id);
  
      if (error) {
        console.error('Error deleting item:', error);
        alert('Gagal menghapus item');
        return;
      }
  
      console.log('Item berhasil dihapus:', data);
      alert('Item berhasil dihapus');
      
      await fetchItems(); // Memperbarui daftar item
    } catch (err) {
      console.error('Terjadi kesalahan:', err);
      alert('Terjadi kesalahan saat menghapus item');
    }
  };
  
  
  const saveItem = async () => {
    try {
      if (editingItem.value) {
        await client
          .from('partners')
          .update(itemForm.value)
          .eq('id', editingItem.value.id)
      } else {
       
        const { data, error } = await client
          .from('partners')
          .insert(itemForm.value)

        if (error) {
          console.error('Error inserting item:', error)
          alert('Error inserting item')
          return
        }
      }
  
  
      await fetchItems()
      showNewPartnerModal.value = false
      editingItem.value = null
      itemForm.value = {
        name: '',
        address: '',
        phone: '',
        email: '',
        owner_name: '',
        license_number: '',
        contract_date: '',
        contract_range: ''
      }
    } catch (error) {
      console.error('Error saving item:', error)
      alert('Error saving item')
    }
  }
  
  onMounted(fetchItems)
  </script>