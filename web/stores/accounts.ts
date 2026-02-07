import { defineStore } from 'pinia'
import type { Account } from '~/types/models'

/**
 * Store comptes — état réactif pur.
 *
 * Pas de logique métier ni d'appels API ici.
 * Toute la logique est dans composables/useAccounts.ts.
 */
export const useAccountsStore = defineStore('accounts', () => {
  // State
  const accounts = ref<Account[]>([])
  const selectedAccountId = ref<string | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const totalBalance = computed(() =>
    accounts.value.reduce((sum, a) => sum + a.balance, 0),
  )

  const accountById = computed(() => (id: string) =>
    accounts.value.find(a => a.id === id) ?? null,
  )

  const sortedAccounts = computed(() =>
    [...accounts.value].sort((a, b) => a.name.localeCompare(b.name)),
  )

  // Mutations
  function setAccounts(value: Account[]) {
    accounts.value = value
  }

  function addAccount(account: Account) {
    accounts.value.push(account)
  }

  function updateAccount(id: string, data: Partial<Account>) {
    const index = accounts.value.findIndex(a => a.id === id)
    if (index !== -1) {
      accounts.value[index] = { ...accounts.value[index], ...data }
    }
  }

  function removeAccount(id: string) {
    accounts.value = accounts.value.filter(a => a.id !== id)
  }

  function setSelectedAccountId(id: string | null) {
    selectedAccountId.value = id
  }

  function setLoading(value: boolean) {
    isLoading.value = value
  }

  function setError(message: string | null) {
    error.value = message
  }

  return {
    // State
    accounts,
    selectedAccountId,
    isLoading,
    error,

    // Getters
    totalBalance,
    accountById,
    sortedAccounts,

    // Mutations
    setAccounts,
    addAccount,
    updateAccount,
    removeAccount,
    setSelectedAccountId,
    setLoading,
    setError,
  }
})
