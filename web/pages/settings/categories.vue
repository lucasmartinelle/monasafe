<script setup lang="ts">
import type { Category } from '~/types/models'
import type { CategoryType } from '~/types/enums'
import { ArrowLeftIcon, PlusIcon } from '@heroicons/vue/24/outline'

definePageMeta({
  layout: 'default',
})

const {
  expenseCategories,
  incomeCategories,
  isLoading,
  error,
  fetchCategories,
  createCategory,
  updateCategory,
  deleteCategory,
  subscribeRealtime,
  unsubscribeRealtime,
  setError,
} = useCategories()

const { upsertBudget, deleteBudget, budgetByCategory } = useBudgets()

// Tabs
const activeTab = ref<'expense' | 'income'>('expense')

const displayedCategories = computed(() =>
  activeTab.value === 'expense' ? expenseCategories.value : incomeCategories.value,
)

// Modal state
const showFormModal = ref(false)
const editingCategory = ref<Category | null>(null)

// Confirm delete
const deletingCategory = ref<Category | null>(null)
const showDeleteConfirm = ref(false)

function openCreate() {
  editingCategory.value = null
  showFormModal.value = true
}

function openEdit(category: Category) {
  editingCategory.value = category
  showFormModal.value = true
}

function closeModal() {
  showFormModal.value = false
  editingCategory.value = null
}

async function handleSubmit(data: { name: string; iconKey: string; color: number; type: CategoryType; budgetLimit: number | null }) {
  if (editingCategory.value) {
    const result = await updateCategory(editingCategory.value.id, data)
    if (result) {
      if (data.budgetLimit && data.budgetLimit > 0) {
        await upsertBudget(result.id, data.budgetLimit)
      } else {
        const existingBudget = budgetByCategory.value(result.id)
        if (existingBudget) {
          await deleteBudget(existingBudget.id)
        }
      }
      closeModal()
    }
  } else {
    const result = await createCategory(data)
    if (result) {
      if (data.budgetLimit && data.budgetLimit > 0) {
        await upsertBudget(result.id, data.budgetLimit)
      }
      closeModal()
    }
  }
}

function confirmDelete(category: Category) {
  deletingCategory.value = category
  showDeleteConfirm.value = true
}

async function handleDelete() {
  if (!deletingCategory.value) return

  const success = await deleteCategory(deletingCategory.value.id)
  if (success) {
    showDeleteConfirm.value = false
    deletingCategory.value = null
  }
}

function cancelDelete() {
  showDeleteConfirm.value = false
  deletingCategory.value = null
  setError(null)
}

// Lifecycle
onMounted(() => {
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
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink
        to="/settings"
        class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
      >
        <ArrowLeftIcon class="h-5 w-5 text-gray-600 dark:text-gray-400" />
      </NuxtLink>
      <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
        Catégories
      </h1>
    </div>

    <!-- Erreur -->
    <div
      v-if="error"
      class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
    >
      {{ error }}
    </div>

    <!-- Tabs -->
    <div class="flex bg-gray-100 dark:bg-gray-800 rounded-xl p-1 mb-6">
      <button
        type="button"
        :class="[
          'flex-1 py-2 text-sm font-medium rounded-lg transition-colors',
          activeTab === 'expense'
            ? 'bg-white dark:bg-card-dark text-gray-900 dark:text-white shadow-sm'
            : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300',
        ]"
        @click="activeTab = 'expense'"
      >
        Dépenses
      </button>
      <button
        type="button"
        :class="[
          'flex-1 py-2 text-sm font-medium rounded-lg transition-colors',
          activeTab === 'income'
            ? 'bg-white dark:bg-card-dark text-gray-900 dark:text-white shadow-sm'
            : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300',
        ]"
        @click="activeTab = 'income'"
      >
        Revenus
      </button>
    </div>

    <!-- Loading -->
    <CommonLoadingState v-if="isLoading && displayedCategories.length === 0" />

    <!-- Liste catégories -->
    <div v-else class="space-y-2">
      <SettingsCategoryListTile
        v-for="cat in displayedCategories"
        :key="cat.id"
        :category="cat"
        @edit="openEdit"
        @delete="confirmDelete"
      />

      <!-- Empty state -->
      <div
        v-if="displayedCategories.length === 0"
        class="text-center py-12 text-gray-500 dark:text-gray-400"
      >
        <p class="text-sm">Aucune catégorie</p>
      </div>
    </div>

    <!-- Bouton ajout -->
    <div class="mt-6">
      <CommonAppButton
        variant="primary"
        class="w-full"
        @click="openCreate"
      >
        <PlusIcon class="h-5 w-5 mr-2" />
        Ajouter une catégorie
      </CommonAppButton>
    </div>

    <!-- Modal création/édition -->
    <SettingsCategoryFormModal
      :open="showFormModal"
      :category="editingCategory"
      @close="closeModal"
      @submit="handleSubmit"
    />

    <!-- Modal confirmation suppression -->
    <CommonAppModal
      :open="showDeleteConfirm"
      title="Supprimer la catégorie"
      size="sm"
      @close="cancelDelete"
    >
      <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
        Êtes-vous sûr de vouloir supprimer
        <strong class="text-gray-900 dark:text-white">{{ deletingCategory?.name }}</strong> ?
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
