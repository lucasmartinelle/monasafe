<script setup lang="ts">
import { z } from 'zod'
import { AccountType, AccountTypeLabels } from '~/types/enums'

interface Props {
  open: boolean
  accountType: AccountType | null
  error?: string | null
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  error: null,
  loading: false,
})

const emit = defineEmits<{
  close: []
  submit: [data: { name: string; type: AccountType; balance: number; color: number }]
}>()

const defaultNames: Record<AccountType, string> = {
  [AccountType.CHECKING]: 'Compte courant',
  [AccountType.SAVINGS]: 'Compte épargne',
  [AccountType.CASH]: 'Espèces',
}

const defaultColors: Record<AccountType, number> = {
  [AccountType.CHECKING]: 0xFF1B5E5A,
  [AccountType.SAVINGS]: 0xFF4CAF50,
  [AccountType.CASH]: 0xFFFF9800,
}

const name = ref('')
const balance = ref(0)

const schema = z.object({
  balance: z.number(),
})

const errors = ref<Record<string, string>>({})

watch(() => props.open, (isOpen) => {
  if (isOpen && props.accountType) {
    name.value = defaultNames[props.accountType]
    balance.value = 0
    errors.value = {}
  }
})

function validate(): boolean {
  const result = schema.safeParse({
    balance: balance.value,
  })
  if (!result.success) {
    errors.value = {}
    for (const issue of result.error.issues) {
      errors.value[issue.path[0] as string] = issue.message
    }
    return false
  }
  errors.value = {}
  return true
}

function handleSubmit() {
  if (!validate() || !props.accountType) return
  emit('submit', {
    name: name.value.trim(),
    type: props.accountType,
    balance: balance.value,
    color: defaultColors[props.accountType],
  })
}
</script>

<template>
  <CommonAppModal
    :open="open"
    :title="accountType ? `Nouveau compte ${AccountTypeLabels[accountType].toLowerCase()}` : 'Nouveau compte'"
    size="sm"
    @close="emit('close')"
  >
    <form class="space-y-5" @submit.prevent="handleSubmit">
      <!-- Erreur -->
      <div
        v-if="props.error"
        class="p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
      >
        {{ props.error }}
      </div>

      <!-- Solde initial -->
      <CommonAppInput
        v-model="balance"
        type="number"
        label="Solde initial"
        placeholder="0.00"
        :error="errors.balance"
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
          :loading="props.loading"
        >
          Créer
        </CommonAppButton>
      </div>
    </form>
  </CommonAppModal>
</template>
