<script setup lang="ts">
import type { Transaction, Account, Category } from '~/types/models'
import { CategoryType } from '~/types/enums'
import { formatRelativeDate } from '~/utils/dates'
import { PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'

interface Props {
  transaction: Transaction
  account?: Account | null
  category?: Category | null
}

const props = withDefaults(defineProps<Props>(), {
  account: null,
  category: null,
})

const emit = defineEmits<{
  edit: [transaction: Transaction]
  delete: [transaction: Transaction]
}>()

const { format: formatMoney } = useCurrency()

const isExpense = computed(() => props.category?.type === CategoryType.EXPENSE)

const formattedAmount = computed(() => {
  const sign = isExpense.value ? '-' : '+'
  return `${sign}${formatMoney(Math.abs(props.transaction.amount))}`
})

const amountColor = computed(() =>
  isExpense.value ? 'text-error' : 'text-success',
)
</script>

<template>
  <div class="flex items-center gap-3 px-4 py-3 bg-white dark:bg-card-dark rounded-xl">
    <!-- Icône catégorie -->
    <CommonCategoryIcon
      v-if="props.category"
      :icon-key="props.category.iconKey"
      :color="props.category.color"
      size="md"
    />

    <!-- Infos -->
    <div class="flex-1 min-w-0">
      <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
        {{ props.category?.name ?? 'Catégorie inconnue' }}
      </p>
      <p class="text-xs text-gray-500 dark:text-gray-400 truncate">
        <span>{{ formatRelativeDate(props.transaction.date) }}</span>
        <span v-if="props.account" class="ml-1">&middot; {{ props.account.name }}</span>
        <span v-if="props.transaction.note" class="ml-1">&middot; {{ props.transaction.note }}</span>
      </p>
    </div>

    <!-- Montant -->
    <div class="text-right shrink-0">
      <p :class="['text-sm font-semibold', amountColor]">
        {{ formattedAmount }}
      </p>
    </div>

    <!-- Actions -->
    <div class="flex items-center gap-1 shrink-0">
      <button
        type="button"
        class="p-2 rounded-lg text-gray-400 hover:text-primary hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        title="Modifier"
        @click="emit('edit', props.transaction)"
      >
        <PencilIcon class="h-4 w-4" />
      </button>
      <button
        type="button"
        class="p-2 rounded-lg text-gray-400 hover:text-error hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
        title="Supprimer"
        @click="emit('delete', props.transaction)"
      >
        <TrashIcon class="h-4 w-4" />
      </button>
    </div>
  </div>
</template>
