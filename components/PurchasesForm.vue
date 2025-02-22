<script setup lang="ts">
import { ref } from 'vue'
const client = useSupabaseClient()
const user = useSupabaseUser()
const purchase = ref({
  purchase_number: '',
  supplier_id: '',
  total: 0,
  status: 'pending',
  products: [] as { product_id: string; quantity: number; price: number; subtotal: string }[]
})

const itemsPurchase = ref({
  product_id: '',
  quantity: 0,
  price: 0,
  subtotal: ""
})

const formPurchase = ref(false)
const suppliers = ref([
  { id: 'supplier1', name: 'Supplier A' },
  { id: 'supplier2', name: 'Supplier B' }
])

const products = ref([
  { id: 'product1', name: 'Produk A', price: 50000 },
  { id: 'product2', name: 'Produk B', price: 75000 }
])

const addProduct = () => {
    const dataProduct = {
        product_id: itemsPurchase.value.product_id,
        quantity: itemsPurchase.value.quantity,
        price: itemsPurchase.value.price,
        subtotal: itemsPurchase.value.subtotal
    }
  purchase.value.products.push(dataProduct)
  formPurchase.value = false
  purchase.value.total += Number(itemsPurchase.value.subtotal.replace(/,/g, '').replace('.', '').replace('Rp', ''))
  //reset form
  itemsPurchase.value.product_id = ''
  itemsPurchase.value.quantity = 0
  itemsPurchase.value.price = 0
  itemsPurchase.value.subtotal = ''
}

const removeProduct = (index: number) => {
  purchase.value.products.splice(index, 1)
}

const submitForm = async () => {
  isLoading.value = true
  if(purchase.value.products.length === 0){
    alert('Belum ada produk ditambahkan')
    isLoading.value = false
    return
  }

  const { data, error } = await client
  .from('purchases')
  .insert({
    total: purchase.value.total,
    status: purchase.value.status,
    
  })
  .select() 
  .single()

  if(error){
    console.log(error)
    alert('Error submitting form')
    isLoading.value = false
    return
  }
    // Ambil purchase_id yang baru dibuat
    const purchaseId = data.id

// Masukkan items ke purchase_items
const itemsToInsert = purchase.value.products.map(item => ({
  purchase_id: purchaseId,
  product: item.product_id,
  quantity: item.quantity,
  price: item.price,

  purchase_price : item.price
}))

// Simpan items ke purchase_items
const { data: itemsData, error: itemsError } = await client
  .from('purchase_items')
  .insert(itemsToInsert)

if (itemsError) {
  console.error('Gagal menyimpan items:', itemsError.message)
} else {
  console.log('Items berhasil disimpan:', itemsData)
  alert('Pembelian berhasil disimpan')

  purchase.value.products = []
  purchase.value.total = 0
  purchase.value.status = 'pending'
}
isLoading.value = false

}
watch([() => itemsPurchase.value.quantity, () => itemsPurchase.value.price], () => {
  const subtotal = itemsPurchase.value.quantity * itemsPurchase.value.price; 
  itemsPurchase.value.subtotal = useFormatRupiah(subtotal.toString());
});

const isLoading = ref(false)
</script>

<template>
    <div class="p-2">
        <div class="bg-white p-6 rounded-lg shadow">
            <h2 class="text-xl font-bold mb-4">Form Pembelian</h2>
          
            <div class="mt-4">
                <h2 class="text-lg font-semibold mb-2">Daftar Produk</h2>
                
                <div v-if="purchase.products.length > 0" class="border rounded-lg p-2">
                    
                    <!-- Desktop View -->
                    <div class="hidden md:grid grid-cols-5 font-semibold text-gray-700 border-b pb-2">
                    <div>Nama Produk</div>
                    <div>Qty</div>
                    <div>Harga</div>
                    <div>Subtotal</div>
                    <div class="text-center">Aksi</div>
                    </div>

                    <!-- Mobile View -->
                    <div v-for="(item, index) in purchase.products" :key="index" 
                        class="border-b py-2 flex flex-col md:grid md:grid-cols-5 md:items-center">
                    
                    <div class="flex justify-between">
                        {{ item.product_id }}

                        <button type="button" @click="removeProduct(index)" 
                                class="text-red-500 hover:text-red-700 text-lg font-bold">
                        ✕
                        </button>
                    </div>
                    
                    <div class="flex justify-between">
                        <div>{{ item.quantity }} Rp {{ item.price.toLocaleString() }}</div>
                        <div>{{ item.subtotal.toLocaleString() }}</div>
                    </div>
                    
                    
                    <div class="text-right mt-2 md:mt-0">
                    </div>
                    </div>
                </div>

                <p v-else class="text-gray-500 text-sm italic">Belum ada produk ditambahkan.</p>
            </div>
        </div>
        <div class="fixed bottom-0 left-0 w-full p-6 rounded-lg shadow">
      
     
            <!-- Daftar Produk -->
            <div v-if="formPurchase" class="bg-white p-6 rounded-lg shadow">
                <form @submit.prevent="addProduct">
                    <div>
                        <label for="product_id">Nama Produk</label>
                        <input type="text" v-model="itemsPurchase.product_id" class="w-full border p-2 rounded focus:ring focus:ring-blue-300">
                    </div>
                    <div class="flex space-x-2 mt-2">
                        <div class="flex items-center">
                            <span class="mr-2">Pcs</span>
                            <input type="number" v-model="itemsPurchase.quantity" class="w-full border p-2 rounded focus:ring focus:ring-blue-300" >
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">Rp</span>
                            <input type="number" v-model="itemsPurchase.price" class="w-full border p-2 rounded focus:ring focus:ring-blue-300">
                        </div>
                    </div>
                    <div class="mt-2">
                        <label for="subtotal">Subtotal</label>
                        <input type="text" readonly v-model="itemsPurchase.subtotal" class="w-full border p-2 rounded focus:ring focus:ring-blue-300" >
                    </div>
                    <div class="flex justify-end">
                        <button type="submit" class="text-sm items-center float-right px-4 py-2 mt-2 bg-blue-500 text-white rounded hover:bg-green-600">+ Tambah Produk</button>
                    </div>
                </form>            
            </div>
            <button type="button" @click="formPurchase = !formPurchase " class="text-sm items-center float-right px-4 py-2 mt-2 bg-blue-500 text-white rounded hover:bg-green-600">{{ formPurchase ? '✕' : '+' }}</button>
      
            <!-- Total -->
            <div class="mt-2 bg-white p-6 rounded-lg shadow w-full">
              <label class="block text-sm font-medium">Total</label>
              <input v-model.number="purchase.total" type="number" class="w-full border p-2 rounded" readonly>
              <!-- Submit Button -->
              <button type="button" @click="submitForm" :disabled="isLoading" :class="isLoading ? 'w-full mt-2 bg-gray-400 text-white py-2 rounded cursor-not-allowed' : 'w-full mt-2 bg-green-500 text-white py-2 rounded hover:bg-green-600'">
                {{ isLoading ? 'Memproses...' : 'Simpan Pembelian' }}
              </button>
            </div>
      
         
        </div>
    </div>
</template>

<style scoped>
input, select {
  outline: none;
}
</style>
