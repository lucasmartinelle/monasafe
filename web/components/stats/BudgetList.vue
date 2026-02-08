<script setup lang="ts">
import { PlusIcon } from '@heroicons/vue/24/outline'
import type { BudgetProgress } from '~/types/models'

interface Props {
  budgets: BudgetProgress[]
}

defineProps<Props>()
const emit = defineEmits<{
  create: []
  select: [progress: BudgetProgress]
}>()
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-3">
      <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">
        Budgets
      </h3>
      <button
        type="button"
        class="p-1.5 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        @click="emit('create')"
      >
        <PlusIcon class="h-5 w-5 text-gray-500 dark:text-gray-400" />
      </button>
    </div>

    <div v-if="budgets.length > 0" class="space-y-2">
      <StatsBudgetProgressBar
        v-for="bp in budgets"
        :key="bp.budgetId"
        :progress="bp"
        @click="emit('select', bp)"
      />
    </div>

    <div v-else class="bg-white dark:bg-card-dark rounded-xl p-6 text-center">
      <p class="text-sm text-gray-500 dark:text-gray-400 mb-3">
        Aucun budget configuré
      </p>
      <CommonAppButton variant="primary" size="sm" @click="emit('create')">
        <PlusIcon class="h-4 w-4 mr-1" />
        Créer un budget
      </CommonAppButton>
    </div>
  </div>
</template>
