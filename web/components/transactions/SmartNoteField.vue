<script setup lang="ts">
interface Props {
  modelValue: string
  label?: string
  placeholder?: string
  suggestions?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  label: 'Note',
  placeholder: 'Ajouter une note...',
  suggestions: () => [],
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const showSuggestions = ref(false)
const inputRef = ref<HTMLInputElement | null>(null)

const filteredSuggestions = computed(() => {
  if (!props.modelValue || props.modelValue.length < 2) return []
  const query = props.modelValue.toLowerCase()
  return props.suggestions
    .filter(s => s.toLowerCase().includes(query))
    .slice(0, 5)
})

function onInput(event: Event) {
  const target = event.target as HTMLInputElement
  emit('update:modelValue', target.value)
  showSuggestions.value = true
}

function selectSuggestion(suggestion: string) {
  emit('update:modelValue', suggestion)
  showSuggestions.value = false
  inputRef.value?.focus()
}

function onBlur() {
  setTimeout(() => {
    showSuggestions.value = false
  }, 200)
}
</script>

<template>
  <div class="w-full relative">
    <label v-if="props.label" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
      {{ props.label }}
    </label>
    <input
      ref="inputRef"
      type="text"
      :value="props.modelValue"
      :placeholder="props.placeholder"
      class="w-full px-4 py-2.5 rounded-[12px] border border-gray-300 dark:border-gray-600 bg-white dark:bg-card-dark text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150"
      @input="onInput"
      @focus="showSuggestions = true"
      @blur="onBlur"
    >

    <!-- Suggestions dropdown -->
    <div
      v-if="showSuggestions && filteredSuggestions.length > 0"
      class="absolute z-10 w-full mt-1 bg-white dark:bg-card-dark border border-gray-200 dark:border-gray-600 rounded-xl shadow-lg overflow-hidden"
    >
      <button
        v-for="suggestion in filteredSuggestions"
        :key="suggestion"
        type="button"
        class="w-full px-4 py-2.5 text-left text-sm text-gray-900 dark:text-white hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
        @mousedown.prevent="selectSuggestion(suggestion)"
      >
        {{ suggestion }}
      </button>
    </div>
  </div>
</template>
