<script setup lang="ts">
useHead({
  script: [
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'WebApplication',
        'name': 'SimpleFlow',
        'description': 'Gérez vos finances personnelles simplement avec SimpleFlow : suivi de comptes, transactions, budgets, récurrences et statistiques.',
        'url': 'https://open-simpleflow.vercel.app',
        'applicationCategory': 'FinanceApplication',
        'operatingSystem': 'Web',
        'offers': {
          '@type': 'Offer',
          'price': '0',
          'priceCurrency': 'EUR',
        },
        'inLanguage': 'fr',
        'author': {
          '@type': 'Person',
          'name': 'Lucas MARTINELLE',
        },
      }),
    },
  ],
})
</script>

<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>
