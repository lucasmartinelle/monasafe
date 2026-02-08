<script setup lang="ts">
import { getIcon, getAvailableIconKeys } from '~/utils/icons'
import { intToHex, contrastTextColor } from '~/utils/colors'

interface Props {
  modelValue: string
  color?: number
}

const props = withDefaults(defineProps<Props>(), {
  color: 0xFF1B5E5A,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const PICKER_ICONS = getAvailableIconKeys()

const bgColor = computed(() => intToHex(props.color))
const textColorSelected = computed(() => contrastTextColor(props.color))

function select(key: string) {
  emit('update:modelValue', key)
}
</script>

<template>
  <div class="grid grid-cols-6 sm:grid-cols-8 gap-2">
    <button
      v-for="key in PICKER_ICONS"
      :key="key"
      type="button"
      :class="[
        'flex items-center justify-center w-10 h-10 rounded-xl transition-all duration-150',
        props.modelValue === key
          ? 'ring-2 ring-offset-2 ring-primary dark:ring-offset-card-dark scale-110'
          : 'bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 hover:scale-105',
      ]"
      :style="props.modelValue === key ? { backgroundColor: bgColor, color: textColorSelected } : {}"
      :title="key"
      @click="select(key)"
    >
      <component
        :is="getIcon(key)"
        :class="[
          'h-5 w-5',
          props.modelValue !== key ? 'text-gray-600 dark:text-gray-300' : '',
        ]"
      />
    </button>
  </div>
</template>
