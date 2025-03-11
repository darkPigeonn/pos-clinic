<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-6">Reports</h1>
      <button @click.prevent="processReport" class=" flex items-center py-2 px-4 bg-blue-500 text-white rounded hover:bg-blue-600">
        <span class="ml-2 md:inline-block">Proses Laporan Bulan Ini</span>
      </button>
  
    
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
  const salesHistory = ref([])
  const totalProfit = ref(0)
  
  import { useUserRole } from '~/composables/useUserRole';
import formatRupiah from '~/plugins/formatRupiah'
  const role = ref('guest');


  const processReport = async () => {
    console.log('Processing report...');
    awaitfetchReportData();
  }
    
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
              name,
              hpp
            )
          )
        `)
        .gte('created_at', `${new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]}T00:00:00`)
        .lte('created_at', `${new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).toISOString().split('T')[0]}T23:59:59`)
        .order('created_at', { ascending: false })


        console.log(sales);
  
     
  
            //get partner name
      const { data: partners } = await client.from('partners').select('*')


      sales.forEach(sale => {
        sale.sale_items.forEach(item => {
            item.hpp = item.product.hpp
            item.persentase = partners.find(partner => partner.id === sale.partner_id)?.persentase ? partners.find(partner => partner.id === sale.partner_id).persentase / 100 : 0
            item.temp_laba = item.price * item.persentase
            item.laba = (item.temp_laba - item.hpp) * item.quantity
        })
      
        sale.laba = sale.sale_items.reduce((sum, item) => sum + item.laba, 0)
       
        })
        
  
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
    //get total profit
    totalProfit.value = sales.reduce((sum, sale) => sum + sale.laba * (partners.find(partner => partner.id === sale.partner_id)?.persentase ? partners.find(partner => partner.id === sale.partner_id).persentase / 100 : 0), 0)
  
      // Format sales history
      salesHistory.value = sales.slice(0, 10).map(sale => ({
        ...sale,
        partner_name: partners.find(partner => partner.id === sale.partner_id)?.name,
        items: sale.sale_items.map(item => ({
          ...item,
          name: item.product.name,
          laba: item.laba
        })) ,
        profit : sale.laba
      }))
      console.log(salesHistory.value);
  
      // Calculate sales by klinik
      salesByKlinik.value = sales.reduce((acc, sale) => {
        acc[sale.partner_id] = (acc[sale.partner_id] || 0) + sale.total_amount
        return acc
      }, {})
  
      salesByKlinik.value = Object.entries(salesByKlinik.value).map(([partnerId, totalAmount]) => ({
        partnerId,
        totalAmount,
        totalTransactions: sales.filter(sale => sale.partner_id === parseInt(partnerId)).length,
        name: partners.find(partner => partner.id === parseInt(partnerId))?.name,
        totalProfit: sales.filter(sale => sale.partner_id === parseInt(partnerId)).reduce((sum, sale) => sum + sale.laba * (partners.find(partner => partner.id === sale.partner_id)?.persentase ? partners.find(partner => partner.id === sale.partner_id).persentase / 100 : 0), 0)
      }))
      
    } catch (error) {
      console.error('Error fetching report data:', error)
    }
  }
  
  onMounted(async () => {
    role.value = await useUserRole();
    if (role.value!== 'admin') {
      navigateTo('/')
    }
  })
  </script>