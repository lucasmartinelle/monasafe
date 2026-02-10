<script setup lang="ts">
import type { BudgetProgress } from '~/types/models'
import type { PeriodType } from '~/composables/useStatistics'
import { getMonthRange, getYearRange, toISODateString, getPreviousMonth } from '~/utils/dates'

useSeoMeta({
  title: 'Statistiques — SimpleFlow',
  description: 'Analysez vos finances : graphiques de cashflow, budgets et suivi des dépenses par catégorie.',
})

definePageMeta({
  layout: 'default',
})

const { fetchCategories } = useCategories()
const { fetchAllTransactions, subscribeRealtime: subscribeTransactions, unsubscribeRealtime: unsubscribeTransactions } = useTransactions()
const {
  fetchBudgets,
  upsertBudget,
  deleteBudget,
  subscribeRealtime: subscribeBudgets,
  unsubscribeRealtime: unsubscribeBudgets,
  error: budgetError,
} = useBudgets()
const { calculateMonthlyStats, calculateDailyStats, calculateBudgetProgress, calculatePeriodTotals } = useStatistics()
const { format: formatMoney } = useCurrency()
const budgetsStore = useBudgetsStore()

// Période sélectionnée
const selectedPeriod = ref<PeriodType>('thisMonth')

const periodRange = computed(() => {
  const now = new Date()

  switch (selectedPeriod.value) {
    case 'thisMonth': {
      const { start, end } = getMonthRange(now)
      return { startDate: toISODateString(start), endDate: toISODateString(end) }
    }
    case 'lastMonth': {
      const prev = getPreviousMonth(now)
      const { start, end } = getMonthRange(prev)
      return { startDate: toISODateString(start), endDate: toISODateString(end) }
    }
    case 'yearToDate': {
      const { start, end } = getYearRange(now)
      return { startDate: toISODateString(start), endDate: toISODateString(end) }
    }
    default: {
      const { start, end } = getMonthRange(now)
      return { startDate: toISODateString(start), endDate: toISODateString(end) }
    }
  }
})

// Chart mode et données
const chartMode = computed(() => selectedPeriod.value === 'yearToDate' ? 'monthly' as const : 'daily' as const)

const monthlyStats = computed(() => {
  if (chartMode.value !== 'monthly') return undefined
  return calculateMonthlyStats(new Date().getFullYear())
})

const dailyStats = computed(() => {
  if (chartMode.value !== 'daily') return undefined
  return calculateDailyStats(periodRange.value.startDate, periodRange.value.endDate)
})

// Résumé période
const periodIncome = computed(() =>
  calculatePeriodTotals(periodRange.value.startDate, periodRange.value.endDate),
)

// Budgets
const budgetProgress = computed(() =>
  calculateBudgetProgress(periodRange.value.startDate, periodRange.value.endDate, selectedPeriod.value),
)

const existingBudgetCategoryIds = computed(() =>
  budgetsStore.budgets.map(b => b.categoryId),
)

// Modals
const showCreateBudget = ref(false)
const selectedBudgetProgress = ref<BudgetProgress | null>(null)
const showBudgetDetail = ref(false)

function openCreateBudget() {
  showCreateBudget.value = true
}

function openBudgetDetail(bp: BudgetProgress) {
  selectedBudgetProgress.value = bp
  showBudgetDetail.value = true
}

async function handleCreateBudget(categoryId: string, budgetLimit: number) {
  const result = await upsertBudget(categoryId, budgetLimit)
  if (result) {
    showCreateBudget.value = false
  }
}

async function handleUpdateBudget(budgetId: string, categoryId: string, budgetLimit: number) {
  const result = await upsertBudget(categoryId, budgetLimit)
  if (result) {
    showBudgetDetail.value = false
    selectedBudgetProgress.value = null
  }
}

async function handleDeleteBudget(budgetId: string) {
  const success = await deleteBudget(budgetId)
  if (success) {
    showBudgetDetail.value = false
    selectedBudgetProgress.value = null
  }
}

// Chargement initial
const isLoading = ref(true)

async function loadAll() {
  isLoading.value = true
  await Promise.all([
    fetchCategories(),
    fetchAllTransactions(),
    fetchBudgets(),
  ])
  isLoading.value = false
}

onMounted(() => {
  loadAll()
  subscribeTransactions()
  subscribeBudgets()
})

onUnmounted(() => {
  unsubscribeTransactions()
  unsubscribeBudgets()
})
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <!-- Header -->
    <div class="mb-6">
      <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
        Statistiques
      </h1>
    </div>

    <!-- Loading -->
    <CommonLoadingState v-if="isLoading" />

    <template v-else>
      <!-- Sélecteur de période -->
      <div class="mb-6">
        <StatsPeriodSelector v-model="selectedPeriod" />
      </div>

      <!-- Résumé revenus / dépenses -->
      <div class="bg-white dark:bg-card-dark rounded-xl p-4 mb-4">
        <div class="flex items-center justify-around">
          <div class="text-center">
            <p class="text-xs text-gray-500 dark:text-gray-400">Revenus</p>
            <p class="text-sm font-semibold text-success mt-0.5">
              +{{ formatMoney(periodIncome.income) }}
            </p>
          </div>
          <div class="w-px h-8 bg-gray-200 dark:bg-gray-700" />
          <div class="text-center">
            <p class="text-xs text-gray-500 dark:text-gray-400">Dépenses</p>
            <p class="text-sm font-semibold text-error mt-0.5">
              -{{ formatMoney(periodIncome.expense) }}
            </p>
          </div>
          <div class="w-px h-8 bg-gray-200 dark:bg-gray-700" />
          <div class="text-center">
            <p class="text-xs text-gray-500 dark:text-gray-400">Balance</p>
            <p
              :class="[
                'text-sm font-semibold mt-0.5',
                periodIncome.income - periodIncome.expense >= 0 ? 'text-success' : 'text-error',
              ]"
            >
              {{ periodIncome.income - periodIncome.expense >= 0 ? '+' : '' }}{{ formatMoney(periodIncome.income - periodIncome.expense) }}
            </p>
          </div>
        </div>
      </div>

      <!-- Graphique Cashflow -->
      <div class="mb-6">
        <StatsCashflowChart
          :mode="chartMode"
          :monthly-data="monthlyStats"
          :daily-data="dailyStats"
        />
      </div>

      <!-- Erreur budgets -->
      <div
        v-if="budgetError"
        class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
      >
        {{ budgetError }}
      </div>

      <!-- Liste budgets -->
      <div class="mb-6">
        <StatsBudgetList
          :budgets="budgetProgress"
          @create="openCreateBudget"
          @select="openBudgetDetail"
        />
      </div>
    </template>

    <!-- Modal création budget -->
    <StatsBudgetFormModal
      :open="showCreateBudget"
      :existing-category-ids="existingBudgetCategoryIds"
      @close="showCreateBudget = false"
      @submit="handleCreateBudget"
    />

    <!-- Modal détail budget -->
    <StatsBudgetDetailModal
      :open="showBudgetDetail"
      :progress="selectedBudgetProgress"
      :start-date="periodRange.startDate"
      :end-date="periodRange.endDate"
      @close="showBudgetDetail = false; selectedBudgetProgress = null"
      @update="handleUpdateBudget"
      @delete="handleDeleteBudget"
    />
  </div>
</template>
