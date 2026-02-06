<script setup lang="ts">
import { computed } from 'vue'
import { intToHex, contrastTextColor } from '~/utils/colors'

interface Props {
  color?: number
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  color: 0xFF1B5E5A,
  size: 'md',
})

const bgColor = computed(() => intToHex(props.color))
const textColor = computed(() => contrastTextColor(props.color))

const sizeClasses: Record<string, string> = {
  sm: 'h-8 w-8',
  md: 'h-10 w-10',
  lg: 'h-12 w-12',
}

const iconSizeClasses: Record<string, string> = {
  sm: 'h-4 w-4',
  md: 'h-5 w-5',
  lg: 'h-6 w-6',
}
</script>

<template>
  <div
    :class="['flex items-center justify-center rounded-xl', sizeClasses[props.size]]"
    :style="{ backgroundColor: bgColor, color: textColor }"
  >
    <slot :icon-class="iconSizeClasses[props.size]" />
  </div>
</template>
