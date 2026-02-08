<script setup lang="ts">
import type { Transaction } from '~/types/models'
import { PlusIcon, FunnelIcon, ChevronLeftIcon, ChevronRightIcon } from '@heroicons/vue/24/outline'
import { formatMonthYear, formatRelativeDate, getMonthRange, getPreviousMonth, getNextMonth, toISODateString } from '~/utils/dates'

definePageMeta({
  layout: 'default',
})

const router = useRouter()

const {
  transactions,
  isLoading,
  error,
  hasMore,
  fetchTransactions,
  fetchNextPage,
  deleteTransaction,
  subscribeRealtime,
  unsubscribeRealtime,
  setError,
} = useTransactions()

const { sortedAccounts, fetchAccounts, accountById } = useAccounts()
const { categoryById, fetchCategories } = useCategories()

// Filtres
const selectedMonth = ref(new Date())
const selectedAccountId = ref<string | null>(null)
const showFilters = ref(false)

const monthLabel = computed(() => formatMonthYear(selectedMonth.value))

const currentRange = computed(() => {
  const { start, end } = getMonthRange(selectedMonth.value)
  return {
    startDate: toISODateString(start),
    endDate: toISODateString(end),
  }
})

function previousMonth() {
  selectedMonth.value = getPreviousMonth(selectedMonth.value)
}

function nextMonth() {
  selectedMonth.value = getNextMonth(selectedMonth.value)
}

// Groupement par date
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

// Chargement
async function loadTransactions() {
  await fetchTransactions({
    accountId: selectedAccountId.value,
    startDate: currentRange.value.startDate,
    endDate: currentRange.value.endDate,
  })
}

function loadMore() {
  fetchNextPage({
    accountId: selectedAccountId.value,
    startDate: currentRange.value.startDate,
    endDate: currentRange.value.endDate,
  })
}

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

// Watchers
watch([selectedMonth, selectedAccountId], () => {
  loadTransactions()
})

// Lifecycle
onMounted(() => {
  loadTransactions()
  fetchAccounts()
  fetchCategories()
  subscribeRealtime()
})

onUnmounted(() => {
  unsubscribeRealtime()
})
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
        Transactions
      </h1>
      <div class="flex items-center gap-2">
        <button
          type="button"
          :class="[
            'p-2 rounded-lg transition-colors',
            showFilters
              ? 'bg-primary/10 text-primary dark:text-primary-light'
              : 'text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-700',
          ]"
          @click="showFilters = !showFilters"
        >
          <FunnelIcon class="h-5 w-5" />
        </button>
        <NuxtLink to="/transactions/add">
          <CommonAppButton variant="primary" size="sm">
            <PlusIcon class="h-5 w-5 mr-1" />
            Ajouter
          </CommonAppButton>
        </NuxtLink>
      </div>
    </div>

    <!-- Sélecteur de mois -->
    <div class="flex items-center justify-between bg-white dark:bg-card-dark rounded-xl px-4 py-3 mb-4">
      <button
        type="button"
        class="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        @click="previousMonth"
      >
        <ChevronLeftIcon class="h-5 w-5 text-gray-600 dark:text-gray-400" />
      </button>
      <span class="text-sm font-medium text-gray-900 dark:text-white capitalize">
        {{ monthLabel }}
      </span>
      <button
        type="button"
        class="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        @click="nextMonth"
      >
        <ChevronRightIcon class="h-5 w-5 text-gray-600 dark:text-gray-400" />
      </button>
    </div>

    <!-- Filtres -->
    <div v-if="showFilters" class="bg-white dark:bg-card-dark rounded-xl px-4 py-3 mb-4">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
        Compte
      </label>
      <select
        v-model="selectedAccountId"
        class="w-full px-4 py-2.5 rounded-[12px] border border-gray-300 dark:border-gray-600 bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150"
      >
        <option :value="null">Tous les comptes</option>
        <option
          v-for="account in sortedAccounts"
          :key="account.id"
          :value="account.id"
        >
          {{ account.name }}
        </option>
      </select>
    </div>

    <!-- Erreur -->
    <div
      v-if="error"
      class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
    >
      {{ error }}
    </div>

    <!-- Loading -->
    <CommonLoadingState v-if="isLoading && transactions.length === 0" />

    <!-- Liste groupée par date -->
    <div v-else class="space-y-4">
      <div v-for="group in groupedTransactions" :key="group.date">
        <!-- Date header -->
        <p class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide px-1 mb-2">
          {{ formatRelativeDate(group.date) }}
        </p>

        <!-- Transactions du jour -->
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

      <!-- Empty state -->
      <div
        v-if="groupedTransactions.length === 0"
        class="text-center py-12 text-gray-500 dark:text-gray-400"
      >
        <p class="text-sm">Aucune transaction pour cette période</p>
        <NuxtLink to="/transactions/add" class="mt-3 inline-block">
          <CommonAppButton variant="primary" size="sm">
            <PlusIcon class="h-4 w-4 mr-1" />
            Ajouter une transaction
          </CommonAppButton>
        </NuxtLink>
      </div>

      <!-- Load more -->
      <div v-if="hasMore && groupedTransactions.length > 0" class="pt-2">
        <CommonAppButton
          variant="secondary"
          class="w-full"
          :loading="isLoading"
          @click="loadMore"
        >
          Charger plus
        </CommonAppButton>
      </div>
    </div>

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
        v-if="error"
        class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
      >
        {{ error }}
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
          :loading="isLoading"
          @click="handleDelete"
        >
          Supprimer
        </CommonAppButton>
      </div>
    </CommonAppModal>
  </div>
</template>
