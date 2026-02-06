<script setup lang="ts">
interface Props {
  variant?: 'spinner' | 'skeleton'
  lines?: number
}

withDefaults(defineProps<Props>(), {
  variant: 'spinner',
  lines: 3,
})
</script>

<template>
  <div v-if="variant === 'spinner'" class="flex items-center justify-center py-12">
    <svg
      class="animate-spin h-8 w-8 text-primary"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
    </svg>
  </div>

  <div v-else class="animate-pulse space-y-3">
    <div
      v-for="i in lines"
      :key="i"
      :class="[
        'h-4 bg-gray-200 dark:bg-gray-700 rounded',
        i === lines ? 'w-2/3' : 'w-full',
      ]"
    />
  </div>
</template>
