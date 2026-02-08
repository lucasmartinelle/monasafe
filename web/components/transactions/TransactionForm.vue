<script setup lang="ts">
import { z } from 'zod'
import type { Transaction } from '~/types/models'
import { CategoryType } from '~/types/enums'
import { toISODateString } from '~/utils/dates'

interface Props {
  transaction?: Transaction | null
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  transaction: null,
  loading: false,
})

const emit = defineEmits<{
  submit: [data: {
    accountId: string
    categoryId: string
    amount: number
    date: string
    note: string | null
  }]
  cancel: []
}>()

const isEditing = computed(() => !!props.transaction)

const { sortedAccounts, fetchAccounts } = useAccounts()
const { categoryById } = useCategories()

// Form state
const categoryType = ref<CategoryType>(CategoryType.EXPENSE)
const accountId = ref('')
const categoryId = ref<string | null>(null)
const amount = ref(0)
const date = ref(toISODateString(new Date()))
const note = ref('')

// Suggestions de notes (basées sur les transactions existantes)
const { transactions } = useTransactions()
const noteSuggestions = computed(() => {
  const notes = transactions.value
    .map(t => t.note)
    .filter((n): n is string => !!n && n.trim().length > 0)
  return [...new Set(notes)]
})

// Validation
const schema = z.object({
  accountId: z.string().min(1, 'Choisissez un compte'),
  categoryId: z.string().min(1, 'Choisissez une catégorie'),
  amount: z.number().positive('Le montant doit être positif'),
  date: z.string().min(1, 'La date est requise'),
})

const errors = ref<Record<string, string>>({})

function resetForm() {
  categoryType.value = CategoryType.EXPENSE
  accountId.value = sortedAccounts.value[0]?.id ?? ''
  categoryId.value = null
  amount.value = 0
  date.value = toISODateString(new Date())
  note.value = ''
  errors.value = {}
}

function syncFromTransaction(tx: Transaction | null) {
  if (tx) {
    accountId.value = tx.accountId
    categoryId.value = tx.categoryId
    amount.value = Math.abs(tx.amount)
    date.value = tx.date
    note.value = tx.note ?? ''

    // Déterminer le type via la catégorie
    const cat = categoryById.value(tx.categoryId)
    categoryType.value = cat?.type ?? CategoryType.EXPENSE
  } else {
    resetForm()
  }
}

// Sync accounts au mount
onMounted(() => {
  if (sortedAccounts.value.length === 0) {
    fetchAccounts()
  }
  syncFromTransaction(props.transaction ?? null)
})

// Sync quand la transaction change (mode édition)
watch(() => props.transaction, (tx) => {
  syncFromTransaction(tx ?? null)
})

// Auto-select premier compte si pas déjà sélectionné
watch(sortedAccounts, (accounts) => {
  if (!accountId.value && accounts.length > 0) {
    accountId.value = accounts[0].id
  }
}, { immediate: true })

function validate(): boolean {
  const result = schema.safeParse({
    accountId: accountId.value,
    categoryId: categoryId.value,
    amount: amount.value,
    date: date.value,
  })

  if (!result.success) {
    errors.value = {}
    for (const issue of result.error.issues) {
      const key = issue.path[0] as string
      errors.value[key] = issue.message
    }
    return false
  }

  errors.value = {}
  return true
}

function handleSubmit() {
  if (!validate()) return

  emit('submit', {
    accountId: accountId.value,
    categoryId: categoryId.value!,
    amount: amount.value,
    date: date.value,
    note: note.value.trim() || null,
  })
}
</script>

<template>
  <form class="space-y-5" @submit.prevent="handleSubmit">
    <!-- Toggle Dépense / Revenu -->
    <div class="flex bg-gray-100 dark:bg-gray-800 rounded-xl p-1">
      <button
        type="button"
        :class="[
          'flex-1 py-2 text-sm font-medium rounded-lg transition-colors',
          categoryType === CategoryType.EXPENSE
            ? 'bg-white dark:bg-card-dark text-gray-900 dark:text-white shadow-sm'
            : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300',
        ]"
        @click="categoryType = CategoryType.EXPENSE; categoryId = null"
      >
        Dépense
      </button>
      <button
        type="button"
        :class="[
          'flex-1 py-2 text-sm font-medium rounded-lg transition-colors',
          categoryType === CategoryType.INCOME
            ? 'bg-white dark:bg-card-dark text-gray-900 dark:text-white shadow-sm'
            : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300',
        ]"
        @click="categoryType = CategoryType.INCOME; categoryId = null"
      >
        Revenu
      </button>
    </div>

    <!-- Montant -->
    <TransactionsAmountInput
      v-model="amount"
      :error="errors.amount"
    />

    <!-- Compte -->
    <div class="w-full">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
        Compte
      </label>
      <select
        v-model="accountId"
        :class="[
          'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150',
          errors.accountId ? 'border-error' : 'border-gray-300 dark:border-gray-600',
        ]"
      >
        <option value="" disabled>Choisir un compte</option>
        <option
          v-for="account in sortedAccounts"
          :key="account.id"
          :value="account.id"
        >
          {{ account.name }}
        </option>
      </select>
      <p v-if="errors.accountId" class="mt-1 text-sm text-error">
        {{ errors.accountId }}
      </p>
    </div>

    <!-- Catégorie -->
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        Catégorie
      </label>
      <p v-if="errors.categoryId" class="mb-1 text-sm text-error">
        {{ errors.categoryId }}
      </p>
      <CommonCategoryGrid
        v-model="categoryId"
        :type="categoryType"
      />
    </div>

    <!-- Date -->
    <div class="w-full">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
        Date
      </label>
      <input
        v-model="date"
        type="date"
        :class="[
          'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150',
          errors.date ? 'border-error' : 'border-gray-300 dark:border-gray-600',
        ]"
      >
      <p v-if="errors.date" class="mt-1 text-sm text-error">
        {{ errors.date }}
      </p>
    </div>

    <!-- Note -->
    <TransactionsSmartNoteField
      v-model="note"
      :suggestions="noteSuggestions"
    />

    <!-- Actions -->
    <div class="flex gap-3 pt-2">
      <CommonAppButton
        type="button"
        variant="secondary"
        class="flex-1"
        @click="emit('cancel')"
      >
        Annuler
      </CommonAppButton>
      <CommonAppButton
        type="submit"
        variant="primary"
        class="flex-1"
        :loading="props.loading"
      >
        {{ isEditing ? 'Modifier' : 'Ajouter' }}
      </CommonAppButton>
    </div>
  </form>
</template>
