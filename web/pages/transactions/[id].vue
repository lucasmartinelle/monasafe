<script setup lang="ts">
import { ArrowLeftIcon } from '@heroicons/vue/24/outline'

definePageMeta({
  layout: 'default',
})

const route = useRoute()
const router = useRouter()

const {
  transactionById,
  updateTransaction,
  fetchTransactions,
  isLoading,
  error,
} = useTransactions()

const transactionId = computed(() => route.params.id as string)
const transaction = computed(() => transactionById.value(transactionId.value))

// Charger la transaction si pas déjà en store
onMounted(async () => {
  if (!transaction.value) {
    await fetchTransactions()
  }
})

async function handleSubmit(data: {
  accountId: string
  categoryId: string
  amount: number
  date: string
  note: string | null
  isRecurring: boolean
}) {
  const result = await updateTransaction(transactionId.value, data)
  if (result) {
    router.push('/dashboard')
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
        Modifier la transaction
      </h1>
    </div>

    <!-- Erreur -->
    <div
      v-if="error"
      class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
    >
      {{ error }}
    </div>

    <!-- Loading -->
    <CommonLoadingState v-if="isLoading && !transaction" />

    <!-- Formulaire -->
    <div v-else-if="transaction" class="bg-white dark:bg-card-dark rounded-xl p-6">
      <TransactionsTransactionForm
        :transaction="transaction"
        :loading="isLoading"
        @submit="handleSubmit"
        @cancel="handleCancel"
      />
    </div>

    <!-- Transaction non trouvée -->
    <div
      v-else
      class="text-center py-12 text-gray-500 dark:text-gray-400"
    >
      <p class="text-sm">Transaction introuvable</p>
      <NuxtLink to="/dashboard" class="mt-3 inline-block">
        <CommonAppButton variant="secondary" size="sm">
          Retour aux transactions
        </CommonAppButton>
      </NuxtLink>
    </div>
  </div>
</template>
