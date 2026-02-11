<script setup lang="ts">
/**
 * Page de callback OAuth.
 *
 * Après l'authentification Google, Supabase redirige ici.
 * Le module @nuxtjs/supabase gère automatiquement l'échange du code
 * via les cookies. On attend que l'utilisateur soit disponible,
 * puis on redirige vers le dashboard (le middleware onboarding
 * se chargera de rediriger vers /onboarding si nécessaire).
 *
 * En cas d'erreur (ex: identity_already_exists après un linkIdentity),
 * on redirige vers /settings/accounts avec le contexte d'erreur.
 */
definePageMeta({
  layout: 'blank',
})

const route = useRoute()
const user = useSupabaseUser()

// Détecter les erreurs OAuth dans l'URL (query params ou hash fragment)
onMounted(() => {
  const hash = window.location.hash.substring(1)
  const hashParams = new URLSearchParams(hash)

  const error = (route.query.error as string) || hashParams.get('error')
  const errorCode = (route.query.error_code as string) || hashParams.get('error_code')
  const errorDesc = (route.query.error_description as string) || hashParams.get('error_description')

  if (errorCode === 'identity_already_exists') {
    navigateTo({ path: '/settings/accounts', query: { identity_conflict: 'true' } })
  } else if (error) {
    navigateTo({ path: '/settings/accounts', query: { auth_error: errorDesc || error } })
  }
})

watch(user, (newUser) => {
  if (newUser) {
    // Invalider le cache onboarding pour forcer un re-check
    const onboardingStatus = useState<Record<string, boolean | null>>('onboarding-status', () => ({}))
    onboardingStatus.value[newUser.id] = null

    navigateTo('/dashboard')
  }
}, { immediate: true })
</script>

<template>
  <div class="min-h-screen flex flex-col items-center justify-center bg-background-light dark:bg-background-dark gap-4">
    <CommonLoadingState />
    <p class="text-body-md text-gray-500 dark:text-gray-400">
      Connexion en cours...
    </p>
  </div>
</template>
