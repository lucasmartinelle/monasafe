<script setup lang="ts">
import { computed } from 'vue'
import { getIcon } from '~/utils/icons'

interface Props {
  iconKey: string
  color?: number
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  color: 0xFF1B5E5A,
  size: 'md',
})

const iconComponent = computed(() => getIcon(props.iconKey))
</script>

<template>
  <CommonIconContainer :color="props.color" :size="props.size">
    <template #default="{ iconClass }">
      <component :is="iconComponent" :class="iconClass" />
    </template>
  </CommonIconContainer>
</template>
