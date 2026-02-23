<script setup lang="ts">
import type { Account } from '~/types/models'

interface Props {
  open: boolean
  account: Account | null
  computedBalance?: number | null
  error?: string | null
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  computedBalance: null,
  error: null,
  loading: false,
})

const emit = defineEmits<{
  close: []
  submit: [data: { balance: number }]
}>()

const { format: formatMoney } = useCurrency()

const newBalance = ref(0)

watch(() => props.open, (isOpen) => {
  if (isOpen && props.account) {
    newBalance.value = props.account.balance
  }
})

// previewBalance = newInitial + net (net = solde calculé actuel - solde initial actuel)
const previewBalance = computed(() => {
  if (props.computedBalance === null || !props.account) return null
  const net = props.computedBalance - props.account.balance
  return newBalance.value + net
})

function handleSubmit() {
  emit('submit', { balance: newBalance.value })
}
</script>

<template>
  <CommonAppModal
    :open="open"
    :title="account?.name ?? 'Modifier le solde initial'"
    size="sm"
    @close="emit('close')"
  >
    <div class="space-y-4">
      <!-- Erreur -->
      <div
        v-if="props.error"
        class="p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
      >
        {{ props.error }}
      </div>

      <!-- Solde initial -->
      <CommonAppInput
        v-model="newBalance"
        type="number"
        label="Solde initial"
        placeholder="0.00"
      />

      <!-- Aperçu solde calculé avec transactions -->
      <div
        class="flex items-center justify-between px-4 py-3 rounded-xl border"
        :class="previewBalance !== null
          ? 'bg-primary/10 dark:bg-primary/15 border-primary/20'
          : 'bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700'"
      >
        <span class="text-sm text-gray-500 dark:text-gray-400">
          Solde calculé avec transactions
        </span>
        <span
          v-if="previewBalance !== null"
          class="text-sm font-semibold"
          :class="previewBalance >= 0 ? 'text-success' : 'text-error'"
        >
          {{ formatMoney(previewBalance) }}
        </span>
        <span
          v-else
          class="h-4 w-16 rounded bg-gray-200 dark:bg-gray-700 animate-pulse"
        />
      </div>

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
          variant="primary"
          class="flex-1"
          :loading="props.loading"
          @click="handleSubmit"
        >
          Enregistrer
        </CommonAppButton>
      </div>
    </div>
  </CommonAppModal>
</template>
