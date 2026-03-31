<script setup lang="ts">
import { z } from 'zod'
import { toISODateString } from '~/utils/dates'

interface Props {
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
})

const emit = defineEmits<{
  submit: [data: {
    fromAccountId: string
    toAccountId: string
    fromAccountName: string
    toAccountName: string
    amount: number
    date: string
    note: string | null
  }]
  cancel: []
}>()

const { sortedAccounts, fetchAccounts } = useAccounts()

// Form state
const fromAccountId = ref('')
const toAccountId = ref('')
const amount = ref(0)
const date = ref(toISODateString(new Date()))
const note = ref('')

const errors = ref<Record<string, string>>({})

const hasMultipleAccounts = computed(() => sortedAccounts.value.length >= 2)

const availableToAccounts = computed(() =>
  sortedAccounts.value.filter(a => a.id !== fromAccountId.value),
)

const availableFromAccounts = computed(() =>
  sortedAccounts.value.filter(a => a.id !== toAccountId.value),
)

// Synchronisation automatique des comptes
watch(sortedAccounts, (accounts) => {
  if (accounts.length >= 1 && !fromAccountId.value) {
    fromAccountId.value = accounts[0]!.id
  }
  if (accounts.length >= 2 && !toAccountId.value) {
    toAccountId.value = accounts[1]!.id
  }
}, { immediate: true })

// Si fromAccount change, s'assurer que toAccount est différent
watch(fromAccountId, (newId) => {
  if (toAccountId.value === newId) {
    const other = sortedAccounts.value.find(a => a.id !== newId)
    toAccountId.value = other?.id ?? ''
  }
})

// Si toAccount change, s'assurer que fromAccount est différent
watch(toAccountId, (newId) => {
  if (fromAccountId.value === newId) {
    const other = sortedAccounts.value.find(a => a.id !== newId)
    fromAccountId.value = other?.id ?? ''
  }
})

onMounted(() => {
  if (sortedAccounts.value.length === 0) {
    fetchAccounts()
  }
})

// Validation
const schema = z.object({
  fromAccountId: z.string().min(1, 'Choisissez le compte source'),
  toAccountId: z.string().min(1, 'Choisissez le compte destination'),
  amount: z.number().positive('Le montant doit être positif'),
  date: z.string().min(1, 'La date est requise'),
}).refine(data => data.fromAccountId !== data.toAccountId, {
  message: 'Les deux comptes doivent être différents',
  path: ['toAccountId'],
})

function validate(): boolean {
  const result = schema.safeParse({
    fromAccountId: fromAccountId.value,
    toAccountId: toAccountId.value,
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

  const fromAccount = sortedAccounts.value.find(a => a.id === fromAccountId.value)
  const toAccount = sortedAccounts.value.find(a => a.id === toAccountId.value)

  emit('submit', {
    fromAccountId: fromAccountId.value,
    toAccountId: toAccountId.value,
    fromAccountName: fromAccount?.name ?? '',
    toAccountName: toAccount?.name ?? '',
    amount: amount.value,
    date: date.value,
    note: note.value.trim() || null,
  })
}
</script>

<template>
  <form class="space-y-5" @submit.prevent="handleSubmit">

    <!-- Avertissement si moins de 2 comptes -->
    <div
      v-if="!hasMultipleAccounts"
      class="flex items-start gap-3 p-4 bg-yellow-50 dark:bg-yellow-900/20 rounded-xl"
    >
      <span class="text-yellow-500 text-lg shrink-0">⚠️</span>
      <p class="text-sm text-yellow-700 dark:text-yellow-300">
        Vous devez avoir au moins deux comptes pour effectuer un virement.
      </p>
    </div>

    <template v-else>
      <!-- Montant -->
      <TransactionsAmountInput
        v-model="amount"
        :error="errors.amount"
      />

      <!-- Sélection des comptes -->
      <div class="grid grid-cols-[1fr_auto_1fr] items-end gap-3">
        <!-- Compte source -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Depuis
          </label>
          <select
            v-model="fromAccountId"
            :class="[
              'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150',
              errors.fromAccountId ? 'border-error' : 'border-gray-300 dark:border-gray-600',
            ]"
          >
            <option value="" disabled>Choisir</option>
            <option
              v-for="account in availableFromAccounts"
              :key="account.id"
              :value="account.id"
            >
              {{ account.name }}
            </option>
          </select>
          <p v-if="errors.fromAccountId" class="mt-1 text-xs text-error">
            {{ errors.fromAccountId }}
          </p>
        </div>

        <!-- Flèche -->
        <div class="flex items-center justify-center pb-2">
          <div class="w-8 h-8 rounded-full bg-primary flex items-center justify-center shrink-0">
            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
            </svg>
          </div>
        </div>

        <!-- Compte destination -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
            Vers
          </label>
          <select
            v-model="toAccountId"
            :class="[
              'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150',
              errors.toAccountId ? 'border-error' : 'border-gray-300 dark:border-gray-600',
            ]"
          >
            <option value="" disabled>Choisir</option>
            <option
              v-for="account in availableToAccounts"
              :key="account.id"
              :value="account.id"
            >
              {{ account.name }}
            </option>
          </select>
          <p v-if="errors.toAccountId" class="mt-1 text-xs text-error">
            {{ errors.toAccountId }}
          </p>
        </div>
      </div>

      <!-- Date -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Date
        </label>
        <input
          v-model="date"
          type="date"
          :max="toISODateString(new Date())"
          :class="[
            'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150',
            errors.date ? 'border-error' : 'border-gray-300 dark:border-gray-600',
          ]"
        >
        <p v-if="errors.date" class="mt-1 text-sm text-error">
          {{ errors.date }}
        </p>
      </div>

      <!-- Note optionnelle -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Note <span class="text-gray-400 font-normal">(optionnel)</span>
        </label>
        <input
          v-model="note"
          type="text"
          placeholder="Ex : épargne mensuelle"
          class="w-full px-4 py-2.5 rounded-[12px] border border-gray-300 dark:border-gray-600 bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150"
        >
      </div>
    </template>

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
        :disabled="!hasMultipleAccounts"
      >
        Confirmer le virement
      </CommonAppButton>
    </div>
  </form>
</template>
