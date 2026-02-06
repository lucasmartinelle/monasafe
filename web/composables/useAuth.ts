/**
 * Composable d'authentification — logique métier.
 *
 * Porte tous les appels Supabase Auth, la gestion d'erreurs,
 * la mise à jour du store et les redirections.
 */
export function useAuth() {
  const store = useAuthStore()
  const supabase = useSupabaseClient()
  const router = useRouter()

  /**
   * Connexion anonyme (AUTH-01) + redirect vers onboarding
   */
  async function signInAnonymous(): Promise<User | null> {
    store.setLoading(true)
    store.clearError()

    try {
      const { data, error } = await supabase.auth.signInAnonymously()
      if (error) throw error
      if (!data.user) throw new Error('Échec de la création du compte anonyme')

      await router.push('/onboarding')
      return data.user
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la connexion anonyme')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Connexion Google OAuth (redirige vers Google)
   */
  async function signInGoogle(): Promise<void> {
    store.setLoading(true)
    store.clearError()

    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/auth/callback`,
        },
      })
      if (error) throw error
      // La page se recharge via redirect Google, pas de setLoading(false)
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la connexion Google')
      store.setLoading(false)
    }
  }

  /**
   * Lier un compte Google à un compte anonyme (AUTH-02, AUTH-03)
   */
  async function linkGoogle(): Promise<void> {
    if (!store.isAnonymous) {
      store.setError('Seuls les comptes anonymes peuvent être liés')
      return
    }

    store.setLoading(true)
    store.clearError()

    try {
      const { error } = await supabase.auth.linkIdentity({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/auth/callback`,
        },
      })
      if (error) throw error
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la liaison Google')
      store.setLoading(false)
    }
  }

  /**
   * Déconnexion + redirect vers auth
   */
  async function signOut(): Promise<void> {
    store.setLoading(true)
    store.clearError()

    try {
      const { error } = await supabase.auth.signOut()
      if (error) throw error

      await router.push('/auth')
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la déconnexion')
    } finally {
      store.setLoading(false)
    }
  }

  return {
    // State (readonly, depuis le store)
    user: computed(() => store.user),
    isAuthenticated: computed(() => store.isAuthenticated),
    isAnonymous: computed(() => store.isAnonymous),
    isLoading: computed(() => store.isLoading),
    error: computed(() => store.error),
    userId: computed(() => store.userId),
    userEmail: computed(() => store.userEmail),
    hasGoogleProvider: computed(() => store.hasGoogleProvider),

    // Actions (logique métier)
    signInAnonymous,
    signInGoogle,
    linkGoogle,
    signOut,
    clearError: store.clearError,
  }
}
