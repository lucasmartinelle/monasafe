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
            Sachez où va
            <span class="text-primary dark:text-primary-light">votre argent</span>
          </h1>
          <p class="mt-5 text-lg text-gray-500 dark:text-gray-400 max-w-lg mx-auto lg:mx-0 leading-relaxed">
            Comptes, dépenses, budgets, récurrences — tout ce qu'il faut pour reprendre le contrôle. Simplement.
          </p>

          <div class="mt-8">
            <NuxtLink
              :to="user ? '/dashboard' : '/auth'"
              class="inline-flex items-center px-8 py-3.5 rounded-xl bg-primary text-white text-base font-semibold hover:bg-primary-dark transition-colors shadow-lg shadow-primary/20"
            >
              {{ user ? 'Accéder au dashboard' : 'Commencer' }}
            </NuxtLink>
            <p class="mt-3 text-xs text-gray-400 dark:text-gray-500">
              Sans publicité, sans engagement.
            </p>
          </div>

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
