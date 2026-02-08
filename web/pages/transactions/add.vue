<script setup lang="ts">
import { ArrowLeftIcon } from '@heroicons/vue/24/outline'

definePageMeta({
  layout: 'default',
})

const router = useRouter()
const { createTransaction, isLoading, error } = useTransactions()

async function handleSubmit(data: {
  accountId: string
  categoryId: string
  amount: number
  date: string
  note: string | null
}) {
  const result = await createTransaction(data)
  if (result) {
    router.push('/transactions')
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
        to="/transactions"
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
