import { defineStore } from 'pinia'
import type { Transaction } from '~/types/models'

/**
 * Store transactions — état réactif pur.
 *
 * Pas de logique métier ni d'appels API ici.
 * Toute la logique est dans composables/useTransactions.ts.
 */
export const useTransactionsStore = defineStore('transactions', () => {
  // State
  const transactions = ref<Transaction[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  const currentPage = ref(0)
  const hasMore = ref(true)

  // Getters
  const recentTransactions = computed(() =>
    [...transactions.value]
      .sort((a, b) => b.date.localeCompare(a.date) || b.createdAt.localeCompare(a.createdAt))
      .slice(0, 5),
  )

  const transactionsByAccount = computed(() => (accountId: string) =>
    transactions.value.filter(t => t.accountId === accountId),
  )

  const transactionsByPeriod = computed(() => (start: string, end: string) =>
    transactions.value.filter(t => t.date >= start && t.date <= end),
  )

  const transactionById = computed(() => (id: string) =>
    transactions.value.find(t => t.id === id) ?? null,
  )

  // Mutations
  function setTransactions(value: Transaction[]) {
    transactions.value = value
  }

  function appendTransactions(value: Transaction[]) {
    const existingIds = new Set(transactions.value.map(t => t.id))
    const newItems = value.filter(t => !existingIds.has(t.id))
    transactions.value.push(...newItems)
  }

  function addTransaction(transaction: Transaction) {
    transactions.value.push(transaction)
  }

  function updateTransaction(id: string, data: Partial<Transaction>) {
    const index = transactions.value.findIndex(t => t.id === id)
    if (index !== -1) {
      transactions.value[index] = { ...transactions.value[index], ...data }
    }
  }

  function removeTransaction(id: string) {
    transactions.value = transactions.value.filter(t => t.id !== id)
  }

  function setLoading(value: boolean) {
    isLoading.value = value
  }

  function setError(message: string | null) {
    error.value = message
  }

  function setCurrentPage(page: number) {
    currentPage.value = page
  }

  function setHasMore(value: boolean) {
    hasMore.value = value
  }

  function reset() {
    transactions.value = []
    currentPage.value = 0
    hasMore.value = true
    error.value = null
  }

  return {
    // State
    transactions,
    isLoading,
    error,
    currentPage,
    hasMore,

    // Getters
    recentTransactions,
    transactionsByAccount,
    transactionsByPeriod,
    transactionById,

    // Mutations
    setTransactions,
    appendTransactions,
    addTransaction,
    updateTransaction,
    removeTransaction,
    setLoading,
    setError,
    setCurrentPage,
    setHasMore,
    reset,
  }
})
