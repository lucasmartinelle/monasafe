<script setup lang="ts">
import { getLucideIcon } from '~/utils/icons'

interface Props {
  iconKey: string
  color?: number
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  color: 0xFF1B5E5A,
  size: 'md',
})

const iconSizes: Record<string, number> = {
  sm: 16,
  md: 20,
  lg: 24,
}

const iconComponent = computed(() => getLucideIcon(props.iconKey))
</script>

<template>
  <CommonIconContainer :color="props.color" :size="props.size">
    <template #default>
      <component :is="iconComponent" :size="iconSizes[props.size]" class="select-none" />
    </template>
  </CommonIconContainer>
</template>
