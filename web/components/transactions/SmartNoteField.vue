<script setup lang="ts">
import type { Transaction, Category } from '~/types/models'

interface NoteSuggestion {
  note: string
  transaction: Transaction
  category: Category | null
}

interface Props {
  modelValue: string
  label?: string
  placeholder?: string
  suggestions?: NoteSuggestion[]
}

const props = withDefaults(defineProps<Props>(), {
  label: 'Note',
  placeholder: 'Ajouter une note...',
  suggestions: () => [],
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
  'select-suggestion': [suggestion: NoteSuggestion]
}>()

const { format: formatMoney } = useCurrency()

const showSuggestions = ref(false)
const inputRef = ref<HTMLInputElement | null>(null)

// Debounce la recherche pour éviter de filtrer à chaque frappe
const searchQuery = refDebounced(computed(() => props.modelValue), 200)

const filteredSuggestions = computed(() => {
  if (!searchQuery.value || searchQuery.value.length < 2) return []
  const query = searchQuery.value.toLowerCase()
  return props.suggestions
    .filter(s => s.note.toLowerCase().includes(query))
    .slice(0, 5)
})

function onInput(event: Event) {
  const target = event.target as HTMLInputElement
  emit('update:modelValue', target.value)
  showSuggestions.value = true
}

function selectSuggestion(suggestion: NoteSuggestion) {
  emit('update:modelValue', suggestion.note)
  emit('select-suggestion', suggestion)
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
        :key="suggestion.transaction.id"
        type="button"
        class="w-full px-4 py-2.5 text-left hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors flex items-center gap-3"
        @mousedown.prevent="selectSuggestion(suggestion)"
      >
        <CommonCategoryIcon
          v-if="suggestion.category"
          :icon-key="suggestion.category.iconKey"
          :color="suggestion.category.color"
          size="sm"
        />
        <div class="flex-1 min-w-0">
          <p class="text-sm text-gray-900 dark:text-white truncate">
            {{ suggestion.note }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400">
            {{ suggestion.category?.name ?? '' }}
          </p>
        </div>
        <p class="text-xs font-medium text-gray-500 dark:text-gray-400 shrink-0">
          {{ formatMoney(Math.abs(suggestion.transaction.amount)) }}
        </p>
      </button>
    </div>
  </div>
</template>
