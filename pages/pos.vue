<template>
  <div class="p-6">
    <div v-if="!activeShift" class="text-center py-12">
      <h2 class="text-2xl font-bold mb-4">Tidak ada Shift Aktif</h2>
      <p class="text-gray-600 mb-4">Anda perlu memulai shift sebelum menggunakan POS</p>
      <button
        @click="showStartShiftModal = true"
        class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
      >
        Mulai Shift
      </button>
    </div>
    <div v-else class="grid md:grid-cols-12 grid-cols-6 gap-6">
      <!-- Products Section -->
      <div class="md:col-span-8 col-span-6">
        <div class="bg-white rounded-lg shadow p-4 mb-6">
          <div class="flex gap-4 mb-4">
            <input
              v-model="search"
              type="text"
              placeholder="Search products..."
              class="flex-1 rounded-lg border-gray-300"
            />
            <select
              v-model="filterType"
              class="rounded-lg border-gray-300 p-2"
            >
              <option value="all">Semua</option>
              <option value="service">Layanan</option>
              <option value="product">Barang</option>
            </select>
          </div>
          <div class="grid md:grid-cols-3 grid-cols-2 gap-4">
            <div
              v-for="product in filteredProducts"
              :key="product.id"
              @click="addToCart(product)"
              class="bg-gray-50 p-4 rounded-lg cursor-pointer hover:bg-gray-100"
            >
              <h3 class="font-semibold">{{ product.name }}</h3>
              <p class="text-gray-600">{{$formatRupiah(product.price) }}</p>              
              <p v-if="product.type === 'product'" class="text-sm text-gray-500">
                Stock: {{ product.stock }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Cart Section Desktop -->
      <div class="md:block hidden md:col-span-4 col-span-6">
        <div class="bg-white rounded-lg shadow p-4">
          <h2 class="text-xl font-bold mb-4">Penjualan Saat Ini</h2>
          <div class="mb-4 max-h-96 overflow-y-auto">
            <div
              v-for="item in cart"
              :key="item.id"
              class="flex justify-between items-center py-2 border-b"
            >
              <div>
                <h4 class="font-semibold">{{ item.name }}</h4>
                <p class="text-sm text-gray-600">
                  {{ $formatRupiah(item.price) }} x {{ item.quantity }}
                </p>
              </div>
              <div class="flex items-center gap-2">
                <button
                  @click="updateQuantity(item, -1)"
                  class="px-2 py-1 bg-gray-100 rounded"
                >
                  -
                </button>
                <span>{{ item.quantity }}</span>
                <button
                  @click="updateQuantity(item, 1)"
                  class="px-2 py-1 bg-gray-100 rounded"
                >
                  +
                </button>
              </div>
            </div>
          </div>
          <div class="border-t pt-4">
            <div class="flex justify-between mb-4">
              <span class="font-bold">Total:</span>
              <span class="font-bold">{{ $formatRupiah(total) }}</span>
            </div>
            <select
              v-model="paymentMethod"
              class="w-full mb-4 rounded-lg border-gray-300 p-2"
            >
              <option value="cash">Tunai</option>
              <!-- <option value="card">Card</option>
              <option value="gcash">GCash</option> -->
            </select>
            <button
              @click="processSale"
              :disabled="cart.length === 0"
              class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:bg-gray-400"
            >
              Proses Penjualan
            </button>
          </div>
        </div>
      </div>

      <!-- Cart Section Mobile -->
      <div class="md:hidden fixed bottom-0 left-0 w-full z-50">
        <div class="flex justify-end">
          <button
          @click="showCartModal = !showCartModal"
          class="my-2 p-2 bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700"
        >
          {{showCartModal ? 'X' : cart.length > 0 ? `${cart.length}` : '0' }}
        </button>
        </div>
        <div class="bg-white rounded-t-lg shadow-lg p-4">
          <div class="flex items-center justify-between mb-2">
            <h2 class="text-xl font-bold mr-4">Total Penjualan</h2>
            <p class="text-2xl font-bold">{{ $formatRupiah(total) }}</p>
          </div>
          <button
              @click="processSale"
              :disabled="cart.length === 0"
              class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 mb-2"
            >
              Proses Penjualan
            </button>
        </div>
      
      </div>

    </div>

    <!-- End Shift Modal -->
    <div v-if="showStartShiftModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-xl font-bold mb-4">Mulai Shift</h2>
        <form @submit.prevent="startShift">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Saldo Awal</label>
              <input
                v-model.number="startShiftForm.cash_start"
                type="number"
                step="0.01"
                required
                class="mt-1 p-2 block w-full rounded-lg border-gray-300"
              />
            </div>
            <button
              type="submit"
              class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
            >
              Mulai Shift
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Cart Modal -->
    <div v-if="showCartModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="bg-white rounded-lg shadow p-4">        
        <h2 class="text-xl font-bold mb-4">Keranjang Belanja</h2>
        <div v-for="item in cart" :key="item.id">
          <div class="items-center py-2 border-b">
            <h4 class="font-semibold">{{ item.name }}</h4>
            <p class="text-sm text-gray-600">
              {{ $formatRupiah(item.price) }} x {{ item.quantity }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import formatRupiah from '~/plugins/formatRupiah'
const {show, hide} = useLoading()
const client = useSupabaseClient()
const user = useSupabaseUser()

const activeShift = ref(null)
const products = ref([])
const cart = ref([])
const search = ref('')
const filterType = ref('all')
const paymentMethod = ref('cash')
const showStartShiftModal = ref(false)
const showCartModal = ref(false)
const startShiftForm = ref({
  cash_start: 0,
})

const total = computed(() => {
  return cart.value.reduce((sum, item) => sum + (item.price * item.quantity), 0)
})

const filteredProducts = computed(() => {
  return products.value
    .filter(product => {
      const matchesSearch = product.name.toLowerCase().includes(search.value.toLowerCase())
      const matchesType = filterType.value === 'all' || product.type === filterType.value
      return matchesSearch && matchesType
    })
})

const fetchProducts = async () => {
  const { data } = await client
    .from('products')
    .select('*')
  products.value = data || []
}

const fetchActiveShift = async () => {
  const { data } = await client
    .from('shifts')
    .select('*')
    .eq('user_id', user.value.id)
    .eq('status', 'active')
    .single()
  activeShift.value = data
}

const startShift = async () => {
  const { data, error } = await client
    .from('shifts')
    .insert({
      user_id: user.value.id,
      cash_start: startShiftForm.value.cash_start,
      status: 'active'
    })
    .select()
    .single()
  
  if (!error) {
    activeShift.value = data
  }
}

const addToCart = (product) => {

  const existingItem = cart.value.find(item => item.id === product.id)
  if (existingItem) {
    updateQuantity(existingItem, 1)
  } else {
    cart.value.push({
      ...product,
      quantity: 1
    })
  }
}

const updateQuantity = (item, change) => {
  const newQuantity = item.quantity + change
  if (newQuantity > 0) {
    if (item.type === 'product' && newQuantity > item.stock) {
      alert('Not enough stock!')
      return
    }
    item.quantity = newQuantity
  } else {
    cart.value = cart.value.filter(cartItem => cartItem.id !== item.id)
  }
}

const processSale = async () => {
  show()
  if (!activeShift.value) return

  try {
    // Create sale record
    const { data: sale } = await client
      .from('sales')
      .insert({
        shift_id: activeShift.value.id,
        total_amount: total.value,
        payment_method: paymentMethod.value
      })
      .select()
      .single()

    // Create sale items
    const saleItems = cart.value.map(item => ({
      sale_id: sale.id,
      product_id: item.id,
      quantity: item.quantity,
      price: item.price
    }))

    await client
      .from('sale_items')
      .insert(saleItems)

    // Update product stock
    for (const item of cart.value) {
      if (item.type === 'product') {
        await client
          .from('products')
          .update({ stock: item.stock - item.quantity })
          .eq('id', item.id)
      }
    }

    // Clear cart
    cart.value = []
    paymentMethod.value = 'cash'
    
    // Refresh products
    hide()
    alert('Penjualan berhasil')

    await fetchProducts()
  } catch (error) {
    hide()
    console.error('Error processing sale:', error)
    alert('Error processing sale')
  }
}

onMounted(async () => {
  await fetchActiveShift()
  await fetchProducts()
})
</script>