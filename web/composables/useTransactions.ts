import type { Transaction } from '~/types/models'
import { SyncStatus } from '~/types/enums'
import type { RealtimeChannel } from '@supabase/supabase-js'

interface CreateTransactionData {
  accountId: string
  categoryId: string
  amount: number
  date: string
  note?: string | null
  recurringId?: string | null
}

interface UpdateTransactionData {
  accountId?: string
  categoryId?: string
  amount?: number
  date?: string
  note?: string | null
}

interface FetchTransactionsOptions {
  accountId?: string | null
  startDate?: string | null
  endDate?: string | null
  page?: number
  pageSize?: number
}

const PAGE_SIZE = 30

/**
 * Mapping Supabase snake_case → TypeScript camelCase
 */
function mapTransaction(row: any): Transaction {
  return {
    id: row.id,
    userId: row.user_id,
    accountId: row.account_id,
    categoryId: row.category_id,
    amount: row.amount,
    rawAmount: String(row.amount),
    date: row.date,
    note: row.note,
    rawNote: row.note,
    recurringId: row.recurring_id,
    isEncrypted: row.is_encrypted ?? false,
    syncStatus: row.sync_status ?? SyncStatus.SYNCED,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

/**
 * Composable transactions — logique métier.
 *
 * Porte tous les appels Supabase transactions,
 * la gestion d'erreurs, le temps réel et la mise à jour du store.
 */
export function useTransactions() {
  const store = useTransactionsStore()
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  let realtimeChannel: RealtimeChannel | null = null

  /**
   * Récupère les transactions avec filtres et pagination
   */
  async function fetchTransactions(options: FetchTransactionsOptions = {}): Promise<void> {
    if (!user.value) return

    const page = options.page ?? 0
    const pageSize = options.pageSize ?? PAGE_SIZE
    const isFirstPage = page === 0

    if (isFirstPage) {
      store.setLoading(true)
    }
    store.setError(null)

    try {
      let query = supabase
        .from('transactions')
        .select('*')
        .eq('user_id', user.value.id)
        .order('date', { ascending: false })
        .order('created_at', { ascending: false })
        .range(page * pageSize, (page + 1) * pageSize - 1)

      if (options.accountId) {
        query = query.eq('account_id', options.accountId)
      }

      if (options.startDate) {
        query = query.gte('date', options.startDate)
      }

      if (options.endDate) {
        query = query.lte('date', options.endDate)
      }

      const { data, error } = await query

      if (error) throw error

      const mapped = (data ?? []).map(mapTransaction)

      if (isFirstPage) {
        store.setTransactions(mapped)
      } else {
        store.appendTransactions(mapped)
      }

      store.setCurrentPage(page)
      store.setHasMore(mapped.length >= pageSize)
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors du chargement des transactions')
    } finally {
      if (isFirstPage) {
        store.setLoading(false)
      }
    }
  }

  /**
   * Récupère toutes les transactions sans pagination (pour les statistiques)
   */
  async function fetchAllTransactions(): Promise<void> {
    if (!user.value) return

    store.setLoading(true)
    store.setError(null)

    try {
      const { data, error } = await supabase
        .from('transactions')
        .select('*')
        .eq('user_id', user.value.id)
        .order('date', { ascending: false })
        .order('created_at', { ascending: false })

      if (error) throw error

      store.setTransactions((data ?? []).map(mapTransaction))
      store.setHasMore(false)
      store.setCurrentPage(0)
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors du chargement des transactions')
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Charge la page suivante
   */
  async function fetchNextPage(options: Omit<FetchTransactionsOptions, 'page'> = {}): Promise<void> {
    if (!store.hasMore) return
    await fetchTransactions({ ...options, page: store.currentPage + 1 })
  }

  /**
   * Crée une nouvelle transaction
   */
  async function createTransaction(data: CreateTransactionData): Promise<Transaction | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const { data: row, error } = await supabase
        .from('transactions')
        .insert({
          user_id: user.value.id,
          account_id: data.accountId,
          category_id: data.categoryId,
          amount: data.amount,
          date: data.date,
          note: data.note ?? null,
          recurring_id: data.recurringId ?? null,
          is_encrypted: false,
          sync_status: SyncStatus.SYNCED,
        })
        .select()
        .single()

      if (error) throw error

      const transaction = mapTransaction(row)
      store.addTransaction(transaction)
      return transaction
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la création de la transaction')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Met à jour une transaction existante
   */
  async function updateTransaction(id: string, data: UpdateTransactionData): Promise<Transaction | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const updateData: Record<string, any> = {}
      if (data.accountId !== undefined) updateData.account_id = data.accountId
      if (data.categoryId !== undefined) updateData.category_id = data.categoryId
      if (data.amount !== undefined) updateData.amount = data.amount
      if (data.date !== undefined) updateData.date = data.date
      if (data.note !== undefined) updateData.note = data.note

      const { data: row, error } = await supabase
        .from('transactions')
        .update(updateData)
        .eq('id', id)
        .eq('user_id', user.value.id)
        .select()
        .single()

      if (error) throw error

      const transaction = mapTransaction(row)
      store.updateTransaction(id, transaction)
      return transaction
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la mise à jour de la transaction')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Supprime une transaction
   */
  async function deleteTransaction(id: string): Promise<boolean> {
    if (!user.value) return false

    store.setLoading(true)
    store.setError(null)

    try {
      const { error } = await supabase
        .from('transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', user.value.id)

      if (error) throw error

      store.removeTransaction(id)
      return true
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la suppression de la transaction')
      return false
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Souscrit aux changements temps réel sur la table transactions
   */
  function subscribeRealtime(): void {
    if (!user.value || realtimeChannel) return

    realtimeChannel = supabase
      .channel('transactions-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'transactions',
          filter: `user_id=eq.${user.value.id}`,
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            store.addTransaction(mapTransaction(payload.new))
          } else if (payload.eventType === 'UPDATE') {
            const transaction = mapTransaction(payload.new)
            store.updateTransaction(transaction.id, transaction)
          } else if (payload.eventType === 'DELETE') {
            store.removeTransaction((payload.old as any).id)
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
    transactions: computed(() => store.transactions),
    recentTransactions: computed(() => store.recentTransactions),
    isLoading: computed(() => store.isLoading),
    error: computed(() => store.error),
    hasMore: computed(() => store.hasMore),
    transactionById: computed(() => store.transactionById),
    transactionsByAccount: computed(() => store.transactionsByAccount),
    transactionsByPeriod: computed(() => store.transactionsByPeriod),

    // Actions
    fetchTransactions,
    fetchAllTransactions,
    fetchNextPage,
    createTransaction,
    updateTransaction,
    deleteTransaction,
    subscribeRealtime,
    unsubscribeRealtime,
    resetStore: store.reset,
    setError: store.setError,
  }
}
