<script setup lang="ts">
import { CheckIcon } from '@heroicons/vue/24/outline'

const emit = defineEmits<{
  complete: []
}>()

let timer: ReturnType<typeof setTimeout>

onMounted(() => {
  timer = setTimeout(() => {
    emit('complete')
  }, 2000)
})

onUnmounted(() => {
  clearTimeout(timer)
})
</script>

<template>
  <div class="flex flex-col items-center justify-center gap-6 py-8 text-center">
    <div class="completion-icon w-20 h-20 rounded-full bg-success/10 flex items-center justify-center">
      <CheckIcon class="h-10 w-10 text-success" />
    </div>
    <div class="completion-text space-y-2">
      <h2 class="text-h3 text-gray-900 dark:text-white">
        Merci et bienvenue !
      </h2>
      <p class="text-body-md text-gray-500 dark:text-gray-400">
        Votre espace est prêt. Vous allez être redirigé...
      </p>
    </div>
  </div>
</template>
