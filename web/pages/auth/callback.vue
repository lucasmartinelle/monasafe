<script setup lang="ts">
/**
 * Page de callback OAuth.
 *
 * Après l'authentification Google, Supabase redirige ici.
 * Le module @nuxtjs/supabase gère automatiquement l'échange du code
 * via les cookies. On attend que l'utilisateur soit disponible,
 * puis on redirige vers le dashboard (le middleware onboarding
 * se chargera de rediriger vers /onboarding si nécessaire).
 */
definePageMeta({
  layout: 'blank',
})

const user = useSupabaseUser()

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
