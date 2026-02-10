<script setup lang="ts">
import type { BudgetProgress } from '~/types/models'
import { getBudgetStatus, getBudgetPercentage } from '~/composables/useStatistics'
import { intToHex } from '~/utils/colors'
import { getIcon } from '~/utils/icons'

interface Props {
  progress: BudgetProgress
}

const props = defineProps<Props>()
const emit = defineEmits<{
  click: []
}>()

const { format: formatMoney } = useCurrency()

const percentage = computed(() => getBudgetPercentage(props.progress.currentSpending, props.progress.budgetLimit))
const status = computed(() => getBudgetStatus(props.progress.currentSpending, props.progress.budgetLimit))
const remaining = computed(() => props.progress.budgetLimit - props.progress.currentSpending)

const barWidth = computed(() => Math.min(percentage.value, 100))

const statusColor = computed(() => {
  switch (status.value) {
    case 'safe': return 'bg-green-500'
    case 'warning': return 'bg-orange-500'
    case 'exceeded': return 'bg-red-500'
    default: return 'bg-green-500'
  }
})

const statusTextColor = computed(() => {
  switch (status.value) {
    case 'safe': return 'text-green-600 dark:text-green-400'
    case 'warning': return 'text-orange-600 dark:text-orange-400'
    case 'exceeded': return 'text-red-600 dark:text-red-400'
    default: return 'text-green-600 dark:text-green-400'
  }
})
</script>

<template>
  <button
    type="button"
    class="w-full text-left bg-white dark:bg-card-dark rounded-xl p-4 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
    @click="emit('click')"
  >
    <div class="flex items-center gap-3">
      <!-- Icône catégorie -->
      <div
        class="flex items-center justify-center h-9 w-9 rounded-lg shrink-0"
        :style="{ backgroundColor: intToHex(props.progress.category.color) + '20' }"
      >
        <component
          :is="getIcon(props.progress.category.iconKey)"
          class="h-5 w-5"
          :style="{ color: intToHex(props.progress.category.color) }"
        />
      </div>

      <!-- Contenu -->
      <div class="flex-1 min-w-0">
        <div class="flex items-center justify-between mb-1">
          <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
            {{ props.progress.category.name }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400 shrink-0 ml-2">
            {{ formatMoney(props.progress.currentSpending) }} / {{ formatMoney(props.progress.budgetLimit) }}
          </p>
        </div>

        <!-- Barre de progression -->
        <div class="h-2 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
          <div
            :class="['h-full rounded-full transition-all duration-500', statusColor]"
            :style="{ width: `${barWidth}%` }"
          />
        </div>

        <div class="flex items-center justify-between mt-1">
          <p :class="['text-xs', statusTextColor]">
            <template v-if="remaining >= 0">
              Reste {{ formatMoney(remaining) }}
            </template>
            <template v-else>
              Dépassé de {{ formatMoney(Math.abs(remaining)) }}
            </template>
          </p>
          <p :class="['text-xs font-medium', statusTextColor]">
            {{ Math.round(percentage) }}%
          </p>
        </div>
      </div>
    </div>
  </button>
</template>
