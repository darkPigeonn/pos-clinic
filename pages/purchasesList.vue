<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-6">Daftar Pembelian</h1>
      <!-- Purchases List -->
      <div class="bg-white rounded-lg shadow">
        <div class="p-4 border-b">
          <h2 class="text-lg font-semibold">Riwayat Pembelian</h2>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Items</th>    
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="purchase in purchasesHistory" :key="purchase.id">
                <td class="px-6 py-4">{{ new Date(purchase.created_at).toLocaleString() }}</td>
                <td class="px-6 py-4">
                  <div v-for="item in purchase.purchase_items" :key="item.id" class="text-sm">
                  {{ item.product }} | {{ item.quantity }} x {{ item.price }} = {{ $formatRupiah(item.subtotal) }}
                  </div>
                </td>
              
                <td class="px-6 py-4">{{ $formatRupiah(purchase.total) }}</td> 
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
  const salesByKlinik = ref({})
  const topProducts = ref([])
  const purchasesHistory = ref([])
  
  
  import { useUserRole } from '~/composables/useUserRole';
  const role = ref('guest');
  
  onMounted(async () => {
    role.value = await useUserRole();
  })
  
  
  const fetchReportData = async () => {
    try {
      // Fetch sales within date range
      const user = await client.auth.getUser()
  const {data: dataUser} = await client.from('users').select('*').eq('auth_id', user.data.user.id).single()
 

        if(dataUser.role === 'admin'){
            const { data: purchases } = await client
              .from('purchases')
              .select(`
                *,
                purchase_items (
                  *
                )
              `)
              .eq('ownercode', thisUser.ownerCode)
      
        
        
            
            if (!purchases) return
            purchasesHistory.value = purchases
        }else{
            const { data: purchases } = await client
              .from('purchases')
              .select(`
                *,
                purchase_items (
                  *
                )
              `).eq('partner_id', dataUser.partner_id)
      
        
        
            
            if (!purchases) return
            purchasesHistory.value = purchases
        }
   
      
      
    } catch (error) {
      console.error('Error fetching report data:', error)
    }
  }
  
  watch([startDate, endDate], fetchReportData)
  onMounted(fetchReportData)
  </script>