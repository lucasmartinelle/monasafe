/**
 * Middleware global de vérification de l'onboarding (AUTH-04).
 *
 * Vérifie que l'utilisateur authentifié a complété l'onboarding.
 * Le résultat est caché via useState pour éviter des requêtes à chaque navigation.
 */
export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()

  // Pas connecté → le module @nuxtjs/supabase gère la redirection
  if (!user.value) return

  // Routes exclues du check onboarding
  const isExcluded =
    to.path === '/' ||
    to.path.startsWith('/auth') ||
    to.path.startsWith('/onboarding')

  if (isExcluded) return

  // Cache du statut onboarding par userId (survit aux navigations)
  const onboardingStatus = useState<Record<string, boolean | null>>('onboarding-status', () => ({}))
  const uid = user.value.id

  // Si déjà vérifié et complété, on passe
  if (onboardingStatus.value[uid] === true) return

  // Si pas encore vérifié, on fetch
  if (onboardingStatus.value[uid] === undefined || onboardingStatus.value[uid] === null) {
    try {
      const supabase = useSupabaseClient()
      const { data } = await supabase
        .from('user_settings')
        .select('value')
        .eq('user_id', uid)
        .eq('key', 'onboarding_completed')
        .maybeSingle()

      onboardingStatus.value[uid] = data?.value === 'true'
    } catch {
      // Erreur réseau → on laisse passer pour ne pas bloquer
      return
    }
  }

  if (!onboardingStatus.value[uid]) {
    return navigateTo('/onboarding')
  }
})
