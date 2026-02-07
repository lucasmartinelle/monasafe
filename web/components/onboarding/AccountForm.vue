<script setup lang="ts">
import { z } from 'zod'
import type { Account } from '~/types/models'
import { AccountType, AccountTypeLabels } from '~/types/enums'
import { COLOR_PALETTE } from '~/utils/colors'

interface Props {
  account?: Account | null
}

const props = withDefaults(defineProps<Props>(), {
  account: null,
})

const emit = defineEmits<{
  submit: [data: { name: string; type: AccountType; balance: number; color: number }]
  cancel: []
}>()

const isEditing = computed(() => !!props.account)

// Form state
const name = ref(props.account?.name ?? '')
const type = ref<AccountType>(props.account?.type ?? AccountType.CHECKING)
const balance = ref(props.account?.balance ?? 0)
const color = ref(props.account?.color ?? COLOR_PALETTE[0])

// Validation
const schema = z.object({
  name: z.string().min(1, 'Le nom est requis').max(50, '50 caractères maximum'),
  type: z.nativeEnum(AccountType),
  balance: z.number(),
  color: z.number(),
})

const errors = ref<Record<string, string>>({})

function validate(): boolean {
  const result = schema.safeParse({
    name: name.value,
    type: type.value,
    balance: balance.value,
    color: color.value,
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
    name: name.value.trim(),
    type: type.value,
    balance: balance.value,
    color: color.value,
  })
}

// Sync props → state si l'account change (mode édition)
watch(() => props.account, (newVal) => {
  if (newVal) {
    name.value = newVal.name
    type.value = newVal.type
    balance.value = newVal.balance
    color.value = newVal.color
  }
})
</script>

<template>
  <form class="space-y-5" @submit.prevent="handleSubmit">
    <!-- Nom -->
    <CommonAppInput
      v-model="name"
      label="Nom du compte"
      placeholder="Ex : Compte courant"
      :error="errors.name"
    />

    <!-- Type -->
    <div class="w-full">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
        Type de compte
      </label>
      <select
        v-model="type"
        class="w-full px-4 py-2.5 rounded-[12px] border border-gray-300 dark:border-gray-600 bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150"
      >
        <option
          v-for="(label, key) in AccountTypeLabels"
          :key="key"
          :value="key"
        >
          {{ label }}
        </option>
      </select>
    </div>

    <!-- Solde initial -->
    <CommonAppInput
      v-model="balance"
      type="number"
      :label="isEditing ? 'Solde' : 'Solde initial'"
      placeholder="0.00"
      :error="errors.balance"
    />

    <!-- Couleur -->
    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        Couleur
      </label>
      <CommonColorPicker v-model="color" />
    </div>

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
      >
        {{ isEditing ? 'Modifier' : 'Créer' }}
      </CommonAppButton>
    </div>
  </form>
</template>
