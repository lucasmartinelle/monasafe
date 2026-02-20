<script setup lang="ts">
interface Props {
  currentStep: number
  totalSteps: number
}

defineProps<Props>()
</script>

<template>
  <div class="flex items-center gap-2">
    <div
      v-for="i in totalSteps"
      :key="i"
      :class="[
        'h-1 rounded-full transition-all duration-300',
        i - 1 === currentStep
          ? 'w-8 bg-primary'
          : 'w-4 bg-gray-300 dark:bg-gray-600',
      ]"
    />
  </div>
</template>
