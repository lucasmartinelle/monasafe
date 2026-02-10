<script setup lang="ts">
import { ArrowLeftIcon } from '@heroicons/vue/24/outline'
import { parseISO } from 'date-fns'

useSeoMeta({
  title: 'Nouvelle transaction — SimpleFlow',
  description: 'Ajoutez une nouvelle transaction à vos comptes SimpleFlow.',
})

definePageMeta({
  layout: 'default',
})

const router = useRouter()
const { createTransaction, isLoading: txLoading, error: txError } = useTransactions()
const { createRecurring, isLoading: recLoading, error: recError } = useRecurring()

const isLoading = computed(() => txLoading.value || recLoading.value)
const error = computed(() => txError.value || recError.value)

async function handleSubmit(data: {
  accountId: string
  categoryId: string
  amount: number
  date: string
  note: string | null
  isRecurring: boolean
}) {
  if (data.isRecurring) {
    // 1. Créer la récurrence
    const startDate = parseISO(data.date)
    const recurring = await createRecurring({
      accountId: data.accountId,
      categoryId: data.categoryId,
      amount: data.amount,
      note: data.note,
      originalDay: startDate.getDate(),
      startDate: data.date,
      lastGenerated: data.date,
    })
    if (!recurring) return

    // 2. Créer la première occurrence liée
    const result = await createTransaction({
      accountId: data.accountId,
      categoryId: data.categoryId,
      amount: data.amount,
      date: data.date,
      note: data.note,
      recurringId: recurring.id,
    })
    if (result) router.push('/dashboard')
  } else {
    const result = await createTransaction(data)
    if (result) router.push('/dashboard')
  }
}

function handleCancel() {
  router.back()
}
</script>

<template>
  <div class="max-w-lg mx-auto">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink
        to="/dashboard"
        class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
      >
        <ArrowLeftIcon class="h-5 w-5 text-gray-600 dark:text-gray-400" />
      </NuxtLink>
      <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
        Nouvelle transaction
      </h1>
    </div>

    <!-- Erreur -->
    <div
      v-if="error"
      class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
    >
      {{ error }}
    </div>

    <!-- Formulaire -->
    <div class="bg-white dark:bg-card-dark rounded-xl p-6">
      <TransactionsTransactionForm
        :loading="isLoading"
        @submit="handleSubmit"
        @cancel="handleCancel"
      />
    </div>
  </div>
</template>
