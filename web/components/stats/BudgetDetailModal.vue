<script setup lang="ts">
import type { BudgetProgress, Transaction, Category } from '~/types/models'
import { CategoryType } from '~/types/enums'
import { getBudgetStatus, getBudgetPercentage } from '~/composables/useStatistics'
import { intToHex } from '~/utils/colors'
import { getIcon } from '~/utils/icons'
import { formatRelativeDate } from '~/utils/dates'

interface Props {
  open: boolean
  progress: BudgetProgress | null
  startDate: string
  endDate: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  close: []
  update: [budgetId: string, categoryId: string, budgetLimit: number]
  delete: [budgetId: string]
}>()

const { format: formatMoney } = useCurrency()

const transactionsStore = useTransactionsStore()
const categoriesStore = useCategoriesStore()

// Transactions de la catégorie pour la période
const categoryTransactions = computed(() => {
  if (!props.progress) return []

  return transactionsStore.transactions
    .filter(tx => {
      if (tx.categoryId !== props.progress!.category.id) return false
      if (tx.date < props.startDate || tx.date > props.endDate) return false
      const cat = categoriesStore.categories.find(c => c.id === tx.categoryId)
      return cat?.type === CategoryType.EXPENSE
    })
    .sort((a, b) => b.date.localeCompare(a.date))
    .slice(0, 10)
})

const totalTransactions = computed(() => {
  if (!props.progress) return 0
  return transactionsStore.transactions.filter(tx => {
    if (tx.categoryId !== props.progress!.category.id) return false
    if (tx.date < props.startDate || tx.date > props.endDate) return false
    const cat = categoriesStore.categories.find(c => c.id === tx.categoryId)
    return cat?.type === CategoryType.EXPENSE
  }).length
})

// Édition du montant
const editAmount = ref('')
const isEditing = ref(false)

const editedLimit = computed(() => {
  const v = parseFloat(editAmount.value.replace(',', '.'))
  return isNaN(v) ? 0 : Math.round(v * 100) / 100
})

function startEdit() {
  if (!props.progress) return
  editAmount.value = props.progress.monthlyBudgetLimit.toFixed(2).replace('.', ',')
  isEditing.value = true
}

function handleUpdate() {
  if (!props.progress || editedLimit.value <= 0) return
  emit('update', props.progress.budgetId, props.progress.category.id, editedLimit.value)
  isEditing.value = false
}

// Suppression
const showDeleteConfirm = ref(false)

function confirmDelete() {
  showDeleteConfirm.value = true
}

function handleDelete() {
  if (!props.progress) return
  emit('delete', props.progress.budgetId)
  showDeleteConfirm.value = false
}

// Computed display
const percentage = computed(() =>
  props.progress ? getBudgetPercentage(props.progress.currentSpending, props.progress.budgetLimit) : 0,
)
const status = computed(() =>
  props.progress ? getBudgetStatus(props.progress.currentSpending, props.progress.budgetLimit) : 'safe',
)
const remaining = computed(() =>
  props.progress ? props.progress.budgetLimit - props.progress.currentSpending : 0,
)
const barWidth = computed(() => Math.min(percentage.value, 100))

const statusColor = computed(() => {
  switch (status.value) {
    case 'safe': return 'bg-green-500'
    case 'warning': return 'bg-orange-500'
    case 'exceeded': return 'bg-red-500'
  }
})

const statusTextColor = computed(() => {
  switch (status.value) {
    case 'safe': return 'text-green-600 dark:text-green-400'
    case 'warning': return 'text-orange-600 dark:text-orange-400'
    case 'exceeded': return 'text-red-600 dark:text-red-400'
  }
})

function handleClose() {
  isEditing.value = false
  showDeleteConfirm.value = false
  emit('close')
}

watch(() => props.open, (val) => {
  if (val) {
    isEditing.value = false
    showDeleteConfirm.value = false
  }
})
</script>

