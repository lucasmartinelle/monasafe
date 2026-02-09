import { defineStore } from 'pinia'

/**
 * Store vault — état réactif pur.
 *
 * Pas de logique métier ni d'appels API ici.
 * Toute la logique est dans composables/useVault.ts.
 */
export const useVaultStore = defineStore('vault', () => {
  // State
  const isEnabled = ref(false)
  const isLocked = ref(true)
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  const dek = ref<Uint8Array | null>(null)

  // Getters
  const isUnlocked = computed(() => isEnabled.value && !isLocked.value)

  // Mutations
  function setEnabled(value: boolean) {
    isEnabled.value = value
  }

  function setLocked(value: boolean) {
    isLocked.value = value
  }

  function setLoading(value: boolean) {
    isLoading.value = value
  }

  function setError(value: string | null) {
    error.value = value
  }

  function setDek(value: Uint8Array) {
    dek.value = value
  }

  function clearDek() {
    dek.value = null
  }

  return {
    // State
    isEnabled,
    isLocked,
    isLoading,
    error,
    dek,

    // Getters
    isUnlocked,

    // Mutations
    setEnabled,
    setLocked,
    setLoading,
    setError,
    setDek,
    clearDek,
  }
})
