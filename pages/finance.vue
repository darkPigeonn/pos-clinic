<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-6">Reports</h1>
      <button @click.prevent="processReport" class=" flex items-center py-2 px-4 bg-blue-500 text-white rounded hover:bg-blue-600">
          <span class="ml-2 md:inline-block">Proses Laporan Bulan Ini</span>
        </button>

        <div class="mt-6 bg-white p-6 rounded-lg shadow">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-lg font-semibold">Rekap Keuangan Bulan {{ new Date().toLocaleString('default', { month: 'long' }) }}</h2>
          </div>
          <table class="w-full border-collapse border border-gray-300">
            <thead>
              <tr>
                <th class="border border-gray-300 p-2">No</th>
                <th class="border border-gray-300 p-2">Partner</th>
                <th class="border border-gray-300 p-2">Total Penjualan</th>
                <th class="border border-gray-300 p-2">Total Precentase</th>
                <th class="border border-gray-300 p-2">Profit</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(partner, index) in salesByKlinik" :key="partner.partner_id">
                <td class="border border-gray-300 p-2">{{ index + 1 }}</td>
                <td class="border border-gray-300 p-2">{{ partner.partner_name }}</td>
                <td class="border border-gray-300 p-2">{{  $formatRupiah(partner.totalPurchase) }}</td>
                <td class="border border-gray-300 p-2">{{  $formatRupiah(partner.total) }}</td>
                <td class="border border-gray-300 p-2">{{  $formatRupiah(partner.profit) }}</td>
              </tr>
              <tr v-if="rekap.totalPurchase > 0">
                <td class="border border-gray-300 p-2" colspan="2">Total</td>
         
                <td class="border border-gray-300 p-2">{{  $formatRupiah(rekap.totalPurchase) }}</td>
                <td class="border border-gray-300 p-2">{{  $formatRupiah(rekap.total) }}</td>
                <td class="border border-gray-300 p-2">{{  $formatRupiah(rekap.profit) }}</td>
              </tr>
            </tbody>
            

          </table>
        </div>
    
    </div>
  </template>
  
  <script setup>
  const client = useSupabaseClient()
  
  const salesByKlinik = ref({})
  const rekap = ref({})
  import { useUserRole } from '~/composables/useUserRole';
  const role = ref('guest');


  const processReport = async () => {
    console.log('Processing report...');
    await fetchReportData();
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


        
     
  
            //get partner name
      const { data: partners } = await client.from('partners').select('*')
      const result = sales.reduce((acc, sale) => {
    // Cek apakah partner_id sudah ada di accumulator
    let partner = acc.find(p => p.partner_id === sale.partner_id);
    
    const precentase = partners.find(partner => partner.id === sale.partner_id)?.persentase ? partners.find(partner => partner.id === sale.partner_id).persentase / 100 : 0
    const partnerName = partners.find(partner => partner.id === sale.partner_id)?.name
    if (!partner) {
        partner = {
            partner_id: sale.partner_id,
            sale_items: [],
            precentase: precentase,
            partner_name: partnerName
        };
        acc.push(partner);
    }

    sale.sale_items.forEach(item => {
        let product = partner.sale_items.find(p => p.product_id === item.product_id);

        if (!product) {
            product = {
                product_id: item.product_id,
                product_name: item.product.name,
                hpp: item.product.hpp,
                total: 0,
                totalPurchase: 0
            };
            partner.sale_items.push(product);
        }

        product.total += (item.price * item.quantity) * precentase;
        product.totalPurchase += item.price * item.quantity;
    });

    return acc;
  }, []);
  let tempRekap = {
    totalPurchase: 0,
    total: 0,
    profit: 0
  };
    result.forEach(partner => {
      partner.profit = 0
      partner.totalPurchase = 0
      partner.total = 0
      partner.sale_items.forEach(product => {
        product.profit =  product.total - product.hpp;
        if (product.profit < 0) product.profit = 0; // Pastikan tidak negatif
        partner.profit += product.profit;
        partner.totalPurchase += product.totalPurchase;
        partner.total += product.total;
      });
      tempRekap.totalPurchase += partner.totalPurchase;
      tempRekap.total += partner.total;
      tempRekap.profit += partner.profit;
    });

    salesByKlinik.value = result;
    rekap.value = tempRekap;
    console.log(rekap);
    
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