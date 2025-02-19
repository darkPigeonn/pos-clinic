<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-6">Dashboard</h1>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-2">Penjualan Hari Ini</h3>
        <p class="text-3xl font-bold">Rp {{ todaySales.toFixed(2) }}</p>
      </div>
      <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-2">Shift Aktif</h3>
        <p v-if="activeShift" class="text-3xl font-bold">Rp {{ activeShift.cash_start.toFixed(2) }}</p>
        <p v-else class="text-gray-500">Tidak ada shift aktif</p>
      </div>
      <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-2">Barang Habis Stok</h3>
        <p class="text-3xl font-bold">{{ lowStockCount }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const client = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()
const todaySales = ref(0)
const activeShift = ref(null)
const lowStockCount = ref(0)

onMounted(async () => {
  // Fetch today's sales
  if (!user.value) {
    router.push('/login') // Redirect ke halaman login jika user tidak ada
    return
  }
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  
  const { data: salesData } = await client
    .from('sales')
    .select('total_amount')
    .gte('created_at', today.toISOString())
  
  todaySales.value = salesData?.reduce((sum, sale) => sum + sale.total_amount, 0) || 0

  // Fetch active shift
  const { data: shiftData } = await client
    .from('shifts')
    .select('*')
    .eq('user_id', user.value.id)
    .eq('status', 'active')
    .single()
  
  activeShift.value = shiftData

  // Fetch low stock items (less than 10 items)
  const { data: stockData } = await client
    .from('products')
    .select('id')
    .eq('type', 'product')
    .lt('stock', 10)
  
  lowStockCount.value = stockData?.length || 0
})
</script>