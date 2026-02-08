<script setup lang="ts">
interface Props {
  modelValue: number
  error?: string
  label?: string
}

const props = withDefaults(defineProps<Props>(), {
  error: undefined,
  label: 'Montant',
})

const emit = defineEmits<{
  'update:modelValue': [value: number]
}>()

const displayValue = ref('')

function formatForDisplay(value: number): string {
  if (value === 0) return ''
  return value.toFixed(2).replace('.', ',')
}

function parseInput(raw: string): number {
  const cleaned = raw.replace(/[^\d,.-]/g, '').replace(',', '.')
  const parsed = parseFloat(cleaned)
  return isNaN(parsed) ? 0 : Math.round(parsed * 100) / 100
}

function onInput(event: Event) {
  const target = event.target as HTMLInputElement
  displayValue.value = target.value
  emit('update:modelValue', parseInput(target.value))
}

function onBlur() {
  if (props.modelValue > 0) {
    displayValue.value = formatForDisplay(props.modelValue)
  }
}

watch(
  () => props.modelValue,
  (val) => {
    if (document.activeElement?.closest('[data-amount-input]')) return
    displayValue.value = formatForDisplay(val)
  },
  { immediate: true },
)
</script>

<template>
  <div class="w-full" data-amount-input>
    <label v-if="props.label" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
      {{ props.label }}
    </label>
    <div class="relative">
      <input
        type="text"
        inputmode="decimal"
        :value="displayValue"
        placeholder="0,00"
        :class="[
          'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500 transition-colors duration-150 text-right text-lg font-semibold',
          'focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary',
          props.error
            ? 'border-error focus:ring-error/50 focus:border-error'
            : 'border-gray-300 dark:border-gray-600',
        ]"
        @input="onInput"
        @blur="onBlur"
      >
    </div>
    <p v-if="props.error" class="mt-1 text-sm text-error">
      {{ props.error }}
    </p>
  </div>
</template>
