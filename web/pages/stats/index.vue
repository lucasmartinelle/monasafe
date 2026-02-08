<script setup lang="ts">
import { ChartBarIcon } from '@heroicons/vue/24/outline'

definePageMeta({
  layout: 'default',
})
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white mb-6">
      Statistiques
    </h1>

    <!-- Placeholder -->
    <div class="flex flex-col items-center justify-center py-16 text-center">
      <div class="flex items-center justify-center h-16 w-16 rounded-2xl bg-primary/10 mb-4">
        <ChartBarIcon class="h-8 w-8 text-primary dark:text-primary-light" />
      </div>
      <p class="text-sm text-gray-500 dark:text-gray-400">
        Bientôt disponible
      </p>
    </div>
  </div>
</template>
