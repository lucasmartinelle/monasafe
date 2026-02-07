import { defineStore } from 'pinia'

/**
 * Store settings — état réactif pur.
 *
 * Pas de logique métier ni d'appels API ici.
 * Toute la logique est dans composables/useSettings.ts.
 */
export const useSettingsStore = defineStore('settings', () => {
  // State
  const currency = ref('EUR')
  const onboardingCompleted = ref(false)
  const isLoading = ref(false)

  // Getters
  const formattedCurrency = computed(() => {
    const labels: Record<string, string> = {
      USD: '$ U.S. Dollar',
      EUR: '€ Euro',
      GBP: '£ British Pound',
      CHF: 'Fr Swiss Franc',
    }
    return labels[currency.value] ?? currency.value
  })

  // Mutations
  function setCurrency(value: string) {
    currency.value = value
  }

  function setOnboardingCompleted(value: boolean) {
    onboardingCompleted.value = value
  }

  function setLoading(value: boolean) {
    isLoading.value = value
  }

  return {
    // State
    currency,
    onboardingCompleted,
    isLoading,

    // Getters
    formattedCurrency,

    // Mutations
    setCurrency,
    setOnboardingCompleted,
    setLoading,
  }
})
