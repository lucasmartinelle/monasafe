/**
 * Middleware "guest only" — redirige vers /dashboard si déjà authentifié.
 * À appliquer sur les pages qui ne doivent être accessibles qu'aux visiteurs non connectés.
 */
export default defineNuxtRouteMiddleware(() => {
  const user = useSupabaseUser()

  if (user.value) {
    return navigateTo('/dashboard')
  }
})
