<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Inventory</h1>
      <button
        @click="showNewProductModal = true"
        class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
      >
        Add New Item
      </button>
    </div>

    <div class="bg-white rounded-lg shadow">
      <div class="p-4 border-b">
        <div class="flex gap-4">
          <input
            v-model="search"
            type="text"
            placeholder="Search items..."
            class="flex-1 rounded-lg border-gray-300"
          />
          <select
            v-model="filterType"
            class="rounded-lg border-gray-300"
          >
            <option value="all">All</option>
            <option value="product">Products</option>
            <option value="service">Services</option>
          </select>
        </div>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="item in filteredItems" :key="item.id">
              <td class="px-6 py-4">{{ item.name }}</td>
              <td class="px-6 py-4 capitalize">{{ item.type }}</td>
              <td class="px-6 py-4">₱{{ item.price.toFixed(2) }}</td>
              <td class="px-6 py-4">
                <span
                  v-if="item.type === 'product'"
                  :class="{
                    'text-red-600': item.stock < 10,
                    'text-yellow-600': item.stock >= 10 && item.stock < 20,
                    'text-green-600': item.stock >= 20
                  }"
                >
                  {{ item.stock }}
                </span>
                <span v-else>-</span>
              </td>
              <td class="px-6 py-4">
                <button
                  @click="editItem(item)"
                  class="text-blue-600 hover:text-blue-800 mr-4"
                >
                  Edit
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- New/Edit Product Modal -->
    <div v-if="showNewProductModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">
          {{ editingItem ? 'Edit Item' : 'New Item' }}
        </h2>
        <form @submit.prevent="saveItem">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Name</label>
              <input
                v-model="itemForm.name"
                type="text"
                required
                class="mt-1 block w-full rounded-lg border-gray-300"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Type</label>
              <select
                v-model="itemForm.type"
                required
                class="mt-1 block w-full rounded-lg border-gray-300"
              >
                <option value="product">Product</option>
                <option value="service">Service</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Price</label>
              <input
                v-model.number="itemForm.price"
                type="number"
                step="0.01"
                required
                class="mt-1 block w-full rounded-lg border-gray-300"
              />
            </div>
            <div v-if="itemForm.type === 'product'">
              <label class="block text-sm font-medium text-gray-700">Stock</label>
              <input
                v-model.number="itemForm.stock"
                type="number"
                required
                class="mt-1 block w-full rounded-lg border-gray-300"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Description</label>
              <textarea
                v-model="itemForm.description"
                class="mt-1 block w-full rounded-lg border-gray-300"
                rows="3"
              ></textarea>
            </div>
          </div>
          <div class="mt-6 flex justify-end gap-4">
            <button
              type="button"
              @click="showNewProductModal = false"
              class="px-4 py-2 border rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              Save
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
const showNewProductModal = ref(false)
const editingItem = ref(null)
const itemForm = ref({
  name: '',
  type: 'product',
  price: 0,
  stock: 0,
  description: ''
})

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
    .from('products')
    .select('*')
  items.value = data || []
}

const editItem = (item) => {
  editingItem.value = item
  itemForm.value = { ...item }
  showNewProductModal.value = true
}

const saveItem = async () => {
  try {
    if (editingItem.value) {
      await client
        .from('products')
        .update(itemForm.value)
        .eq('id', editingItem.value.id)
    } else {
      await client
        .from('products')
        .insert(itemForm.value)
    }

    await fetchItems()
    showNewProductModal.value = false
    editingItem.value = null
    itemForm.value = {
      name: '',
      type: 'product',
      price: 0,
      stock: 0,
      description: ''
    }
  } catch (error) {
    console.error('Error saving item:', error)
    alert('Error saving item')
  }
}

onMounted(fetchItems)
</script>