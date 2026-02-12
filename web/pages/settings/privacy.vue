<script setup lang="ts">
import { ArrowLeftIcon } from '@heroicons/vue/24/outline'

useSeoMeta({
  title: 'Politique de confidentialité — Monasafe',
  description: 'Découvrez comment Monasafe protège vos données personnelles et financières.',
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
        Politique de confidentialité
      </h1>
    </div>

    <div class="bg-white dark:bg-card-dark rounded-xl p-6 space-y-4 text-sm text-gray-700 dark:text-gray-300 leading-relaxed">
      <p class="text-xs text-gray-400 dark:text-gray-500">
        Dernière mise à jour : février 2026
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        1. Données collectées
      </h2>
      <p>
        Monasafe collecte uniquement les données que vous saisissez volontairement :
        comptes bancaires, transactions, catégories, récurrences, budgets et paramètres.
        Aucune donnée de navigation, de localisation ou de comportement n'est collectée.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        2. Stockage des données
      </h2>
      <p>
        Vos données sont stockées sur les serveurs Supabase, protégées par des politiques
        de sécurité au niveau des lignes (RLS) garantissant que seul votre compte peut accéder
        à vos données.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        3. Chiffrement
      </h2>
      <p>
        Si vous activez le Vault, vos montants et notes de transactions sont chiffrés de bout
        en bout avec AES-256-GCM. La clé de chiffrement est dérivée de votre mot de passe
        maître via PBKDF2 (100 000 itérations). Ni l'éditeur ni l'hébergeur ne peuvent
        déchiffrer ces données.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        4. Authentification
      </h2>
      <p>
        L'authentification est gérée par Supabase Auth. Si vous choisissez la connexion Google,
        seuls votre adresse e-mail et votre nom sont récupérés pour identifier votre compte.
        Aucune donnée Google supplémentaire n'est accédée.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        5. Partage des données
      </h2>
      <p>
        Vos données ne sont jamais partagées, vendues ou transmises à des tiers.
        Aucun service d'analyse, de publicité ou de tracking n'est intégré à l'application.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        6. Suppression des données
      </h2>
      <p>
        Vous pouvez supprimer l'intégralité de vos données depuis les paramètres de
        l'application (Paramètres &gt; Données). La suppression est immédiate et définitive.
      </p>

      <h2 class="text-base font-semibold text-gray-900 dark:text-white">
        7. Contact
      </h2>
      <p>
        Pour toute question relative à la confidentialité de vos données, contactez
        <a href="mailto:lucasmar.martinelle@gmail.com" class="text-primary dark:text-primary-light hover:underline">
          lucasmar.martinelle@gmail.com
        </a>.
      </p>
    </div>
  </div>
</template>
