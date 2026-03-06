<script setup lang="ts">
import { getLucideIcon } from '~/utils/icons'
import { intToHex, contrastTextColor } from '~/utils/colors'

interface Props {
  modelValue: string
  color?: number
}

interface IconEntry {
  name: string
  fr: string
  tags: string[]
}

const props = withDefaults(defineProps<Props>(), {
  color: 0xFF1B5E5A,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const search = ref('')
const allIcons = ref<IconEntry[]>([])
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await fetch('/icons.json')
    allIcons.value = await res.json()
  } catch {
    allIcons.value = []
  } finally {
    loading.value = false
  }
})

const filteredIcons = computed(() => {
  const q = search.value.trim().toLowerCase()
  if (!q) return allIcons.value
  return allIcons.value.filter(i =>
    i.fr.toLowerCase().includes(q)
    || i.name.replace(/-/g, ' ').includes(q)
    || i.tags.some(t => t.toLowerCase().includes(q)),
  )
})

const bgColor = computed(() => intToHex(props.color))
const textColorSelected = computed(() => contrastTextColor(props.color))
</script>

<template>
  <div class="flex flex-col gap-2">
    <div class="relative">
      <input
        v-model="search"
        type="text"
        placeholder="Rechercher (ex : voiture, sport…)"
        class="w-full px-3 py-2 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50"
      >
      <button
        v-if="search"
        type="button"
        class="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
        @click="search = ''"
      >
        ✕
      </button>
    </div>

    <div v-if="loading" class="flex justify-center py-6">
      <div class="animate-spin h-6 w-6 border-2 border-primary border-t-transparent rounded-full" />
    </div>

    <p v-else-if="filteredIcons.length === 0" class="text-center text-sm text-gray-400 py-4">
      Aucune icône trouvée
    </p>

    <div v-else class="grid grid-cols-6 sm:grid-cols-10 gap-1.5 max-h-52 overflow-y-auto pr-1">
      <button
        v-for="icon in filteredIcons"
        :key="icon.name"
        type="button"
        :class="[
          'flex items-center justify-center w-10 h-10 rounded-xl transition-all duration-150',
          props.modelValue === icon.name
            ? 'ring-2 ring-offset-1 ring-primary dark:ring-offset-card-dark scale-110'
            : 'bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 hover:scale-105',
        ]"
        :style="props.modelValue === icon.name ? { backgroundColor: bgColor, color: textColorSelected } : {}"
        :title="icon.fr"
        @click="emit('update:modelValue', icon.name)"
      >
        <component :is="getLucideIcon(icon.name)" :size="20" class="select-none" />
      </button>
    </div>
  </div>
</template>
