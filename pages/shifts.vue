<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Shifts</h1>
      <div class="flex gap-4">
        <button
          v-if="!activeShift"
          @click="startShift"
          class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          Mulai Shift
        </button>
        <button
          v-else
          @click="showEndShiftModal = true"
          class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700"
        >
          Akhiri Shift
        </button>
      </div>
    </div>

    <div class="bg-white rounded-lg shadow mb-6" v-if="activeShift">
      <div class="p-6">
        <h2 class="text-xl font-bold mb-4">Shift Aktif</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <p class="text-sm text-gray-600">Dibuat</p>
            <p class="text-lg font-semibold">
              {{ new Date(activeShift.start_time).toLocaleString() }}
            </p>
          </div>
          <div>
            <p class="text-sm text-gray-600">Saldo Awal</p>
            <p class="text-lg font-semibold">{{ $formatRupiah(activeShift.cash_start) }}</p>
          </div>
          <div>
            <p class="text-sm text-gray-600">Penjualan</p>
            <p class="text-lg font-semibold">{{ $formatRupiah(currentShiftSales) }}</p>
          </div>
        </div>
      </div>
    </div>

    <div class="bg-white rounded-lg shadow">
      <div class="p-4 border-b">
        <h2 class="text-lg font-semibold">Shift History</h2>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jam Mulai</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jam Selesai</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Saldo Awal</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Saldo Akhir</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total Penjualan</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="shift in shifts" :key="shift.id">
              <td class="px-6 py-4">{{ new Date(shift.start_time).toLocaleString() }}</td>
              <td class="px-6 py-4">
                {{ shift.end_time ? new Date(shift.end_time).toLocaleString() : '-' }}
              </td>
              <td class="px-6 py-4">{{ $formatRupiah(shift.cash_start) }}</td>
              <td class="px-6 py-4">
                {{ shift.cash_end ? $formatRupiah(shift.cash_end) : '-' }}
              </td>
              <td class="px-6 py-4">{{ $formatRupiah(shiftSales[shift.id]) }}</td>
              <td class="px-6 py-4 capitalize">
                <span
                  :class="{
                    'px-2 py-1 rounded-full text-xs font-medium': true,
                    'bg-green-100 text-green-800': shift.status === 'active',
                    'bg-gray-100 text-gray-800': shift.status === 'closed'
                  }"
                >
                  {{ shift.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- End Shift Modal -->
    <div v-if="showEndShiftModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Akhiri Shift</h2>
        <form @submit.prevent="endShift">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Saldo Awal</label>
              <p class="text-lg font-semibold">{{ $formatRupiah(activeShift.cash_start) }}</p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Penjualan</label>
              <p class="text-lg font-semibold">{{ $formatRupiah(currentShiftSales) }}</p>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700">Saldo Akhir</label>
              <p class="text-lg font-semibold">{{ $formatRupiah(endShiftForm.cash_end) }}</p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Catatan</label>
              <textarea
                v-model="endShiftForm.notes"
                class="mt-1 p-2 block w-full rounded-lg border-gray-300"
                rows="3"
              ></textarea>
            </div>
          </div>
          <div class="mt-6 flex justify-end gap-4">
            <button
              type="button"
              @click="showEndShiftModal = false"
              class="px-4 py-2 border rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
            >
              End Shift
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
const client = useSupabaseClient()
const user = useSupabaseUser()

const shifts = ref([])
const activeShift = ref(null)
const shiftSales = ref({})
const currentShiftSales = ref(0)
const showEndShiftModal = ref(false)
const endShiftForm = ref({
  cash_end: 0,
  notes: ''
})

const fetchShifts = async () => {
  const { data } = await client
    .from('shifts')
    .select('*')
    .eq('user_id', user.value.id)
    .order('start_time', { ascending: false })
  
  shifts.value = data || []
  
  // Find active shift
  activeShift.value = shifts.value.find(shift => shift.status === 'active')
  if(activeShift.value){
    endShiftForm.value.cash_end = activeShift.value.cash_start + currentShiftSales.value
  }
  
  // Fetch sales for each shift
  for (const shift of shifts.value) {
    const { data: salesData } = await client
      .from('sales')
      .select('total_amount')
      .eq('shift_id', shift.id)
    
    shiftSales.value[shift.id] = salesData?.reduce((sum, sale) => sum + sale.total_amount, 0) || 0
    
    if (shift.status === 'active') {
      currentShiftSales.value = shiftSales.value[shift.id]
    }
  }
}

const startShift = async () => {
  if (activeShift.value) return

  try {
    const { data, error } = await client
      .from('shifts')
      .insert({
        user_id: user.value.id,
        cash_start: 0,
        status: 'active'
      })
      .select()
      .single()
    
    if (error) throw error
    
    await fetchShifts()
  } catch (error) {
    console.error('Error starting shift:', error)
    alert('Error starting shift')
  }
}

const endShift = async () => {
  if (!activeShift.value) return

  try {
    await client
      .from('shifts')
      .update({
        end_time: new Date().toISOString(),
        cash_end: endShiftForm.value.cash_end,
        notes: endShiftForm.value.notes,
        status: 'closed'
      })
      .eq('id', activeShift.value.id)
    
    showEndShiftModal.value = false
    endShiftForm.value = {
      cash_end: 0,
      notes: ''
    }
    
    await fetchShifts()
  } catch (error) {
    console.error('Error ending shift:', error)
    alert('Error ending shift')
  }
}



onMounted(fetchShifts)
</script>