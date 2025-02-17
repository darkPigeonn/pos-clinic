<template>
  <div class="p-6">
    <div v-if="!activeShift" class="text-center py-12">
      <h2 class="text-2xl font-bold mb-4">No Active Shift</h2>
      <p class="text-gray-600 mb-4">You need to start a shift before using the POS</p>
      <button
        @click="startShift"
        class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
      >
        Start Shift
      </button>
    </div>
    <div v-else class="grid grid-cols-12 gap-6">
      <!-- Products Section -->
      <div class="col-span-8">
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
              class="rounded-lg border-gray-300"
            >
              <option value="all">All</option>
              <option value="product">Products</option>
              <option value="service">Services</option>
            </select>
          </div>
          <div class="grid grid-cols-3 gap-4">
            <div
              v-for="product in filteredProducts"
              :key="product.id"
              @click="addToCart(product)"
              class="bg-gray-50 p-4 rounded-lg cursor-pointer hover:bg-gray-100"
            >
              <h3 class="font-semibold">{{ product.name }}</h3>
              <p class="text-gray-600">₱{{ product.price.toFixed(2) }}</p>
              <p v-if="product.type === 'product'" class="text-sm text-gray-500">
                Stock: {{ product.stock }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Cart Section -->
      <div class="col-span-4">
        <div class="bg-white rounded-lg shadow p-4">
          <h2 class="text-xl font-bold mb-4">Current Sale</h2>
          <div class="mb-4 max-h-96 overflow-y-auto">
            <div
              v-for="item in cart"
              :key="item.id"
              class="flex justify-between items-center py-2 border-b"
            >
              <div>
                <h4 class="font-semibold">{{ item.name }}</h4>
                <p class="text-sm text-gray-600">
                  ₱{{ item.price.toFixed(2) }} x {{ item.quantity }}
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
              <span class="font-bold">₱{{ total.toFixed(2) }}</span>
            </div>
            <select
              v-model="paymentMethod"
              class="w-full mb-4 rounded-lg border-gray-300"
            >
              <option value="cash">Cash</option>
              <option value="card">Card</option>
              <option value="gcash">GCash</option>
            </select>
            <button
              @click="processSale"
              :disabled="cart.length === 0"
              class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:bg-gray-400"
            >
              Process Sale
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const client = useSupabaseClient()
const user = useSupabaseUser()

const activeShift = ref(null)
const products = ref([])
const cart = ref([])
const search = ref('')
const filterType = ref('all')
const paymentMethod = ref('cash')

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
      cash_start: 0,
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
    await fetchProducts()
  } catch (error) {
    console.error('Error processing sale:', error)
    alert('Error processing sale')
  }
}

onMounted(async () => {
  await fetchActiveShift()
  await fetchProducts()
})
</script>