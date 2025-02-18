<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="max-w-md w-full bg-white rounded-lg shadow-md p-8">
      <h2 class="text-2xl font-bold text-center mb-6">Login to Karunia Jaya Medika</h2>
      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700">Email</label>
          <input
            v-model="email"
            type="email"
            required
            class="mt-1 p-2 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700">Password</label>
          <input
            v-model="password"
            type="password"
            required
            class="mt-1 p-2 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
        <button
          type="submit"
          class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          Sign in
        </button>
        <div class="text-center text-sm text-gray-600">
          Don't have an account?
          <NuxtLink to="/auth/register" class="text-blue-600 hover:text-blue-500">
            Register
          </NuxtLink>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
const client = useSupabaseClient()
const router = useRouter()

const email = ref('')
const password = ref('')

const handleLogin = async () => {
  try {
    const { error } = await client.auth.signInWithPassword({
      email: email.value,
      password: password.value
    })
    if (error) throw error
    router.push('/')
  } catch (error) {
    console.error('Error:', error.message)
  }
}
</script>