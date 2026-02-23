<script setup lang="ts">
import type { Transaction } from '~/types/models'
import { AccountType, CategoryType } from '~/types/enums'
import { PlusIcon } from '@heroicons/vue/24/outline'
import { getMonthRange, toISODateString, formatMonthYear, formatRelativeDate } from '~/utils/dates'
import { colorStyle } from '~/utils/colors'

useSeoMeta({
  title: 'Dashboard — Monasafe',
  description: 'Tableau de bord de vos finances : solde, transactions récentes et répartition des dépenses.',
})

definePageMeta({
  layout: 'default',
})

const router = useRouter()

const {
  sortedAccounts,
  fetchAccounts,
  accountById,
  computedBalances,
  totalComputedBalance,
  refreshComputedBalances,
  createAccount,
  isLoading: accountsLoading,
  error: accountsError,
  setError: setAccountsError,
  subscribeRealtime: subscribeAccounts,
  unsubscribeRealtime: unsubscribeAccounts,
} = useAccounts()

const { currency } = useCurrency()

// Modal création de compte
const showAccountCreateModal = ref(false)
const creatingAccountType = ref<AccountType | null>(null)

function openCreateAccount(type: AccountType) {
  creatingAccountType.value = type
  showAccountCreateModal.value = true
}

function closeAccountCreateModal() {
  showAccountCreateModal.value = false
  creatingAccountType.value = null
  setAccountsError(null)
}

async function handleCreateAccount(data: { name: string; type: AccountType; balance: number; color: number }) {
  const result = await createAccount({ ...data, currency: currency.value })
  if (result) {
    closeAccountCreateModal()
    refreshComputedBalances()
  }
}
const { fetchCategories, categoryById, subscribeRealtime: subscribeCategories, unsubscribeRealtime: unsubscribeCategories } = useCategories()
const {
  transactions,
  isLoading: txLoading,
  error: txError,
  hasMore,
  fetchTransactions,
  fetchNextPage,
  deleteTransaction,
  setError,
  subscribeRealtime: subscribeTransactions,
  unsubscribeRealtime: unsubscribeTransactions,
} = useTransactions()
const { calculateFinancialSummary, calculateCategoryStats } = useStatistics()
const { fetchRecurrings, generatePendingTransactions } = useRecurring()

// Période courante
const currentDate = ref(new Date())
const currentMonthLabel = computed(() => formatMonthYear(currentDate.value))

const currentRange = computed(() => {
  const { start, end } = getMonthRange(currentDate.value)
  return {
    startDate: toISODateString(start),
    endDate: toISODateString(end),
  }
})

// Filtre par compte
const selectedAccountId = ref<string | null>(null)

function selectAccount(accountId: string | null) {
  selectedAccountId.value = accountId
  // Recharger les transactions pour ce compte
  fetchTransactions({
    accountId: accountId,
    pageSize: PAGE_SIZE,
  })
  nextTick(() => setupInfiniteScroll())
}

// Données calculées (non filtrées)
const summary = computed(() => calculateFinancialSummary())

// Répartition dépenses (filtrée par compte si sélectionné)
const expenseStats = computed(() => {
  return calculateCategoryStats(
    currentRange.value.startDate,
    currentRange.value.endDate,
    CategoryType.EXPENSE,
    selectedAccountId.value,
  )
})

// Transactions groupées par date
const PAGE_SIZE = 20

const groupedTransactions = computed(() => {
  const groups: Record<string, Transaction[]> = {}

  const sorted = [...transactions.value].sort(
    (a, b) => b.date.localeCompare(a.date) || b.createdAt.localeCompare(a.createdAt),
  )

  for (const tx of sorted) {
    if (!groups[tx.date]) {
      groups[tx.date] = []
    }
    groups[tx.date].push(tx)
  }

  return Object.entries(groups).map(([date, items]) => ({
    date,
    transactions: items,
  }))
})

// Suppression
const deletingTransaction = ref<Transaction | null>(null)
const showDeleteConfirm = ref(false)

function confirmDelete(transaction: Transaction) {
  deletingTransaction.value = transaction
  showDeleteConfirm.value = true
}

async function handleDelete() {
  if (!deletingTransaction.value) return

  const success = await deleteTransaction(deletingTransaction.value.id)
  if (success) {
    showDeleteConfirm.value = false
    deletingTransaction.value = null
    refreshComputedBalances()
  }
}

function cancelDelete() {
  showDeleteConfirm.value = false
  deletingTransaction.value = null
  setError(null)
}

function editTransaction(transaction: Transaction) {
  router.push(`/transactions/${transaction.id}`)
}

// Scroll infini
const scrollSentinel = ref<HTMLElement | null>(null)
let observer: IntersectionObserver | null = null

function setupInfiniteScroll() {
  observer?.disconnect()
  if (!scrollSentinel.value) return

  observer = new IntersectionObserver(
    (entries) => {
      if (entries[0].isIntersecting && hasMore.value && !txLoading.value) {
        fetchNextPage({
          accountId: selectedAccountId.value,
          pageSize: PAGE_SIZE,
        })
      }
    },
    { rootMargin: '200px' },
  )

  observer.observe(scrollSentinel.value)
}

// Chargement initial
const isLoading = ref(true)

async function loadAll() {
  isLoading.value = true
  await Promise.all([
    fetchAccounts(),
    fetchCategories(),
    fetchTransactions({ pageSize: PAGE_SIZE }),
    fetchRecurrings(),
  ])
  await Promise.all([
    generatePendingTransactions(),
    refreshComputedBalances(),
  ])
  isLoading.value = false

  nextTick(() => setupInfiniteScroll())
}

