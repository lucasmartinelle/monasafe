import type { RecurringTransaction } from '~/types/models'
import { SyncStatus } from '~/types/enums'
import type { RealtimeChannel } from '@supabase/supabase-js'
import { clampDayToMonth, toISODateString } from '~/utils/dates'
import { addMonths, startOfMonth, endOfMonth, isBefore, isAfter, parseISO } from 'date-fns'

interface CreateRecurringData {
  accountId: string
  categoryId: string
  amount: number
  note?: string | null
  originalDay: number
  startDate: string
  endDate?: string | null
  lastGenerated?: string | null
}

interface UpdateRecurringData {
  accountId?: string
  categoryId?: string
  amount?: number
  note?: string | null
  originalDay?: number
  startDate?: string
  endDate?: string | null
  isActive?: boolean
}

/**
 * Mapping Supabase snake_case → TypeScript camelCase
 */
function mapRecurring(row: any): RecurringTransaction {
  return {
    id: row.id,
    userId: row.user_id,
    accountId: row.account_id,
    categoryId: row.category_id,
    amount: row.amount,
    rawAmount: String(row.amount),
    note: row.note,
    rawNote: row.note,
    originalDay: row.original_day,
    startDate: row.start_date,
    endDate: row.end_date,
    lastGenerated: row.last_generated,
    isActive: row.is_active,
    isEncrypted: row.is_encrypted ?? false,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

/**
 * Composable récurrences — logique métier.
 *
 * Porte tous les appels Supabase recurring_transactions,
 * la gestion d'erreurs, le temps réel, la génération automatique
 * et la mise à jour du store.
 */
export function useRecurring() {
  const store = useRecurringStore()
  const supabase = useSupabaseClient<any>()
  const user = useSupabaseUser()

  let realtimeChannel: RealtimeChannel | null = null

  /**
   * Récupère toutes les récurrences de l'utilisateur
   */
  async function fetchRecurrings(): Promise<void> {
    if (!user.value) return

    store.setLoading(true)
    store.setError(null)

    try {
      const { data, error } = await supabase
        .from('recurring_transactions')
        .select('*')
        .eq('user_id', user.value.id)
        .order('created_at', { ascending: false })

      if (error) throw error

      store.setRecurrings((data ?? []).map(mapRecurring))
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors du chargement des récurrences')
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Crée une nouvelle récurrence
   */
  async function createRecurring(data: CreateRecurringData): Promise<RecurringTransaction | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const { data: row, error } = await supabase
        .from('recurring_transactions')
        .insert({
          user_id: user.value.id,
          account_id: data.accountId,
          category_id: data.categoryId,
          amount: data.amount,
          note: data.note ?? null,
          original_day: data.originalDay,
          start_date: data.startDate,
          end_date: data.endDate ?? null,
          last_generated: data.lastGenerated ?? null,
          is_active: true,
          is_encrypted: false,
        })
        .select()
        .single()

      if (error) throw error

      const recurring = mapRecurring(row)
      store.addRecurring(recurring)
      return recurring
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la création de la récurrence')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Met à jour une récurrence existante
   */
  async function updateRecurring(id: string, data: UpdateRecurringData): Promise<RecurringTransaction | null> {
    if (!user.value) return null

    store.setLoading(true)
    store.setError(null)

    try {
      const updateData: Record<string, any> = {}
      if (data.accountId !== undefined) updateData.account_id = data.accountId
      if (data.categoryId !== undefined) updateData.category_id = data.categoryId
      if (data.amount !== undefined) updateData.amount = data.amount
      if (data.note !== undefined) updateData.note = data.note
      if (data.originalDay !== undefined) updateData.original_day = data.originalDay
      if (data.startDate !== undefined) updateData.start_date = data.startDate
      if (data.endDate !== undefined) updateData.end_date = data.endDate
      if (data.isActive !== undefined) updateData.is_active = data.isActive

      const { data: row, error } = await supabase
        .from('recurring_transactions')
        .update(updateData)
        .eq('id', id)
        .eq('user_id', user.value.id)
        .select()
        .single()

      if (error) throw error

      const recurring = mapRecurring(row)
      store.updateRecurring(id, recurring)
      return recurring
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la mise à jour de la récurrence')
      return null
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Active/désactive une récurrence
   */
  async function toggleActive(id: string): Promise<RecurringTransaction | null> {
    const recurring = store.recurringById(id)
    if (!recurring) return null
    return updateRecurring(id, { isActive: !recurring.isActive })
  }

  /**
   * Supprime une récurrence (détache les transactions liées : recurring_id = null)
   */
  async function deleteRecurring(id: string): Promise<boolean> {
    if (!user.value) return false

    store.setLoading(true)
    store.setError(null)

    try {
      // Détacher les transactions liées (REC-07)
      await supabase
        .from('transactions')
        .update({ recurring_id: null })
        .eq('recurring_id', id)
        .eq('user_id', user.value.id)

      const { error } = await supabase
        .from('recurring_transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', user.value.id)

      if (error) throw error

      store.removeRecurring(id)
      return true
    } catch (e: any) {
      store.setError(e.message || 'Erreur lors de la suppression de la récurrence')
      return false
    } finally {
      store.setLoading(false)
    }
  }

  /**
   * Calcule la prochaine date de génération pour une récurrence
   */
  function calculateNextDate(recurring: RecurringTransaction): Date | null {
    if (!recurring.isActive) return null

    const now = new Date()
    let checkDate: Date

    if (recurring.lastGenerated) {
      // Mois suivant la dernière génération
      checkDate = addMonths(parseISO(recurring.lastGenerated), 1)
      checkDate = startOfMonth(checkDate)
    } else {
      checkDate = parseISO(recurring.startDate)
    }

    // Appliquer le jour original avec clamping (REC-02, REC-03)
    const nextDate = clampDayToMonth(recurring.originalDay, checkDate)

    // Vérifier end_date
    if (recurring.endDate && isAfter(nextDate, parseISO(recurring.endDate))) {
      return null
    }

    return nextDate
  }

  /**
   * Génère les transactions en attente pour toutes les récurrences actives.
   * Appelé au démarrage de l'app et à chaque resume (REC-04).
   */
  async function generatePendingTransactions(): Promise<number> {
    if (!user.value) return 0

    const activeRecurrings = store.activeRecurrings
    const now = new Date()
    let generated = 0

    for (const recurring of activeRecurrings) {
      let lastGen = recurring.lastGenerated
        ? parseISO(recurring.lastGenerated)
        : null

      // Point de départ : mois suivant lastGenerated ou startDate
      let checkMonth = lastGen
        ? addMonths(startOfMonth(lastGen), 1)
        : startOfMonth(parseISO(recurring.startDate))

      // Générer mois par mois jusqu'à maintenant
      while (!isAfter(checkMonth, now)) {
        const txDate = clampDayToMonth(recurring.originalDay, checkMonth)

        // Ne pas générer dans le futur
        if (isAfter(txDate, now)) break

        // Vérifier end_date
        if (recurring.endDate && isAfter(txDate, parseISO(recurring.endDate))) break

        // Ne pas re-générer si déjà fait pour ce mois
        if (lastGen) {
          const lastGenMonth = startOfMonth(lastGen)
          const txMonth = startOfMonth(txDate)
          if (!isAfter(txMonth, lastGenMonth)) {
            checkMonth = addMonths(checkMonth, 1)
            continue
          }
        }

        try {
          // Créer la transaction
          const { error: insertError } = await supabase
            .from('transactions')
            .insert({
              user_id: user.value!.id,
              account_id: recurring.accountId,
              category_id: recurring.categoryId,
              amount: recurring.amount,
              date: toISODateString(txDate),
              note: recurring.note,
              recurring_id: recurring.id,
              is_encrypted: recurring.isEncrypted,
              sync_status: SyncStatus.SYNCED,
            })

          if (insertError) throw insertError

          // Mettre à jour last_generated (REC-05)
          const txDateStr = toISODateString(txDate)
          await supabase
            .from('recurring_transactions')
            .update({ last_generated: txDateStr })
            .eq('id', recurring.id)
            .eq('user_id', user.value!.id)

          store.updateRecurring(recurring.id, { lastGenerated: txDateStr })
          lastGen = txDate
          generated++
        } catch (e: any) {
          console.error(`Erreur génération récurrence ${recurring.id}:`, e.message)
        }

        checkMonth = addMonths(checkMonth, 1)
      }
    }

    return generated
  }

  /**
   * Souscrit aux changements temps réel
   */
  function subscribeRealtime(): void {
    if (!user.value || realtimeChannel) return

    realtimeChannel = supabase
      .channel('recurring-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'recurring_transactions',
          filter: `user_id=eq.${user.value.id}`,
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            store.addRecurring(mapRecurring(payload.new))
          } else if (payload.eventType === 'UPDATE') {
            const recurring = mapRecurring(payload.new)
            store.updateRecurring(recurring.id, recurring)
          } else if (payload.eventType === 'DELETE') {
            store.removeRecurring((payload.old as any).id)
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
    recurrings: computed(() => store.recurrings),
    activeRecurrings: computed(() => store.activeRecurrings),
    inactiveRecurrings: computed(() => store.inactiveRecurrings),
    isLoading: computed(() => store.isLoading),
    error: computed(() => store.error),
    recurringById: computed(() => store.recurringById),

    // Actions
    fetchRecurrings,
    createRecurring,
    updateRecurring,
    toggleActive,
    deleteRecurring,
    calculateNextDate,
    generatePendingTransactions,
    subscribeRealtime,
    unsubscribeRealtime,
    setError: store.setError,
  }
}
