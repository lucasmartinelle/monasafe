<script setup lang="ts">
definePageMeta({
  layout: 'default',
})
</script>

<template>
  <div>
    <h1 class="text-h2 text-gray-900 dark:text-white mb-6">
      Dashboard
    </h1>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <CommonAppCard>
        <h3 class="text-label-md text-gray-500 dark:text-gray-400">
          Solde total
        </h3>
        <p class="text-h2 text-gray-900 dark:text-white mt-1">
          0,00 &euro;
        </p>
      </CommonAppCard>

      <CommonAppCard>
        <h3 class="text-label-md text-gray-500 dark:text-gray-400">
          Revenus du mois
        </h3>
        <p class="text-h2 text-success mt-1">
          0,00 &euro;
        </p>
      </CommonAppCard>

      <CommonAppCard>
        <h3 class="text-label-md text-gray-500 dark:text-gray-400">
          Dépenses du mois
        </h3>
        <p class="text-h2 text-error mt-1">
          0,00 &euro;
        </p>
      </CommonAppCard>
    </div>
  </div>
</template>
