import type { Category } from '~/types/models'
import type { CategoryType } from '~/types/enums'
import type { RealtimeChannel } from '@supabase/supabase-js'

interface CreateCategoryData {
  name: string
  iconKey: string
  color: number
  type: CategoryType
  budgetLimit?: number | null
}

interface UpdateCategoryData {
  name?: string
  iconKey?: string
  color?: number
  type?: CategoryType
  budgetLimit?: number | null
}

/**
 * Mapping Supabase snake_case → TypeScript camelCase
 */
function mapCategory(row: any): Category {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    iconKey: row.icon_key,
    color: row.color,
    type: row.type,
    budgetLimit: row.budget_limit,
    isDefault: row.is_default,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

/**
 * Composable catégories — logique métier.
 *
 * Porte tous les appels Supabase categories,
 * la gestion d'erreurs, le temps réel et la mise à jour du store.
 */
export function useCategories() {
  const store = useCategoriesStore()
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  let realtimeChannel: RealtimeChannel | null = null

  /**
   * Récupère toutes les catégories de l'utilisateur (+ défaut)
   */
  async function fetchCategories(): Promise<void> {
    if (!user.value) return

    store.setLoading(true)
    store.setError(null)

    try {
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .or(`user_id.eq.${user.value.id},user_id.is.null`)
        .order('name')

      if (error) throw error

      store.setCategories((data ?? []).map(mapCategory))
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors du chargement des catégories')
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Crée une nouvelle catégorie personnalisée
   */
  async function createCategory(data: CreateCategoryData): Promise<Category | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const { data: row, error } = await supabase
        .from('categories')
        .insert({
          user_id: user.value.id,
          name: data.name,
          icon_key: data.iconKey,
          color: data.color,
          type: data.type,
          budget_limit: data.budgetLimit ?? null,
          is_default: false,
        })
        .select()
        .single()

      if (error) throw error

      const category = mapCategory(row)
      store.addCategory(category)
      return category
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la création de la catégorie')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Met à jour une catégorie existante (non default uniquement)
   */
  async function updateCategory(id: string, data: UpdateCategoryData): Promise<Category | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const updateData: Record<string, any> = {}
      if (data.name !== undefined) updateData.name = data.name
      if (data.iconKey !== undefined) updateData.icon_key = data.iconKey
      if (data.color !== undefined) updateData.color = data.color
      if (data.type !== undefined) updateData.type = data.type
      if (data.budgetLimit !== undefined) updateData.budget_limit = data.budgetLimit

      const { data: row, error } = await supabase
        .from('categories')
        .update(updateData)
        .eq('id', id)
        .eq('user_id', user.value.id)
        .select()
        .single()

      if (error) throw error

      const category = mapCategory(row)
      store.updateCategory(id, category)
      return category
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la mise à jour de la catégorie')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Supprime une catégorie (avec vérification des transactions liées)
   */
  async function deleteCategory(id: string): Promise<boolean> {
    if (!user.value) return false

    store.setLoading(true)
    store.setError(null)

    try {
      // Vérifier si c'est une catégorie par défaut
      const category = store.categoryById(id)
      if (category?.isDefault) {
        store.setError('Les catégories par défaut ne peuvent pas être supprimées.')
        return false
      }

      // Vérifier s'il y a des transactions liées
      const { count, error: countError } = await supabase
        .from('transactions')
        .select('id', { count: 'exact', head: true })
        .eq('category_id', id)

      if (countError) throw countError

      if (count && count > 0) {
        store.setError(`Cette catégorie est utilisée par ${count} transaction(s). Supprimez-les d'abord.`)
        return false
      }

      const { error } = await supabase
        .from('categories')
        .delete()
        .eq('id', id)
        .eq('user_id', user.value.id)

      if (error) throw error

      store.removeCategory(id)
      return true
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la suppression de la catégorie')
      return false
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Souscrit aux changements temps réel sur la table categories
   */
  function subscribeRealtime(): void {
    if (!user.value || realtimeChannel) return

    realtimeChannel = supabase
      .channel('categories-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'categories',
          filter: `user_id=eq.${user.value.id}`,
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            store.addCategory(mapCategory(payload.new))
          } else if (payload.eventType === 'UPDATE') {
            const category = mapCategory(payload.new)
            store.updateCategory(category.id, category)
          } else if (payload.eventType === 'DELETE') {
            store.removeCategory((payload.old as any).id)
          }
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
    categories: computed(() => store.categories),
    expenseCategories: computed(() => store.expenseCategories),
    incomeCategories: computed(() => store.incomeCategories),
    isLoading: computed(() => store.isLoading),
    error: computed(() => store.error),
    categoryById: computed(() => store.categoryById),

    // Actions
    fetchCategories,
    createCategory,
    updateCategory,
    deleteCategory,
    subscribeRealtime,
    unsubscribeRealtime,
    setError: store.setError,
  }
}
