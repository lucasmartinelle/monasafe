import { defineStore } from 'pinia'
import type { UserBudget } from '~/types/models'

/**
 * Store budgets — état réactif pur.
 *
 * Pas de logique métier ni d'appels API ici.
 * Toute la logique est dans composables/useBudgets.ts.
 */
export const useBudgetsStore = defineStore('budgets', () => {
  // State
  const budgets = ref<UserBudget[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const budgetByCategory = computed(() => (categoryId: string) =>
    budgets.value.find(b => b.categoryId === categoryId) ?? null,
  )

  // Mutations
  function setBudgets(value: UserBudget[]) {
    budgets.value = value
  }

  function upsertBudget(budget: UserBudget) {
    const index = budgets.value.findIndex(b => b.id === budget.id)
    if (index !== -1) {
      budgets.value[index] = budget
    } else {
      budgets.value.push(budget)
    }
  }

  function removeBudget(id: string) {
    budgets.value = budgets.value.filter(b => b.id !== id)
  }

  function setLoading(value: boolean) {
    isLoading.value = value
  }

  function setError(message: string | null) {
    error.value = message
  }

  function reset() {
    budgets.value = []
    error.value = null
  }

  return {
    // State
    budgets,
    isLoading,
    error,

    // Getters
    budgetByCategory,

    // Mutations
    setBudgets,
    upsertBudget,
    removeBudget,
    setLoading,
    setError,
    reset,
  }
})
