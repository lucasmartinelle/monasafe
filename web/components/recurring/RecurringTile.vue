<script setup lang="ts">
import type { RecurringTransaction, Account, Category } from '~/types/models'
import { CategoryType } from '~/types/enums'
import { PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

interface Props {
  recurring: RecurringTransaction
  account?: Account | null
  category?: Category | null
  nextDate?: Date | null
}

const props = withDefaults(defineProps<Props>(), {
  account: null,
  category: null,
  nextDate: null,
})

const emit = defineEmits<{
  edit: [recurring: RecurringTransaction]
  delete: [recurring: RecurringTransaction]
  toggle: [recurring: RecurringTransaction]
}>()

const { format: formatMoney } = useCurrency()

const isExpense = computed(() => props.category?.type === CategoryType.EXPENSE)

const formattedAmount = computed(() => {
  const sign = isExpense.value ? '-' : '+'
  return `${sign}${formatMoney(Math.abs(props.recurring.amount))}`
})

const amountColor = computed(() =>
  isExpense.value ? 'text-error' : 'text-success',
)

const nextDateLabel = computed(() => {
  if (!props.nextDate) return null
  return `Prochain : le ${format(props.nextDate, 'd MMMM', { locale: fr })}`
})

const dayLabel = computed(() => {
  const day = props.recurring.originalDay
  return `Le ${day} de chaque mois`
})
</script>

<template>
  <div :class="[
    'flex items-center gap-3 px-4 py-3 bg-white dark:bg-card-dark rounded-xl transition-opacity',
    !props.recurring.isActive ? 'opacity-50' : '',
  ]">
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
        {{ props.recurring.note || (props.category?.name ?? 'Sans note') }}
      </p>
      <p class="text-xs text-gray-500 dark:text-gray-400 truncate">
        <span>{{ dayLabel }}</span>
        <span v-if="props.account" class="ml-1">&middot; {{ props.account.name }}</span>
      </p>
      <p
        v-if="nextDateLabel && props.recurring.isActive"
        class="text-xs text-primary dark:text-primary-light mt-0.5"
      >
        {{ nextDateLabel }}
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
      <!-- Toggle actif -->
      <button
        type="button"
        :class="[
          'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
          props.recurring.isActive ? 'bg-primary' : 'bg-gray-300 dark:bg-gray-600',
        ]"
        @click="emit('toggle', props.recurring)"
      >
        <span
          :class="[
            'inline-block h-4 w-4 rounded-full bg-white transition-transform',
            props.recurring.isActive ? 'translate-x-6' : 'translate-x-1',
          ]"
        />
      </button>

      <button
        type="button"
        class="p-2 rounded-lg text-gray-400 hover:text-primary hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        title="Modifier"
        @click="emit('edit', props.recurring)"
      >
        <PencilIcon class="h-4 w-4" />
      </button>
      <button
        type="button"
        class="p-2 rounded-lg text-gray-400 hover:text-error hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
        title="Supprimer"
        @click="emit('delete', props.recurring)"
      >
        <TrashIcon class="h-4 w-4" />
      </button>
    </div>
  </div>
</template>
