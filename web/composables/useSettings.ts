/**
 * Composable settings — logique métier.
 *
 * Porte tous les appels Supabase user_settings,
 * la gestion d'erreurs et la mise à jour du store.
 */
export function useSettings() {
  const store = useSettingsStore()
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  /**
   * Charge les settings depuis user_settings
   */
  async function loadSettings(): Promise<void> {
    if (!user.value) return

    store.setLoading(true)

    try {
      const { data, error } = await supabase
        .from('user_settings')
        .select('key, value')
        .eq('user_id', user.value.id)

      if (error) throw error

      if (data) {
        for (const setting of data) {
          if (setting.key === 'currency') {
            store.setCurrency(setting.value)
          }
          if (setting.key === 'onboarding_completed') {
            store.setOnboardingCompleted(setting.value === 'true')
          }
        }
      }
    } catch (e: any) {
      console.error('Erreur chargement settings:', e.message)
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Met à jour un setting (upsert dans user_settings)
   */
  async function updateSetting(key: string, value: string): Promise<void> {
    if (!user.value) return

    try {
      const { error } = await supabase
        .from('user_settings')
        .upsert(
          { user_id: user.value.id, key, value },
          { onConflict: 'user_id,key' },
        )

      if (error) throw error

      if (key === 'currency') {
        store.setCurrency(value)
      }
    } catch (e: any) {
      console.error('Erreur mise à jour setting:', e.message)
    }
  }

  /**
   * Complète l'onboarding : persiste + invalide le cache useState
   */
  async function completeOnboarding(): Promise<void> {
    if (!user.value) return

    try {
      const { error } = await supabase
        .from('user_settings')
        .upsert(
          { user_id: user.value.id, key: 'onboarding_completed', value: 'true' },
          { onConflict: 'user_id,key' },
        )

      if (error) throw error

      store.setOnboardingCompleted(true)

      // Invalider le cache du middleware onboarding
      const onboardingStatus = useState<Record<string, boolean | null>>('onboarding-status')
      if (onboardingStatus.value) {
        onboardingStatus.value[user.value.id] = true
      }
    } catch (e: any) {
      console.error('Erreur complétion onboarding:', e.message)
    }
  }

  /**
   * Récupère un setting individuel par clé
   */
  async function getSetting(key: string): Promise<string | null> {
    if (!user.value) return null

    try {
      const { data, error } = await supabase
        .from('user_settings')
        .select('value')
        .eq('user_id', user.value.id)
        .eq('key', key)
        .maybeSingle()

      if (error) throw error
      return data?.value ?? null
    } catch (e: any) {
      console.error(`Erreur lecture setting "${key}":`, e.message)
      return null
    }
  }

  /**
   * Supprime un setting par clé
   */
  async function deleteSetting(key: string): Promise<void> {
    if (!user.value) return

    try {
      const { error } = await supabase
        .from('user_settings')
        .delete()
        .eq('user_id', user.value.id)
        .eq('key', key)

      if (error) throw error
    } catch (e: any) {
      console.error(`Erreur suppression setting "${key}":`, e.message)
    }
  }

  return {
    // State (readonly, depuis le store)
    currency: computed(() => store.currency),
    onboardingCompleted: computed(() => store.onboardingCompleted),
    isLoading: computed(() => store.isLoading),
    formattedCurrency: computed(() => store.formattedCurrency),

    // Actions
    loadSettings,
    updateSetting,
    getSetting,
    deleteSetting,
    completeOnboarding,
  }
}
