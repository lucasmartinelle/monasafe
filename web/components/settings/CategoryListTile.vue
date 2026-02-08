<script setup lang="ts">
import type { Category } from '~/types/models'
import { PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'

interface Props {
  category: Category
}

const props = defineProps<Props>()

const emit = defineEmits<{
  edit: [category: Category]
  delete: [category: Category]
}>()
</script>

<template>
  <div class="flex items-center gap-3 px-4 py-3 bg-white dark:bg-card-dark rounded-xl">
    <!-- Icône catégorie -->
    <CommonCategoryIcon
      :icon-key="props.category.iconKey"
      :color="props.category.color"
      size="md"
    />

    <!-- Nom -->
    <div class="flex-1 min-w-0">
      <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
        {{ props.category.name }}
      </p>
      <p v-if="props.category.isDefault" class="text-xs text-gray-500 dark:text-gray-400">
        Par défaut
      </p>
    </div>

    <!-- Actions (uniquement si non default) -->
    <div v-if="!props.category.isDefault" class="flex items-center gap-1">
      <button
        type="button"
        class="p-2 rounded-lg text-gray-400 hover:text-primary hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        title="Modifier"
        @click="emit('edit', props.category)"
      >
        <PencilIcon class="h-4 w-4" />
      </button>
      <button
        type="button"
        class="p-2 rounded-lg text-gray-400 hover:text-error hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
        title="Supprimer"
        @click="emit('delete', props.category)"
      >
        <TrashIcon class="h-4 w-4" />
      </button>
    </div>
  </div>
</template>
