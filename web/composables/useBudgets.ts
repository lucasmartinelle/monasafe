import type { UserBudget } from '~/types/models'
import type { RealtimeChannel } from '@supabase/supabase-js'

/**
 * Mapping Supabase snake_case → TypeScript camelCase
 */
function mapBudget(row: any): UserBudget {
  return {
    id: row.id,
    userId: row.user_id,
    categoryId: row.category_id,
    budgetLimit: Number(row.budget_limit),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

/**
 * Composable budgets — logique métier.
 *
 * Porte tous les appels Supabase user_budgets,
 * la gestion d'erreurs, le temps réel et la mise à jour du store.
 */
export function useBudgets() {
  const store = useBudgetsStore()
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  let realtimeChannel: RealtimeChannel | null = null

  /**
   * Récupère tous les budgets de l'utilisateur
   */
  async function fetchBudgets(): Promise<void> {
    if (!user.value) return

    store.setLoading(true)
    store.setError(null)

    try {
      const { data, error } = await supabase
        .from('user_budgets')
        .select('*')
        .eq('user_id', user.value.id)
        .order('created_at', { ascending: true })

      if (error) throw error

      store.setBudgets((data ?? []).map(mapBudget))
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors du chargement des budgets')
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Crée ou met à jour un budget (upsert sur user_id + category_id)
   */
  async function upsertBudget(categoryId: string, budgetLimit: number): Promise<UserBudget | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const { data, error } = await supabase
        .from('user_budgets')
        .upsert(
          {
            user_id: user.value.id,
            category_id: categoryId,
            budget_limit: budgetLimit,
          },
          { onConflict: 'user_id,category_id' },
        )
        .select()
        .single()

      if (error) throw error

      const budget = mapBudget(data)
      store.upsertBudget(budget)
      return budget
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors de la sauvegarde du budget')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Supprime un budget
   */
  async function deleteBudget(id: string): Promise<boolean> {
    if (!user.value) return false

    store.setLoading(true)
    store.setError(null)

    try {
      const { error } = await supabase
        .from('user_budgets')
        .delete()
        .eq('id', id)
        .eq('user_id', user.value.id)

      if (error) throw error

      store.removeBudget(id)
      return true
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors de la suppression du budget')
      return false
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Souscrit aux changements temps réel sur la table user_budgets
   */
  function subscribeRealtime(): void {
    if (!user.value || realtimeChannel) return

    realtimeChannel = supabase
      .channel('budgets-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'user_budgets',
          filter: `user_id=eq.${user.value.id}`,
        },
        () => {
          fetchBudgets()
        },
      )
      .subscribe()
  }

  /**
   * Se désabonne du channel temps réel
   */
  function unsubscribeRealtime(): void {
    if (realtimeChannel) {
      supabase.removeChannel(realtimeChannel)
      realtimeChannel = null
    }
  }

  return {
    // State (readonly, depuis le store)
    budgets: computed(() => store.budgets),
    isLoading: computed(() => store.isLoading),
    error: computed(() => store.error),
    budgetByCategory: computed(() => store.budgetByCategory),

    // Actions
    fetchBudgets,
    upsertBudget,
    deleteBudget,
    subscribeRealtime,
    unsubscribeRealtime,
    setError: store.setError,
  }
}
