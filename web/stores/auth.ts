import { defineStore } from 'pinia'

/**
 * Store d'authentification — état réactif pur.
 *
 * Pas de logique métier ni d'appels API ici.
 * Toute la logique est dans composables/useAuth.ts.
 */
export const useAuthStore = defineStore('auth', () => {
  const user = useSupabaseUser()

  // State
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const isAuthenticated = computed(() => !!user.value)
  const isAnonymous = computed(() => user.value?.is_anonymous ?? false)
  const userId = computed(() => user.value?.id ?? null)
  const userEmail = computed(() => user.value?.email ?? null)
  const hasGoogleProvider = computed(() =>
    user.value?.identities?.some((i) => i.provider === 'google') ?? false,
  )

  // Mutations
  function setLoading(value: boolean) {
    isLoading.value = value
  }

  function setError(message: string | null) {
    error.value = message
  }

  function clearError() {
    error.value = null
  }

  return {
    // State
    user,
    isLoading,
    error,

    // Getters
    isAuthenticated,
    isAnonymous,
    userId,
    userEmail,
    hasGoogleProvider,

    // Mutations
    setLoading,
    setError,
    clearError,
  }
})
