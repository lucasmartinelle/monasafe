<script setup lang="ts">
import type { RecurringTransaction } from '~/types/models'
import { CategoryType } from '~/types/enums'
import { PlusIcon, InformationCircleIcon } from '@heroicons/vue/24/outline'

useSeoMeta({
  title: 'Récurrences — Monasafe',
  description: 'Gérez vos paiements récurrents : abonnements, loyers et revenus automatiques.',
})

definePageMeta({
  layout: 'default',
})

const {
  activeRecurrings,
  inactiveRecurrings,
  isLoading,
  error,
  fetchRecurrings,
  createRecurring,
  updateRecurring,
  toggleActive,
  deleteRecurring,
  calculateNextDate,
  generatePendingTransactions,
  subscribeRealtime,
  unsubscribeRealtime,
  setError,
} = useRecurring()

const { fetchAccounts, accountById } = useAccounts()
const { fetchCategories, categoryById } = useCategories()
const { format: formatMoney } = useCurrency()

// Totaux
const totalExpense = computed(() => {
  return activeRecurrings.value
    .filter((r) => {
      const cat = categoryById.value(r.categoryId)
      return cat?.type === CategoryType.EXPENSE
    })
    .reduce((sum, r) => sum + Math.abs(r.amount), 0)
})

const totalIncome = computed(() => {
  return activeRecurrings.value
    .filter((r) => {
      const cat = categoryById.value(r.categoryId)
      return cat?.type === CategoryType.INCOME
    })
    .reduce((sum, r) => sum + Math.abs(r.amount), 0)
})

// Modal form
const showFormModal = ref(false)
const editingRecurring = ref<RecurringTransaction | null>(null)

// Modal delete
const deletingRecurring = ref<RecurringTransaction | null>(null)
const showDeleteConfirm = ref(false)

// Generated count feedback
const generatedCount = ref(0)
const showGenerated = ref(false)

function openCreate() {
  editingRecurring.value = null
  showFormModal.value = true
}

function openEdit(recurring: RecurringTransaction) {
  editingRecurring.value = recurring
  showFormModal.value = true
}

function closeModal() {
  showFormModal.value = false
  editingRecurring.value = null
}

async function handleSubmit(data: {
  accountId: string
  categoryId: string
  amount: number
  note: string | null
  originalDay: number
  startDate: string
  endDate: string | null
}) {
  if (editingRecurring.value) {
    const result = await updateRecurring(editingRecurring.value.id, data)
    if (result) closeModal()
  } else {
    const result = await createRecurring(data)
    if (result) closeModal()
  }
}

async function handleToggle(recurring: RecurringTransaction) {
  await toggleActive(recurring.id)
}

function confirmDelete(recurring: RecurringTransaction) {
  deletingRecurring.value = recurring
  showDeleteConfirm.value = true
}

async function handleDelete() {
  if (!deletingRecurring.value) return

  const success = await deleteRecurring(deletingRecurring.value.id)
  if (success) {
    showDeleteConfirm.value = false
    deletingRecurring.value = null
  }
}

function cancelDelete() {
  showDeleteConfirm.value = false
  deletingRecurring.value = null
  setError(null)
}

