<script setup lang="ts">
interface Props {
  padding?: boolean
  hoverable?: boolean
}

withDefaults(defineProps<Props>(), {
  padding: true,
  hoverable: false,
})
</script>

<template>
  <div
    :class="[
      'bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-100 dark:border-gray-700/50',
      padding ? 'p-5' : '',
      hoverable ? 'hover:shadow-md transition-shadow duration-200 cursor-pointer' : '',
    ]"
  >
    <slot />
  </div>
</template>