onMounted(() => {
  loadAll()
  subscribeAccounts()
  subscribeCategories()
  subscribeTransactions()
})

onUnmounted(() => {
  unsubscribeAccounts()
  unsubscribeCategories()
  unsubscribeTransactions()
  observer?.disconnect()
})
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
          Dashboard
        </h1>
        <p class="text-sm text-gray-500 dark:text-gray-400 capitalize mt-0.5">
          {{ currentMonthLabel }}
        </p>
      </div>
      <NuxtLink to="/transactions/add">
        <CommonAppButton variant="primary" size="sm">
          <PlusIcon class="h-5 w-5 mr-1" />
          Transaction
        </CommonAppButton>
      </NuxtLink>
    </div>

    <!-- Loading -->
    <CommonLoadingState v-if="isLoading && sortedAccounts.length === 0" />

    <template v-else>
      <!-- Résumé financier (non filtré) -->
      <div class="mb-6">
        <DashboardNetWorthCard
          :total-balance="totalComputedBalance"
          :monthly-income="summary.monthlyIncome"
          :monthly-expense="summary.monthlyExpense"
        />
      </div>

      <!-- Grille principale (non filtré) -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6">
        <!-- Comptes -->
        <DashboardAccountListCard
          :accounts="sortedAccounts"
          :computed-balances="computedBalances"
          @create-account="openCreateAccount"
        />

        <!-- Répartition dépenses (filtrée) -->
        <DashboardExpenseBreakdownCard :stats="expenseStats" />
      </div>

      <!-- Sélecteur de compte -->
      <div class="flex items-center gap-2 mb-4 overflow-x-auto pb-1 -mx-1 px-1 scrollbar-hide">
        <button
          type="button"
          :class="[
            'shrink-0 px-4 py-2 rounded-xl text-sm font-medium border transition-colors',
            selectedAccountId === null
              ? 'bg-primary text-white border-primary'
              : 'bg-white dark:bg-card-dark text-gray-700 dark:text-gray-300 border-gray-200 dark:border-gray-600 hover:border-primary/50',
          ]"
          @click="selectAccount(null)"
        >
          Tous les comptes
        </button>
        <button
          v-for="account in sortedAccounts"
          :key="account.id"
          type="button"
          :class="[
            'shrink-0 flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium border transition-colors',
            selectedAccountId === account.id
              ? 'bg-primary text-white border-primary'
              : 'bg-white dark:bg-card-dark text-gray-700 dark:text-gray-300 border-gray-200 dark:border-gray-600 hover:border-primary/50',
          ]"
          @click="selectAccount(account.id)"
        >
          <span
            class="w-2.5 h-2.5 rounded-full shrink-0"
            :style="{ backgroundColor: selectedAccountId === account.id ? 'white' : colorStyle(account.color) }"
          />
          {{ account.name }}
        </button>
      </div>

      <!-- Transactions -->
      <div>
        <h2 class="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-3">
          Transactions
        </h2>

        <!-- Erreur -->
        <div
          v-if="txError"
          class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
        >
          {{ txError }}
        </div>

        <!-- Liste groupée par date -->
        <div v-if="groupedTransactions.length > 0" class="space-y-4">
          <div v-for="group in groupedTransactions" :key="group.date">
            <p class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide px-1 mb-2">
              {{ formatRelativeDate(group.date) }}
            </p>
            <div class="space-y-2">
              <TransactionsTransactionTile
                v-for="tx in group.transactions"
                :key="tx.id"
                :transaction="tx"
                :account="accountById(tx.accountId)"
                :category="categoryById(tx.categoryId)"
                @edit="editTransaction"
                @delete="confirmDelete"
              />
            </div>
          </div>

          <!-- Sentinel pour scroll infini -->
          <div ref="scrollSentinel" class="h-1" />

          <!-- Indicateur de chargement scroll -->
          <div v-if="txLoading && transactions.length > 0" class="flex justify-center py-4">
            <div class="h-6 w-6 border-2 border-primary border-t-transparent rounded-full animate-spin" />
          </div>
        </div>

        <!-- Empty state -->
        <div
          v-else-if="!txLoading"
          class="text-center py-12 text-gray-500 dark:text-gray-400"
        >
          <p class="text-sm">Aucune transaction</p>
          <NuxtLink to="/transactions/add" class="mt-3 inline-block">
            <CommonAppButton variant="primary" size="sm">
              <PlusIcon class="h-4 w-4 mr-1" />
              Ajouter une transaction
            </CommonAppButton>
          </NuxtLink>
        </div>
      </div>
    </template>

    <!-- Modal création de compte -->
    <DashboardAccountCreateModal
      :open="showAccountCreateModal"
      :account-type="creatingAccountType"
      :error="accountsError"
      :loading="accountsLoading"
      @close="closeAccountCreateModal"
      @submit="handleCreateAccount"
    />

    <!-- Modal confirmation suppression -->
    <CommonAppModal
      :open="showDeleteConfirm"
      title="Supprimer la transaction"
      size="sm"
      @close="cancelDelete"
    >
      <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
        Êtes-vous sûr de vouloir supprimer cette transaction ?
      </p>

      <div
        v-if="txError"
        class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
      >
        {{ txError }}
      </div>

      <div class="flex gap-3">
        <CommonAppButton
          variant="secondary"
          class="flex-1"
          @click="cancelDelete"
        >
          Annuler
        </CommonAppButton>
        <CommonAppButton
          variant="danger"
          class="flex-1"
          :loading="txLoading"
          @click="handleDelete"
        >
          Supprimer
        </CommonAppButton>
      </div>
    </CommonAppModal>
  </div>
</template>
