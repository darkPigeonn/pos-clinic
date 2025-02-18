<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-6">Reports</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
      <!-- Date Range Selector -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-lg font-semibold mb-4">Jangka Waktu</h2>
        <div class="flex gap-4">
          <div class="flex-1">
            <label class="block text-sm font-medium text-gray-700">Tanggal Mulai</label>
            <input
              v-model="startDate"
              type="date"
              class="mt-1 block w-full rounded-lg border-gray-300"
            />
          </div>
          <div class="flex-1">
            <label class="block text-sm font-medium text-gray-700">Tanggal Selesai</label>
            <input
              v-model="endDate"
              type="date"
              class="mt-1 block w-full rounded-lg border-gray-300"
            />
          </div>
        </div>
      </div>

      <!-- Summary Stats -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-lg font-semibold mb-4">Rekapitulasi</h2>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-sm text-gray-600">Total Penjualan</p>
            <p class="text-2xl font-bold">{{ $formatRupiah(totalSales) }}</p>
          </div>
          <div>
            <p class="text-sm text-gray-600">Total Transaksi</p>
            <p class="text-2xl font-bold">{{ totalTransactions }}</p>
          </div>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
      <!-- Sales by Payment Method -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-lg font-semibold mb-4">Penjualan per Metode Pembayaran</h2>
        <div class="space-y-4">
          <div v-for="(amount, method) in salesByPaymentMethod" :key="method">
            <div class="flex justify-between items-center">
              <span class="capitalize">{{ method }}</span>
              <span class="font-semibold">₱{{ amount.toFixed(2) }}</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-blue-600 h-2 rounded-full"
                :style="{
                  width: `${(amount / totalSales) * 100}%`
                }"
              ></div> </div>
          </div>
        </div>
      </div>

      <!-- Top Products -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-lg font-semibold mb-4">Produk Teratas</h2>
        <div class="space-y-4">
          <div v-for="product in topProducts" :key="product.id">
            <div class="flex justify-between items-center">
              <span>{{ product.name }}</span>
              <span class="font-semibold">{{ product.quantity }} units</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-green-600 h-2 rounded-full"
                :style="{
                  width: `${(product.quantity / topProducts[0].quantity) * 100}%`
                }"
              ></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Sales History -->
    <div class="bg-white rounded-lg shadow">
      <div class="p-4 border-b">
        <h2 class="text-lg font-semibold">Riwayat Penjualan</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Items</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Metode Pembayaran</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="sale in salesHistory" :key="sale.id">
              <td class="px-6 py-4">{{ new Date(sale.created_at).toLocaleString() }}</td>
              <td class="px-6 py-4">
                <div v-for="item in sale.items" :key="item.id" class="text-sm">
                  {{ item.quantity }}x {{ item.name }}
                </div>
              </td>
              <td class="px-6 py-4 capitalize">{{ sale.payment_method }}</td>
              <td class="px-6 py-4">₱{{ sale.total_amount.toFixed(2) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
const client = useSupabaseClient()

const startDate = ref(new Date(new Date().setDate(new Date().getDate() - 30)).toISOString().split('T')[0])
const endDate = ref(new Date().toISOString().split('T')[0])

const totalSales = ref(0)
const totalTransactions = ref(0)
const salesByPaymentMethod = ref({})
const topProducts = ref([])
const salesHistory = ref([])

const fetchReportData = async () => {
  try {
    // Fetch sales within date range
    const { data: sales } = await client
      .from('sales')
      .select(`
        *,
        sale_items (
          *,
          product:products (
            name
          )
        )
      `)
      .gte('created_at', `${startDate.value}T00:00:00`)
      .lte('created_at', `${endDate.value}T23:59:59`)
      .order('created_at', { ascending: false })

    if (!sales) return

    // Process sales data
    totalTransactions.value = sales.length
    totalSales.value = sales.reduce((sum, sale) => sum + sale.total_amount, 0)

    // Calculate sales by payment method
    salesByPaymentMethod.value = sales.reduce((acc, sale) => {
      acc[sale.payment_method] = (acc[sale.payment_method] || 0) + sale.total_amount
      return acc
    }, {})

    // Calculate top products
    const productQuantities = {}
    sales.forEach(sale => {
      sale.sale_items.forEach(item => {
        const productName = item.product.name
        productQuantities[productName] = (productQuantities[productName] || 0) + item.quantity
      })
    })

    topProducts.value = Object.entries(productQuantities)
      .map(([name, quantity]) => ({ name, quantity }))
      .sort((a, b) => b.quantity - a.quantity)
      .slice(0, 5)

    // Format sales history
    salesHistory.value = sales.map(sale => ({
      ...sale,
      items: sale.sale_items.map(item => ({
        ...item,
        name: item.product.name
      }))
    }))
  } catch (error) {
    console.error('Error fetching report data:', error)
  }
}

watch([startDate, endDate], fetchReportData)
onMounted(fetchReportData)
</script>