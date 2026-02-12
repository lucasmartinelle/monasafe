<script setup lang="ts">
import { z } from 'zod'
import type { RecurringTransaction } from '~/types/models'
import { CategoryType } from '~/types/enums'
import { toISODateString } from '~/utils/dates'

interface Props {
  open: boolean
  recurring?: RecurringTransaction | null
}

const props = withDefaults(defineProps<Props>(), {
  recurring: null,
})

const emit = defineEmits<{
  close: []
  submit: [data: {
    accountId: string
    categoryId: string
    amount: number
    note: string | null
    originalDay: number
    startDate: string
    endDate: string | null
  }]
}>()

const isEditing = computed(() => !!props.recurring)

const { sortedAccounts, fetchAccounts } = useAccounts()
const { categoryById } = useCategories()

// Form state
const categoryType = ref<CategoryType>(CategoryType.EXPENSE)
const accountId = ref('')
const categoryId = ref<string | null>(null)
const amount = ref(0)
const note = ref('')
const originalDay = ref(1)
const startDate = ref(toISODateString(new Date()))
const endDate = ref('')
const hasEndDate = ref(false)

// Validation
const schema = z.object({
  accountId: z.string().min(1, 'Choisissez un compte'),
  categoryId: z.string().min(1, 'Choisissez une catégorie'),
  amount: z.number().positive('Le montant doit être positif'),
  originalDay: z.number().min(1, 'Min 1').max(31, 'Max 31'),
  startDate: z.string().min(1, 'La date de début est requise'),
})

const errors = ref<Record<string, string>>({})

function resetForm() {
  categoryType.value = CategoryType.EXPENSE
  accountId.value = sortedAccounts.value[0]?.id ?? ''
  categoryId.value = null
  amount.value = 0
  note.value = ''
  originalDay.value = new Date().getDate()
  startDate.value = toISODateString(new Date())
  endDate.value = ''
  hasEndDate.value = false
  errors.value = {}
}

function syncFromRecurring(rec: RecurringTransaction | null) {
  if (rec) {
    accountId.value = rec.accountId
    categoryId.value = rec.categoryId
    amount.value = Math.abs(rec.amount)
    note.value = rec.note ?? ''
    originalDay.value = rec.originalDay
    startDate.value = rec.startDate
    endDate.value = rec.endDate ?? ''
    hasEndDate.value = !!rec.endDate

    const cat = categoryById.value(rec.categoryId)
    categoryType.value = cat?.type ?? CategoryType.EXPENSE
  } else {
    resetForm()
  }
}

// Sync quand la modal s'ouvre
watch(() => props.open, (isOpen) => {
  if (isOpen) {
    if (sortedAccounts.value.length === 0) fetchAccounts()
    syncFromRecurring(props.recurring ?? null)
  }
})

// Auto-select premier compte
watch(sortedAccounts, (accounts) => {
  if (!accountId.value && accounts.length > 0) {
    accountId.value = accounts[0].id
  }
}, { immediate: true })

function validate(): boolean {
  const result = schema.safeParse({
    accountId: accountId.value,
    categoryId: categoryId.value ?? '',
    amount: amount.value,
    originalDay: originalDay.value,
    startDate: startDate.value,
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
    note: note.value.trim() || null,
    originalDay: originalDay.value,
    startDate: startDate.value,
    endDate: hasEndDate.value && endDate.value ? endDate.value : null,
  })
}

const dayOptions = Array.from({ length: 31 }, (_, i) => i + 1)
</script>

<template>
  <CommonAppModal
    :open="props.open"
    :title="isEditing ? 'Modifier la récurrence' : 'Nouvelle récurrence'"
    size="lg"
    @close="emit('close')"
  >
    <form class="space-y-5" @submit.prevent="handleSubmit">
      <!-- Toggle Dépense / Revenu -->
      <div class="flex bg-gray-100 dark:bg-gray-800 rounded-xl p-1">
        <button
          type="button"
          :class="[
            'flex-1 py-2 text-sm font-medium rounded-lg transition-colors',
            categoryType === CategoryType.EXPENSE
              ? 'bg-white dark:bg-card-dark text-gray-900 dark:text-white shadow-sm'
              : 'text-gray-500 dark:text-gray-400',
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
              : 'text-gray-500 dark:text-gray-400',
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
        <p v-if="errors.accountId" class="mt-1 text-sm text-error">{{ errors.accountId }}</p>
      </div>

      <!-- Catégorie -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Catégorie
        </label>
        <p v-if="errors.categoryId" class="mb-1 text-sm text-error">{{ errors.categoryId }}</p>
        <CommonCategoryGrid
          v-model="categoryId"
          :type="categoryType"
        />
      </div>

      <!-- Jour du mois -->
      <div class="w-full">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Jour du mois
        </label>
        <select
          v-model="originalDay"
          :class="[
            'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150',
            errors.originalDay ? 'border-error' : 'border-gray-300 dark:border-gray-600',
          ]"
        >
          <option v-for="day in dayOptions" :key="day" :value="day">
            {{ day }}
          </option>
        </select>
        <p v-if="errors.originalDay" class="mt-1 text-sm text-error">{{ errors.originalDay }}</p>
        <p class="mt-1 text-xs text-gray-400 dark:text-gray-500">
          Si le mois a moins de jours, le dernier jour sera utilisé.
        </p>
      </div>

      <!-- Date de début -->
      <div class="w-full">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Date de début
        </label>
        <input
          v-model="startDate"
          type="date"
          :class="[
            'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150',
            errors.startDate ? 'border-error' : 'border-gray-300 dark:border-gray-600',
          ]"
        >
        <p v-if="errors.startDate" class="mt-1 text-sm text-error">{{ errors.startDate }}</p>
      </div>

      <!-- Date de fin (optionnelle) -->
      <div>
        <label class="flex items-center gap-2 text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          <input
            v-model="hasEndDate"
            type="checkbox"
            class="rounded border-gray-300 text-primary focus:ring-primary"
          >
          Définir une date de fin
        </label>
        <input
          v-if="hasEndDate"
          v-model="endDate"
          type="date"
          class="w-full px-4 py-2.5 rounded-[12px] border border-gray-300 dark:border-gray-600 bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150"
        >
      </div>

      <!-- Note -->
      <CommonAppInput
        v-model="note"
        label="Note (optionnelle)"
        placeholder="Ex : Loyer, Abonnement..."
      />

      <!-- Actions -->
      <div class="flex gap-3 pt-2">
        <CommonAppButton
          type="button"
          variant="secondary"
          class="flex-1"
          @click="emit('close')"
        >
          Annuler
        </CommonAppButton>
        <CommonAppButton
          type="submit"
          variant="primary"
          class="flex-1"
        >
          {{ isEditing ? 'Modifier' : 'Créer' }}
        </CommonAppButton>
      </div>
    </form>
  </CommonAppModal>
</template>
