<script setup lang="ts">
import {
  ShieldCheckIcon,
  EyeSlashIcon,
  DevicePhoneMobileIcon,
} from '@heroicons/vue/24/outline'

useSeoMeta({
  title: 'Monasafe — Gestion de finances personnelles',
  description: 'Gérez vos finances personnelles simplement avec Monasafe : suivi de comptes, transactions, budgets, récurrences et statistiques. Sans publicité.',
})

definePageMeta({
  layout: 'landing',
})

const user = useSupabaseUser()
</script>

<template>
  <div class="h-[calc(100vh-4rem)] flex flex-col">
    <!-- Main content -->
    <div class="flex-1 flex items-center px-4 sm:px-8 lg:px-16">
      <div class="max-w-7xl mx-auto w-full grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
        <!-- Left: text -->
        <div class="text-center lg:text-left">
          <h1 class="text-4xl sm:text-5xl xl:text-6xl font-heading font-bold text-gray-900 dark:text-white leading-[1.1] tracking-tight">
            Reprenez le contrôle de
            <span class="text-primary dark:text-primary-light">votre argent</span>
          </h1>
          <p class="mt-5 text-lg text-gray-500 dark:text-gray-400 max-w-lg mx-auto lg:mx-0 leading-relaxed">
            Comptes, dépenses, budgets, récurrences — tout ce qu'il faut pour reprendre le contrôle. Simplement.
          </p>

          <div class="mt-8 flex flex-col sm:flex-row items-center lg:items-start gap-3">
            <NuxtLink
              :to="user ? '/dashboard' : '/auth'"
              class="inline-flex items-center px-8 py-3.5 rounded-xl bg-primary text-white text-base font-semibold hover:bg-primary-dark transition-colors shadow-lg shadow-primary/20"
            >
              {{ user ? 'Accéder au dashboard' : 'Commencer' }}
            </NuxtLink>
            <a
              href="https://play.google.com/store/apps/details?id=com.lurieldev.monasafe"
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center gap-2 px-5 py-3 rounded-xl border border-gray-300 dark:border-gray-600 text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            >
              <svg class="h-5 w-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M3.61 1.814A1.82 1.82 0 0 0 3 3.18v17.64a1.82 1.82 0 0 0 .61 1.366l.07.062L14.29 11.64v-.28L3.68 .752l-.07.062zM17.85 15.2l-3.56-3.56v-.28l3.56-3.56.08.046 4.22 2.4c1.2.682 1.2 1.798 0 2.48l-4.22 2.4-.08.07zM17.77 15.27l-3.48-3.63L3.61 22.32c.398.42 1.054.47 1.504.11l12.656-7.16zM17.77 8.73L5.114 1.57C4.664 1.21 4.008 1.26 3.61 1.68l10.68 10.68 3.48-3.63z" />
              </svg>
              Google Play
            </a>
          </div>
          <p class="mt-3 text-xs text-gray-400 dark:text-gray-500 text-center lg:text-left">
            Sans publicité, sans engagement.
          </p>

          <!-- Pillars inline -->
          <div class="mt-10 flex flex-wrap justify-center lg:justify-start gap-6">
            <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
              <ShieldCheckIcon class="h-5 w-5 text-primary dark:text-primary-light shrink-0" />
              <span>Sécurisé</span>
            </div>
            <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
              <EyeSlashIcon class="h-5 w-5 text-primary dark:text-primary-light shrink-0" />
              <span>Privé</span>
            </div>
            <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
              <DevicePhoneMobileIcon class="h-5 w-5 text-primary dark:text-primary-light shrink-0" />
              <span>Web & Android</span>
            </div>
          </div>
        </div>

        <!-- Right: screenshots -->
        <div class="hidden lg:flex items-center justify-center relative">
          <div class="relative w-full max-w-md">
            <!-- Screen 1: dashboard (front, left) -->
            <div class="relative z-10 w-[220px] xl:w-[260px] rounded-3xl overflow-hidden shadow-2xl shadow-black/20 border border-gray-200 dark:border-gray-700">
              <img
                src="/screen-1.jpg"
                alt="Tableau de bord Monasafe"
                class="w-full h-auto"
              />
            </div>
            <!-- Screen 2: stats (behind, right) -->
            <div class="absolute top-8 left-[140px] xl:left-[160px] z-0 w-[220px] xl:w-[260px] rounded-3xl overflow-hidden shadow-2xl shadow-black/15 border border-gray-200 dark:border-gray-700 opacity-85">
              <img
                src="/screen-2.jpg"
                alt="Statistiques Monasafe"
                class="w-full h-auto"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
