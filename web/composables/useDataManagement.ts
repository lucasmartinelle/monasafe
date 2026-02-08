/**
 * Composable gestion des données — logique métier.
 *
 * Suppression ciblée ou totale des données utilisateur,
 * avec invalidation des stores correspondants.
 */
export function useDataManagement() {
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const transactionsStore = useTransactionsStore()
  const recurringStore = useRecurringStore()
  const accountsStore = useAccountsStore()
  const categoriesStore = useCategoriesStore()

  /**
   * Supprime toutes les transactions de l'utilisateur
   */
  async function deleteTransactions(): Promise<boolean> {
    if (!user.value) return false

    isLoading.value = true
    error.value = null

    try {
      const { error: err } = await supabase
        .from('transactions')
        .delete()
        .eq('user_id', user.value.id)

      if (err) throw err

      transactionsStore.reset()
      return true
    } catch (e: any) {
      error.value = e.message || 'Erreur lors de la suppression des transactions'
      return false
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Supprime toutes les récurrences de l'utilisateur
   */
  async function deleteRecurrings(): Promise<boolean> {
    if (!user.value) return false

    isLoading.value = true
    error.value = null

    try {
      // D'abord détacher les transactions liées
      await supabase
        .from('transactions')
        .update({ recurring_id: null })
        .eq('user_id', user.value.id)
        .not('recurring_id', 'is', null)

      const { error: err } = await supabase
        .from('recurring_transactions')
        .delete()
        .eq('user_id', user.value.id)

      if (err) throw err

      recurringStore.setRecurrings([])
      return true
    } catch (e: any) {
      error.value = e.message || 'Erreur lors de la suppression des récurrences'
      return false
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Supprime tous les budgets de l'utilisateur
   */
  async function deleteBudgets(): Promise<boolean> {
    if (!user.value) return false

    isLoading.value = true
    error.value = null

    try {
      const { error: err } = await supabase
        .from('user_budgets')
        .delete()
        .eq('user_id', user.value.id)

      if (err) throw err

      return true
    } catch (e: any) {
      error.value = e.message || 'Erreur lors de la suppression des budgets'
      return false
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Supprime TOUTES les données de l'utilisateur
   * Ordre : transactions → récurrences → budgets → comptes → catégories custom
   */
  async function deleteAllData(): Promise<boolean> {
    if (!user.value) return false

    isLoading.value = true
    error.value = null

    try {
      // 1. Transactions
      const { error: e1 } = await supabase
        .from('transactions')
        .delete()
        .eq('user_id', user.value.id)
      if (e1) throw e1

      // 2. Récurrences
      const { error: e2 } = await supabase
        .from('recurring_transactions')
        .delete()
        .eq('user_id', user.value.id)
      if (e2) throw e2

      // 3. Budgets
      const { error: e3 } = await supabase
        .from('user_budgets')
        .delete()
        .eq('user_id', user.value.id)
      if (e3) throw e3

      // 4. Comptes
      const { error: e4 } = await supabase
        .from('accounts')
        .delete()
        .eq('user_id', user.value.id)
      if (e4) throw e4

      // 5. Catégories personnalisées (pas les default)
      const { error: e5 } = await supabase
        .from('categories')
        .delete()
        .eq('user_id', user.value.id)
      if (e5) throw e5

      // Reset tous les stores
      transactionsStore.reset()
      recurringStore.setRecurrings([])
      accountsStore.setAccounts([])
      categoriesStore.setCategories(
        categoriesStore.categories.filter(c => c.isDefault),
      )

      return true
    } catch (e: any) {
      error.value = e.message || 'Erreur lors de la suppression des données'
      return false
    } finally {
      isLoading.value = false
    }
  }

  return {
    isLoading: computed(() => isLoading.value),
    error: computed(() => error.value),
    deleteTransactions,
    deleteRecurrings,
    deleteBudgets,
    deleteAllData,
  }
}
