<script setup lang="ts">
useHead({
  script: [
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'WebApplication',
        'name': 'Monasafe',
        'description': 'Gérez vos finances personnelles simplement avec Monasafe : suivi de comptes, transactions, budgets, récurrences et statistiques.',
        'url': 'https://monasafe.com',
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
