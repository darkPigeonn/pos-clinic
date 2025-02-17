<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-6">Dashboard</h1>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-2">Today's Sales</h3>
        <p class="text-3xl font-bold">₱{{ todaySales.toFixed(2) }}</p>
      </div>
      <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-2">Active Shift</h3>
        <p v-if="activeShift" class="text-3xl font-bold">₱{{ activeShift.cash_start.toFixed(2) }}</p>
        <p v-else class="text-gray-500">No active shift</p>
      </div>
      <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-2">Low Stock Items</h3>
        <p class="text-3xl font-bold">{{ lowStockCount }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const client = useSupabaseClient()
const user = useSupabaseUser()

const todaySales = ref(0)
const activeShift = ref(null)
const lowStockCount = ref(0)

onMounted(async () => {
  // Fetch today's sales
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