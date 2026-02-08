<script setup lang="ts">
import type { Category } from '~/types/models'
import { CategoryType } from '~/types/enums'

interface Props {
  modelValue: string | null
  type?: CategoryType | null
}

const props = withDefaults(defineProps<Props>(), {
  type: null,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const { categories, fetchCategories } = useCategories()

onMounted(() => {
  if (categories.value.length === 0) {
    fetchCategories()
  }
})

const filteredCategories = computed(() => {
  if (!props.type) return categories.value
  return categories.value.filter(c => c.type === props.type)
})

function select(category: Category) {
  emit('update:modelValue', category.id)
}
</script>

<template>
  <div class="grid grid-cols-4 sm:grid-cols-5 gap-3">
    <button
      v-for="cat in filteredCategories"
      :key="cat.id"
      type="button"
      :class="[
        'flex flex-col items-center gap-1.5 p-2 rounded-xl transition-all duration-150',
        props.modelValue === cat.id
          ? 'bg-primary/10 ring-2 ring-primary dark:ring-primary-light'
          : 'hover:bg-gray-100 dark:hover:bg-gray-700',
      ]"
      @click="select(cat)"
    >
      <CommonCategoryIcon
        :icon-key="cat.iconKey"
        :color="cat.color"
        size="md"
      />
      <span class="text-xs text-gray-600 dark:text-gray-400 truncate w-full text-center">
        {{ cat.name }}
      </span>
    </button>
  </div>
</template>
