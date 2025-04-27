<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-6">Dashboard</h1>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-2">Penjualan Hari Ini</h3>
        <p class="text-3xl font-bold"> {{ $formatRupiah(todaySales) }}</p>
      </div>
      <div class="bg-white p-6 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-2">Shift Aktif</h3>
        <p v-if="activeShift" class="text-3xl font-bold">{{ activeShift }} Klinik</p>
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
import { useUserRole } from '~/composables/useUserRole';

onMounted(async () => {
  console.log(user.value?.email);
  if (user.value?.email === 'prasetyostefanusdwi@gmail.com') {
    alert('Anda tidak memiliki akses ke halaman ini')
    await client.auth.signOut()
    router.push('/auth/login')
  }

  // Fetch today's sales

  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const thisRole = await useUserRole();
  
  const { data: salesData } = await client
    .from('sales')
    .select('total_amount')
    .gte('created_at', today.toISOString())
  
  todaySales.value = salesData?.reduce((sum, sale) => sum + sale.total_amount, 0) || 0

  // Fetch active shift
  let { data: shiftData } = await client
    .from('shifts')
    .select('*')
    .eq('user_id', user.value.id)
    .eq('status', 'active')
    .single()

  if (thisRole === 'admin') {
    const { data: allShiftData } = await client
      .from('shifts')
      .select('*')
      .eq('status', 'active')
    shiftData = allShiftData;
  } 
  
  activeShift.value = shiftData.length > 0 ? shiftData.length : 0

  // Fetch low stock items (less than 10 items)
  const { data: stockData } = await client
    .from('products')
    .select('id')
    .eq('type', 'product')
    .lt('stock', 10)
  
  lowStockCount.value = stockData?.length || 0




})
</script>