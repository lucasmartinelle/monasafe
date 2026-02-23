import type { Account } from '~/types/models'
import { type AccountType, CategoryType } from '~/types/enums'
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
  const categoriesStore = useCategoriesStore()

  let realtimeChannel: RealtimeChannel | null = null

  // Soldes calculés à partir des transactions (toutes, y compris futures)
  const computedBalances = ref<Record<string, number>>({})
  // Soldes réels : transactions jusqu'à aujourd'hui inclus uniquement
  const realComputedBalances = ref<Record<string, number>>({})

  const totalComputedBalance = computed(() =>
    Object.values(computedBalances.value).reduce((sum, b) => sum + b, 0),
  )

  const totalRealComputedBalance = computed(() =>
    Object.values(realComputedBalances.value).reduce((sum, b) => sum + b, 0),
  )

  /**
   * Calcule les soldes réels de chaque compte à partir des transactions.
   * Formule : solde initial (DB) + somme(revenus) - somme(dépenses)
   *
   * Les transactions chiffrées sont déchiffrées si le vault est déverrouillé,
   * sinon elles sont ignorées (montant inconnu).
   */
  async function refreshComputedBalances(): Promise<void> {
    if (!user.value) return

    const vault = useVault()
    // Date locale (pas UTC) pour ne pas décaler d'un jour selon le fuseau horaire
    const now = new Date()
    const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`

    try {
      // Deux requêtes en parallèle :
      // 1. Toutes les transactions → solde prévisionnel
      // 2. Transactions ≤ aujourd'hui (filtre serveur) → solde réel
      const [{ data: allData, error: allError }, { data: realData }] = await Promise.all([
        supabase
          .from('transactions')
          .select('account_id, amount, category_id, is_encrypted')
          .eq('user_id', user.value.id),
        supabase
          .from('transactions')
          .select('account_id, amount, category_id, is_encrypted')
          .eq('user_id', user.value.id)
          .lte('date', today),
      ])

      if (allError || !allData) return

      const computeNet = async (rows: typeof allData): Promise<Record<string, number>> => {
        const net: Record<string, number> = {}
        for (const row of rows) {
          let amount: number
          if (row.is_encrypted) {
            if (!vault.isUnlocked.value) continue
            const decrypted = await vault.decryptTransactionData(String(row.amount), null)
            amount = decrypted.amount
          } else {
            amount = parseFloat(String(row.amount)) || 0
          }
          const cat = categoriesStore.categoryById(row.category_id)
          const signed = cat?.type === CategoryType.EXPENSE ? -amount : amount
          net[row.account_id] = (net[row.account_id] ?? 0) + signed
        }
        return net
      }

      const [netByAccount, realNetByAccount] = await Promise.all([
        computeNet(allData),
        computeNet(realData ?? allData),
      ])

      const result: Record<string, number> = {}
      const realResult: Record<string, number> = {}
      for (const account of store.accounts) {
        result[account.id] = account.balance + (netByAccount[account.id] ?? 0)
        realResult[account.id] = account.balance + (realNetByAccount[account.id] ?? 0)
      }

      computedBalances.value = result
      realComputedBalances.value = realResult
    } catch {
      // En cas d'erreur, on utilise les soldes bruts
    }
  }

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
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors du chargement des comptes')
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
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors de la création du compte')
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
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors de la mise à jour du compte')
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
    } catch (e: unknown) {
      store.setError(e instanceof Error ? e.message : 'Erreur lors de la suppression du compte')
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
            store.removeAccount((payload.old as Record<string, string>).id)
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
    computedBalances,
    realComputedBalances,
    totalComputedBalance,
    totalRealComputedBalance,
    selectedAccountId: computed(() => store.selectedAccountId),
    isLoading: computed(() => store.isLoading),
    error: computed(() => store.error),
    accountById: computed(() => store.accountById),

    // Actions
    fetchAccounts,
    createAccount,
    updateAccount,
    deleteAccount,
    refreshComputedBalances,
    subscribeRealtime,
    unsubscribeRealtime,
    setSelectedAccountId: store.setSelectedAccountId,
    setError: store.setError,
  }
}
