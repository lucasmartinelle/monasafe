<script setup lang="ts">
import type { PeriodType } from '~/composables/useStatistics'

interface Props {
  modelValue: PeriodType
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: PeriodType]
}>()

const options: { value: PeriodType; label: string }[] = [
  { value: 'thisMonth', label: 'Ce mois' },
  { value: 'lastMonth', label: 'Mois dernier' },
  { value: 'yearToDate', label: 'Année' },
]
</script>

<template>
  <div class="flex gap-2">
    <button
      v-for="opt in options"
      :key="opt.value"
      type="button"
      :class="[
        'px-4 py-2 rounded-xl text-sm font-medium border transition-colors',
        props.modelValue === opt.value
          ? 'bg-primary text-white border-primary'
          : 'bg-white dark:bg-card-dark text-gray-700 dark:text-gray-300 border-gray-200 dark:border-gray-600 hover:border-primary/50',
      ]"
      @click="emit('update:modelValue', opt.value)"
    >
      {{ opt.label }}
    </button>
  </div>
</template>