<template>
  <CommonAppModal
    :open="props.open"
    :title="props.progress?.category.name ?? 'Budget'"
    size="lg"
    @close="handleClose"
  >
    <template v-if="props.progress">
      <!-- Progression -->
      <div class="mb-5">
        <div class="flex items-center gap-3 mb-3">
          <div
            class="flex items-center justify-center h-10 w-10 rounded-xl"
            :style="{ backgroundColor: intToHex(props.progress.category.color) + '20' }"
          >
            <component
              :is="getIcon(props.progress.category.iconKey)"
              class="h-5 w-5"
              :style="{ color: intToHex(props.progress.category.color) }"
            />
          </div>
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              {{ formatMoney(props.progress.currentSpending) }}
              <span class="text-gray-400 dark:text-gray-500">
                / {{ formatMoney(props.progress.budgetLimit) }}
              </span>
            </p>
            <p :class="['text-xs', statusTextColor]">
              <template v-if="remaining >= 0">
                Reste {{ formatMoney(remaining) }}
              </template>
              <template v-else>
                Dépassé de {{ formatMoney(Math.abs(remaining)) }}
              </template>
              &middot; {{ Math.round(percentage) }}%
            </p>
          </div>
        </div>

        <div class="h-2.5 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
          <div
            :class="['h-full rounded-full transition-all duration-500', statusColor]"
            :style="{ width: `${barWidth}%` }"
          />
        </div>
      </div>

      <!-- Plafond mensuel (éditable) -->
      <div class="bg-gray-50 dark:bg-gray-800 rounded-xl p-3 mb-4">
        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-1">
          Plafond mensuel
        </p>
        <div v-if="!isEditing" class="flex items-center justify-between">
          <p class="text-sm font-semibold text-gray-900 dark:text-white">
            {{ formatMoney(props.progress.monthlyBudgetLimit) }}
          </p>
          <button
            type="button"
            class="text-xs text-primary dark:text-primary-light hover:underline"
            @click="startEdit"
          >
            Modifier
          </button>
        </div>
        <div v-else class="flex items-center gap-2">
          <div class="relative flex-1">
            <input
              v-model="editAmount"
              type="text"
              inputmode="decimal"
              class="w-full px-3 py-2 rounded-lg border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-right pr-8 text-sm focus:ring-2 focus:ring-primary/50 focus:border-primary outline-none"
            >
            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs">
              &euro;
            </span>
          </div>
          <CommonAppButton
            variant="primary"
            size="sm"
            :disabled="editedLimit <= 0"
            @click="handleUpdate"
          >
            OK
          </CommonAppButton>
        </div>
      </div>

      <!-- Transactions récentes -->
      <div v-if="categoryTransactions.length > 0" class="mb-4">
        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2">
          Transactions récentes
          <span v-if="totalTransactions > 10" class="text-gray-400">
            ({{ totalTransactions }} au total)
          </span>
        </p>
        <div class="space-y-1.5">
          <div
            v-for="tx in categoryTransactions"
            :key="tx.id"
            class="flex items-center justify-between py-1.5 px-2 rounded-lg"
          >
            <div class="min-w-0">
              <p class="text-sm text-gray-900 dark:text-white truncate">
                {{ tx.note || props.progress.category.name }}
              </p>
              <p class="text-xs text-gray-400 dark:text-gray-500">
                {{ formatRelativeDate(tx.date) }}
              </p>
            </div>
            <p class="text-sm font-medium text-error shrink-0 ml-2">
              -{{ formatMoney(Math.abs(tx.amount)) }}
            </p>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div v-if="!showDeleteConfirm" class="flex gap-3 pt-2">
        <CommonAppButton
          variant="secondary"
          class="flex-1"
          @click="confirmDelete"
        >
          Supprimer
        </CommonAppButton>
        <CommonAppButton
          variant="primary"
          class="flex-1"
          @click="handleClose"
        >
          Fermer
        </CommonAppButton>
      </div>

      <!-- Confirmation suppression -->
      <div v-else class="pt-2">
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-3">
          Supprimer le budget pour {{ props.progress.category.name }} ?
        </p>
        <div class="flex gap-3">
          <CommonAppButton
            variant="secondary"
            class="flex-1"
            @click="showDeleteConfirm = false"
          >
            Annuler
          </CommonAppButton>
          <CommonAppButton
            variant="danger"
            class="flex-1"
            @click="handleDelete"
          >
            Supprimer
          </CommonAppButton>
        </div>
      </div>
    </template>
  </CommonAppModal>
</template>
