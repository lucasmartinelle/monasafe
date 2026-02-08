<script setup lang="ts">
import { ArrowLeftIcon, ExclamationTriangleIcon } from '@heroicons/vue/24/outline'

definePageMeta({
  layout: 'default',
})

const { isLoading, error, deleteTransactions, deleteRecurrings, deleteBudgets, deleteAllData } = useDataManagement()

// Confirmation par saisie
const confirmText = ref('')
const activeAction = ref<string | null>(null)
const showConfirm = ref(false)

const actionLabels: Record<string, { title: string; description: string; warning: string }> = {
  transactions: {
    title: 'Supprimer les transactions',
    description: 'Toutes les transactions seront définitivement supprimées.',
    warning: 'Cette action est irréversible.',
  },
  recurrings: {
    title: 'Supprimer les récurrences',
    description: 'Toutes les récurrences seront supprimées. Les transactions déjà générées seront conservées.',
    warning: 'Cette action est irréversible.',
  },
  budgets: {
    title: 'Supprimer les budgets',
    description: 'Tous les budgets seront définitivement supprimés.',
    warning: 'Cette action est irréversible.',
  },
  all: {
    title: 'Supprimer toutes les données',
    description: 'Toutes vos données seront supprimées : transactions, récurrences, budgets, comptes et catégories personnalisées.',
    warning: 'Cette action est irréversible et ne peut pas être annulée.',
  },
}

const currentAction = computed(() =>
  activeAction.value ? actionLabels[activeAction.value] : null,
)

const isConfirmValid = computed(() =>
  confirmText.value.trim().toUpperCase() === 'SUPPRIMER',
)

function openConfirm(action: string) {
  activeAction.value = action
  confirmText.value = ''
  showConfirm.value = true
}

function closeConfirm() {
  showConfirm.value = false
  activeAction.value = null
  confirmText.value = ''
}

const successMessage = ref('')

async function executeAction() {
  if (!isConfirmValid.value || !activeAction.value) return

  let success = false
  switch (activeAction.value) {
    case 'transactions':
      success = await deleteTransactions()
      break
    case 'recurrings':
      success = await deleteRecurrings()
      break
    case 'budgets':
      success = await deleteBudgets()
      break
    case 'all':
      success = await deleteAllData()
      break
  }

  if (success) {
    successMessage.value = `${currentAction.value?.title} effectuée avec succès.`
    closeConfirm()
    setTimeout(() => { successMessage.value = '' }, 4000)
  }
}
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink
        to="/settings"
        class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
      >
        <ArrowLeftIcon class="h-5 w-5 text-gray-600 dark:text-gray-400" />
      </NuxtLink>
      <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
        Gestion des données
      </h1>
    </div>

    <!-- Succès -->
    <div
      v-if="successMessage"
      class="mb-4 p-3 bg-green-50 dark:bg-green-900/20 text-success text-sm rounded-xl"
    >
      {{ successMessage }}
    </div>

    <!-- Erreur -->
    <div
      v-if="error"
      class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
    >
      {{ error }}
    </div>

    <!-- Actions de suppression -->
    <div class="space-y-3">
      <!-- Transactions -->
      <div class="bg-white dark:bg-card-dark rounded-xl p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              Transactions
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
              Supprimer toutes les transactions
            </p>
          </div>
          <CommonAppButton
            variant="danger"
            size="sm"
            @click="openConfirm('transactions')"
          >
            Supprimer
          </CommonAppButton>
        </div>
      </div>

      <!-- Récurrences -->
      <div class="bg-white dark:bg-card-dark rounded-xl p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              Récurrences
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
              Supprimer toutes les transactions récurrentes
            </p>
          </div>
          <CommonAppButton
            variant="danger"
            size="sm"
            @click="openConfirm('recurrings')"
          >
            Supprimer
          </CommonAppButton>
        </div>
      </div>

      <!-- Budgets -->
      <div class="bg-white dark:bg-card-dark rounded-xl p-5">
        <div class="flex items-start justify-between">
          <div>
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              Budgets
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
              Supprimer tous les budgets configurés
            </p>
          </div>
          <CommonAppButton
            variant="danger"
            size="sm"
            @click="openConfirm('budgets')"
          >
            Supprimer
          </CommonAppButton>
        </div>
      </div>

      <!-- Séparateur -->
      <div class="border-t border-gray-200 dark:border-gray-700 my-4" />

      <!-- Tout supprimer -->
      <div class="bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-800/30 rounded-xl p-5">
        <div class="flex items-start gap-3">
          <ExclamationTriangleIcon class="h-5 w-5 text-error shrink-0 mt-0.5" />
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              Supprimer toutes les données
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
              Supprime définitivement toutes vos données : transactions, récurrences, budgets, comptes et catégories personnalisées.
            </p>
            <CommonAppButton
              variant="danger"
              size="sm"
              class="mt-3"
              @click="openConfirm('all')"
            >
              Tout supprimer
            </CommonAppButton>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal confirmation -->
    <CommonAppModal
      :open="showConfirm"
      :title="currentAction?.title ?? 'Confirmer'"
      size="sm"
      @close="closeConfirm"
    >
      <div class="space-y-4">
        <p class="text-sm text-gray-600 dark:text-gray-400">
          {{ currentAction?.description }}
        </p>

        <div class="p-3 bg-red-50 dark:bg-red-900/20 rounded-xl">
          <p class="text-xs font-medium text-error">
            {{ currentAction?.warning }}
          </p>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Tapez <strong>SUPPRIMER</strong> pour confirmer
          </label>
          <input
            v-model="confirmText"
            type="text"
            placeholder="SUPPRIMER"
            class="w-full px-4 py-2.5 rounded-[12px] border border-gray-300 dark:border-gray-600 bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150"
          >
        </div>

        <div class="flex gap-3 pt-1">
          <CommonAppButton
            variant="secondary"
            class="flex-1"
            @click="closeConfirm"
          >
            Annuler
          </CommonAppButton>
          <CommonAppButton
            variant="danger"
            class="flex-1"
            :loading="isLoading"
            :disabled="!isConfirmValid"
            @click="executeAction"
          >
            Confirmer
          </CommonAppButton>
        </div>
      </div>
    </CommonAppModal>
  </div>
</template>
