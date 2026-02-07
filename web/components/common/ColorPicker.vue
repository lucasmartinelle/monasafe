<script setup lang="ts">
import { COLOR_PALETTE, intToHex, contrastTextColor } from '~/utils/colors'
import { CheckIcon } from '@heroicons/vue/24/outline'

interface Props {
  modelValue: number
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:modelValue': [value: number]
}>()

function select(color: number) {
  emit('update:modelValue', color)
}
</script>

<template>
  <div class="grid grid-cols-5 gap-3">
    <button
      v-for="color in COLOR_PALETTE"
      :key="color"
      type="button"
      :class="[
        'w-10 h-10 rounded-full flex items-center justify-center transition-transform duration-150',
        props.modelValue === color ? 'ring-2 ring-offset-2 ring-primary dark:ring-offset-card-dark scale-110' : 'hover:scale-105',
      ]"
      :style="{ backgroundColor: intToHex(color) }"
      @click="select(color)"
    >
      <CheckIcon
        v-if="props.modelValue === color"
        class="h-5 w-5"
        :style="{ color: contrastTextColor(color) }"
      />
    </button>
  </div>
</template>
