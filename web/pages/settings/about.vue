<script setup lang="ts">
import { ArrowLeftIcon } from '@heroicons/vue/24/outline'

useSeoMeta({
  title: 'À propos — Monasafe',
  description: 'Informations sur Monasafe : version, développeur et technologies utilisées.',
})

definePageMeta({
  layout: 'default',
})

const version = '1.0.0'
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink
        to="/settings"
        class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
      >
        <ArrowLeftIcon class="h-5 w-5 text-gray-600 dark:text-gray-400" />
      </NuxtLink>
      <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
        À propos
      </h1>
    </div>

    <!-- Logo & Version -->
    <div class="bg-white dark:bg-card-dark rounded-xl p-6 text-center mb-6">
      <h2 class="text-2xl font-heading font-bold text-primary dark:text-primary-light">
        Monasafe
      </h2>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
        Gestion de finances personnelles
      </p>
      <p class="text-xs text-gray-400 dark:text-gray-500 mt-2">
        Version {{ version }}
      </p>
    </div>

    <!-- Infos -->
    <div class="space-y-3">
      <!-- Développeur -->
      <div class="bg-white dark:bg-card-dark rounded-xl p-5">
        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-1">
          Développeur
        </p>
        <p class="text-sm font-medium text-gray-900 dark:text-white">
          Lucas MARTINELLE
        </p>
        <a
          href="mailto:lucasmar.martinelle@gmail.com"
          class="text-xs text-primary dark:text-primary-light hover:underline mt-1 inline-block"
        >
          lucasmar.martinelle@gmail.com
        </a>
      </div>

      <!-- Technologies -->
      <div class="bg-white dark:bg-card-dark rounded-xl p-5">
        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2">
          Technologies
        </p>
        <div class="flex flex-wrap gap-2">
          <span
            v-for="tech in ['Nuxt 3', 'Vue 3', 'TypeScript', 'Supabase', 'Tailwind CSS', 'Pinia']"
            :key="tech"
            class="px-2.5 py-1 text-xs font-medium bg-primary/10 text-primary dark:text-primary-light rounded-lg"
          >
            {{ tech }}
          </span>
        </div>
      </div>

      <!-- Liens -->
      <div class="bg-white dark:bg-card-dark rounded-xl p-5">
        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-3">
          Liens
        </p>
        <div class="space-y-2">
          <NuxtLink
            to="/settings/terms"
            class="block text-sm text-primary dark:text-primary-light hover:underline"
          >
            Conditions d'utilisation
          </NuxtLink>
          <NuxtLink
            to="/settings/privacy"
            class="block text-sm text-primary dark:text-primary-light hover:underline"
          >
            Politique de confidentialité
          </NuxtLink>
        </div>
      </div>
    </div>

  </div>
</template>
