export default defineNuxtRouteMiddleware((to) => {
    const user = useSupabaseUser()
  
    // Allow access to auth pages
    if (to.path.startsWith('/auth')) {
      return
    }
  
    // Redirect to login if not authenticated
    if (!user.value) {
      return navigateTo('/auth/login')
    }
  })