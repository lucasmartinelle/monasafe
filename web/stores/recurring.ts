import { defineStore } from 'pinia'
import type { RecurringTransaction } from '~/types/models'

/**
 * Store récurrences — état réactif pur.
 *
 * Pas de logique métier ni d'appels API ici.
 * Toute la logique est dans composables/useRecurring.ts.
 */
export const useRecurringStore = defineStore('recurring', () => {
  // State
  const recurrings = ref<RecurringTransaction[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const activeRecurrings = computed(() =>
    recurrings.value.filter(r => r.isActive),
  )

  const inactiveRecurrings = computed(() =>
    recurrings.value.filter(r => !r.isActive),
  )

  const recurringById = computed(() => (id: string) =>
    recurrings.value.find(r => r.id === id) ?? null,
  )

  // Mutations
  function setRecurrings(value: RecurringTransaction[]) {
    recurrings.value = value
  }

  function addRecurring(recurring: RecurringTransaction) {
    recurrings.value.push(recurring)
  }

  function updateRecurring(id: string, data: Partial<RecurringTransaction>) {
    const index = recurrings.value.findIndex(r => r.id === id)
    if (index !== -1) {
      recurrings.value[index] = { ...recurrings.value[index], ...data }
    }
  }

  function removeRecurring(id: string) {
    recurrings.value = recurrings.value.filter(r => r.id !== id)
  }

  function setLoading(value: boolean) {
    isLoading.value = value
  }

  function setError(message: string | null) {
    error.value = message
  }

  return {
    // State
    recurrings,
    isLoading,
    error,

    // Getters
    activeRecurrings,
    inactiveRecurrings,
    recurringById,

    // Mutations
    setRecurrings,
    addRecurring,
    updateRecurring,
    removeRecurring,
    setLoading,
    setError,
  }
})
