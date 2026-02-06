<script setup lang="ts">
interface Props {
  modelValue?: string | number
  type?: 'text' | 'email' | 'password' | 'number'
  label?: string
  placeholder?: string
  error?: string
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  type: 'text',
  label: undefined,
  placeholder: '',
  error: undefined,
  disabled: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
}>()

function onInput(event: Event) {
  const target = event.target as HTMLInputElement
  const value = props.type === 'number' ? Number(target.value) : target.value
  emit('update:modelValue', value)
}
</script>

<template>
  <div class="w-full">
    <label v-if="props.label" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
      {{ props.label }}
    </label>
    <input
      :type="props.type"
      :value="props.modelValue"
      :placeholder="props.placeholder"
      :disabled="props.disabled"
      :class="[
        'w-full px-4 py-2.5 rounded-[12px] border bg-white dark:bg-card-dark text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500 transition-colors duration-150',
        'focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary',
        props.error
          ? 'border-error focus:ring-error/50 focus:border-error'
          : 'border-gray-300 dark:border-gray-600',
        props.disabled ? 'opacity-50 cursor-not-allowed' : '',
      ]"
      @input="onInput"
    >
    <p v-if="props.error" class="mt-1 text-sm text-error">
      {{ props.error }}
    </p>
  </div>
</template>
