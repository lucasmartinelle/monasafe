<script setup lang="ts">
import { ArrowLeftIcon } from '@heroicons/vue/24/outline'

useSeoMeta({
  title: 'Conditions d\'utilisation — Monasafe',
  description: 'Consultez les conditions d\'utilisation de Monasafe.',
})

definePageMeta({
  layout: 'default',
})
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink
        to="/settings/about"
        class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
      >
        <ArrowLeftIcon class="h-5 w-5 text-gray-600 dark:text-gray-400" />
      </NuxtLink>
      <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
        Conditions d'utilisation
      </h1>
    </div>

    <div class="bg-white dark:bg-card-dark rounded-xl p-6 space-y-4 text-sm text-gray-700 dark:text-gray-300 leading-relaxed">
      <p class="text-xs text-gray-400 dark:text-gray-500">
        Dernière mise à jour : février 2026
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        1. Acceptation des conditions
      </h2>
      <p>
        En utilisant Monasafe, vous acceptez les présentes conditions d'utilisation.
        Si vous n'acceptez pas ces conditions, veuillez ne pas utiliser l'application.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        2. Description du service
      </h2>
      <p>
        Monasafe est une application de gestion de finances personnelles permettant de
        suivre vos comptes, transactions, récurrences et budgets. L'application est fournie
        "en l'état" à titre gratuit.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        3. Compte utilisateur
      </h2>
      <p>
        Vous pouvez utiliser Monasafe de manière anonyme ou en vous connectant via Google.
        Vous êtes responsable de la confidentialité de vos identifiants de connexion.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        4. Données utilisateur
      </h2>
      <p>
        Vos données financières sont stockées sur des serveurs sécurisés (Supabase).
        Vous pouvez activer le chiffrement de bout en bout (Vault) pour protéger
        vos montants et notes avec un mot de passe maître. En cas de perte de ce mot de passe,
        vos données chiffrées seront irrécupérables.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        5. Responsabilité
      </h2>
      <p>
        Monasafe est un outil de suivi et ne constitue pas un conseil financier.
        L'application est fournie sans garantie d'exactitude des calculs ni de disponibilité.
        L'éditeur ne saurait être tenu responsable de toute perte de données ou d'erreur
        de calcul.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        6. Suppression de données
      </h2>
      <p>
        Vous pouvez supprimer vos données à tout moment depuis les paramètres de l'application.
        La suppression est définitive et irréversible.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        7. Modifications
      </h2>
      <p>
        Ces conditions peuvent être modifiées à tout moment. L'utilisation continue de
        l'application après modification vaut acceptation des nouvelles conditions.
      </p>
    </div>
  </div>
</template>
