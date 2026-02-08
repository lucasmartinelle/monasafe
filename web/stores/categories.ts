import { defineStore } from 'pinia'
import type { Category } from '~/types/models'
import { CategoryType } from '~/types/enums'

/**
 * Store catégories — état réactif pur.
 *
 * Pas de logique métier ni d'appels API ici.
 * Toute la logique est dans composables/useCategories.ts.
 */
export const useCategoriesStore = defineStore('categories', () => {
  // State
  const categories = ref<Category[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const expenseCategories = computed(() =>
    categories.value.filter(c => c.type === CategoryType.EXPENSE),
  )

  const incomeCategories = computed(() =>
    categories.value.filter(c => c.type === CategoryType.INCOME),
  )

  const categoryById = computed(() => (id: string) =>
    categories.value.find(c => c.id === id) ?? null,
  )

  // Mutations
  function setCategories(value: Category[]) {
    categories.value = value
  }

  function addCategory(category: Category) {
    categories.value.push(category)
  }

  function updateCategory(id: string, data: Partial<Category>) {
    const index = categories.value.findIndex(c => c.id === id)
    if (index !== -1) {
      categories.value[index] = { ...categories.value[index], ...data }
    }
  }

  function removeCategory(id: string) {
    categories.value = categories.value.filter(c => c.id !== id)
  }

  function setLoading(value: boolean) {
    isLoading.value = value
  }

  function setError(message: string | null) {
    error.value = message
  }

  return {
    // State
    categories,
    isLoading,
    error,

    // Getters
    expenseCategories,
    incomeCategories,
    categoryById,

    // Mutations
    setCategories,
    addCategory,
    updateCategory,
    removeCategory,
    setLoading,
    setError,
  }
})
