import type { Account } from '~/types/models'
import type { AccountType } from '~/types/enums'
import type { RealtimeChannel } from '@supabase/supabase-js'

interface CreateAccountData {
  name: string
  type: AccountType
  balance: number
  currency: string
  color: number
}

interface UpdateAccountData {
  name?: string
  type?: AccountType
  balance?: number
  color?: number
}

/**
 * Mapping Supabase snake_case → TypeScript camelCase
 */
function mapAccount(row: any): Account {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    type: row.type,
    balance: row.balance,
    currency: row.currency,
    color: row.color,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

/**
 * Composable comptes — logique métier.
 *
 * Porte tous les appels Supabase accounts,
 * la gestion d'erreurs, le temps réel et la mise à jour du store.
 */
export function useAccounts() {
  const store = useAccountsStore()
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  let realtimeChannel: RealtimeChannel | null = null

  /**
   * Récupère tous les comptes de l'utilisateur
   */
  async function fetchAccounts(): Promise<void> {
    if (!user.value) return

    store.setLoading(true)
    store.setError(null)

    try {
      const { data, error } = await supabase
        .from('accounts')
        .select('*')
        .eq('user_id', user.value.id)
        .order('name')

      if (error) throw error

      store.setAccounts((data ?? []).map(mapAccount))
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors du chargement des comptes')
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Crée un nouveau compte
   */
  async function createAccount(data: CreateAccountData): Promise<Account | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const { data: row, error } = await supabase
        .from('accounts')
        .insert({
          user_id: user.value.id,
          name: data.name,
          type: data.type,
          balance: data.balance,
          currency: data.currency,
          color: data.color,
        })
        .select()
        .single()

      if (error) throw error

      const account = mapAccount(row)
      store.addAccount(account)
      return account
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la création du compte')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Met à jour un compte existant
   */
  async function updateAccount(id: string, data: UpdateAccountData): Promise<Account | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const updateData: Record<string, any> = {}
      if (data.name !== undefined) updateData.name = data.name
      if (data.type !== undefined) updateData.type = data.type
      if (data.balance !== undefined) updateData.balance = data.balance
      if (data.color !== undefined) updateData.color = data.color

      const { data: row, error } = await supabase
        .from('accounts')
        .update(updateData)
        .eq('id', id)
        .eq('user_id', user.value.id)
        .select()
        .single()

      if (error) throw error

      const account = mapAccount(row)
      store.updateAccount(id, account)
      return account
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la mise à jour du compte')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Supprime un compte (avec vérification des transactions liées)
   */
  async function deleteAccount(id: string): Promise<boolean> {
    if (!user.value) return false

    store.setLoading(true)
    store.setError(null)

    try {
      // Vérifier s'il y a des transactions liées
      const { count, error: countError } = await supabase
        .from('transactions')
        .select('id', { count: 'exact', head: true })
        .eq('account_id', id)

      if (countError) throw countError

      if (count && count > 0) {
        store.setError(`Ce compte contient ${count} transaction(s). Supprimez-les d'abord.`)
        return false
      }

      const { error } = await supabase
        .from('accounts')
        .delete()
        .eq('id', id)
        .eq('user_id', user.value.id)

      if (error) throw error

      store.removeAccount(id)
      return true
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la suppression du compte')
      return false
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Souscrit aux changements temps réel sur la table accounts
   */
  function subscribeRealtime(): void {
    if (!user.value || realtimeChannel) return

    realtimeChannel = supabase
      .channel('accounts-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'accounts',
          filter: `user_id=eq.${user.value.id}`,
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            store.addAccount(mapAccount(payload.new))
          } else if (payload.eventType === 'UPDATE') {
            const account = mapAccount(payload.new)
            store.updateAccount(account.id, account)
          } else if (payload.eventType === 'DELETE') {
            store.removeAccount((payload.old as any).id)
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
    accounts: computed(() => store.accounts),
    sortedAccounts: computed(() => store.sortedAccounts),
    totalBalance: computed(() => store.totalBalance),
    selectedAccountId: computed(() => store.selectedAccountId),
    isLoading: computed(() => store.isLoading),
    error: computed(() => store.error),
    accountById: computed(() => store.accountById),

    // Actions
    fetchAccounts,
    createAccount,
    updateAccount,
    deleteAccount,
    subscribeRealtime,
    unsubscribeRealtime,
    setSelectedAccountId: store.setSelectedAccountId,
    setError: store.setError,
  }
}