// Lifecycle
onMounted(async () => {
  await Promise.all([
    fetchRecurrings(),
    fetchAccounts(),
    fetchCategories(),
  ])
  subscribeRealtime()

  // Générer les transactions en attente (REC-04)
  const count = await generatePendingTransactions()
  if (count > 0) {
    generatedCount.value = count
    showGenerated.value = true
    setTimeout(() => { showGenerated.value = false }, 5000)
  }
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
        Récurrences
      </h1>
      <CommonAppButton variant="primary" size="sm" @click="openCreate">
        <PlusIcon class="h-5 w-5 mr-1" />
        Ajouter
      </CommonAppButton>
    </div>

    <!-- Notification transactions générées -->
    <div
      v-if="showGenerated"
      class="mb-4 p-3 bg-green-50 dark:bg-green-900/20 text-success text-sm rounded-xl"
    >
      {{ generatedCount }} transaction(s) récurrente(s) générée(s) automatiquement.
    </div>

    <!-- Erreur -->
    <div
      v-if="error"
      class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
    >
      {{ error }}
    </div>

    <!-- Loading -->
    <CommonLoadingState v-if="isLoading && activeRecurrings.length === 0 && inactiveRecurrings.length === 0" />

    <template v-else>
      <!-- Section Actives -->
      <div v-if="activeRecurrings.length > 0" class="mb-6">
        <h2 class="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-3">
          Actives
        </h2>
        <div class="space-y-2">
          <RecurringTile
            v-for="rec in activeRecurrings"
            :key="rec.id"
            :recurring="rec"
            :account="accountById(rec.accountId)"
            :category="categoryById(rec.categoryId)"
            :next-date="calculateNextDate(rec)"
            @edit="openEdit"
            @delete="confirmDelete"
            @toggle="handleToggle"
          />
        </div>
      </div>

      <!-- Section Inactives -->
      <div v-if="inactiveRecurrings.length > 0">
        <h2 class="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-3">
          Inactives
        </h2>
        <div class="space-y-2">
          <RecurringTile
            v-for="rec in inactiveRecurrings"
            :key="rec.id"
            :recurring="rec"
            :account="accountById(rec.accountId)"
            :category="categoryById(rec.categoryId)"
            :next-date="null"
            @edit="openEdit"
            @delete="confirmDelete"
            @toggle="handleToggle"
          />
        </div>
      </div>

      <!-- Empty state -->
      <div
        v-if="activeRecurrings.length === 0 && inactiveRecurrings.length === 0"
        class="text-center py-12 text-gray-500 dark:text-gray-400"
      >
        <p class="text-sm">Aucune récurrence configurée</p>
        <CommonAppButton
          variant="primary"
          size="sm"
          class="mt-3"
          @click="openCreate"
        >
          <PlusIcon class="h-4 w-4 mr-1" />
          Créer une récurrence
        </CommonAppButton>
      </div>
    </template>

    <!-- Totaux -->
    <div
      v-if="activeRecurrings.length > 0"
      class="mt-6 bg-white dark:bg-card-dark rounded-xl p-4"
    >
      <div class="flex items-center justify-around">
        <div class="text-center">
          <p class="text-xs text-gray-500 dark:text-gray-400">Dépenses / mois</p>
          <p class="text-sm font-semibold text-error mt-0.5">
            -{{ formatMoney(totalExpense) }}
          </p>
        </div>
        <div class="w-px h-8 bg-gray-200 dark:bg-gray-700" />
        <div class="text-center">
          <p class="text-xs text-gray-500 dark:text-gray-400">Revenus / mois</p>
          <p class="text-sm font-semibold text-success mt-0.5">
            +{{ formatMoney(totalIncome) }}
          </p>
        </div>
      </div>
    </div>

    <!-- Info -->
    <div class="mt-4 flex items-start gap-2.5 px-1">
      <InformationCircleIcon class="h-4 w-4 text-gray-400 dark:text-gray-500 shrink-0 mt-0.5" />
      <p class="text-xs text-gray-400 dark:text-gray-500">
        Les paiements récurrents sont générés automatiquement chaque mois.
      </p>
    </div>

    <!-- Modal création/édition -->
    <RecurringForm
      :open="showFormModal"
      :recurring="editingRecurring"
      @close="closeModal"
      @submit="handleSubmit"
    />

    <!-- Modal confirmation suppression -->
    <CommonAppModal
      :open="showDeleteConfirm"
      title="Supprimer la récurrence"
      size="sm"
      @close="cancelDelete"
    >
      <p class="text-sm text-gray-600 dark:text-gray-400 mb-2">
        Êtes-vous sûr de vouloir supprimer cette récurrence ?
      </p>
      <p class="text-xs text-gray-400 dark:text-gray-500 mb-4">
        Les transactions déjà générées seront conservées mais détachées.
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
