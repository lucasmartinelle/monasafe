<script setup lang="ts">
import {
  TagIcon,
  BanknotesIcon,
  ShieldCheckIcon,
  TrashIcon,
  InformationCircleIcon,
  SunIcon,
  MoonIcon,
  ComputerDesktopIcon,
} from '@heroicons/vue/24/outline'
import { ChevronRightIcon } from '@heroicons/vue/24/solid'

useSeoMeta({
  title: 'Paramètres — Monasafe',
  description: 'Configurez Monasafe : apparence, catégories, comptes, sécurité et données.',
})

definePageMeta({
  layout: 'default',
})

const colorMode = useColorMode()

const themeOptions = [
  { value: 'light', label: 'Clair', icon: SunIcon },
  { value: 'dark', label: 'Sombre', icon: MoonIcon },
  { value: 'system', label: 'Système', icon: ComputerDesktopIcon },
] as const

function setTheme(value: string) {
  colorMode.preference = value
}

const menuItems = [
  {
    label: 'Catégories',
    description: 'Gérer les catégories de transactions',
    icon: TagIcon,
    href: '/settings/categories',
  },
  {
    label: 'Compte',
    description: 'Connexion, synchronisation Google',
    icon: BanknotesIcon,
    href: '/settings/accounts',
  },
  {
    label: 'Sécurité',
    description: 'Chiffrement et vault',
    icon: ShieldCheckIcon,
    href: '/settings/security',
  },
  {
    label: 'Données',
    description: 'Supprimer des données',
    icon: TrashIcon,
    href: '/settings/data',
  },
  {
    label: 'À propos',
    description: 'Version et informations',
    icon: InformationCircleIcon,
    href: '/settings/about',
  },
]
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white mb-6">
      Paramètres
    </h1>

    <div class="space-y-4">
      <!-- Thème -->
      <div class="bg-white dark:bg-card-dark rounded-xl p-4">
        <p class="text-sm font-medium text-gray-900 dark:text-white mb-3">
          Apparence
        </p>
        <div class="flex gap-2">
          <button
            v-for="option in themeOptions"
            :key="option.value"
            type="button"
            :class="[
              'flex-1 flex items-center justify-center gap-2 px-3 py-2.5 rounded-xl text-sm font-medium border transition-colors',
              colorMode.preference === option.value
                ? 'bg-primary text-white border-primary'
                : 'bg-gray-50 dark:bg-gray-800 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-gray-600 hover:border-primary/50',
            ]"
            @click="setTheme(option.value)"
          >
            <component :is="option.icon" class="h-4 w-4" />
            {{ option.label }}
          </button>
        </div>
      </div>

      <!-- Menu items -->
      <div class="space-y-2">
        <NuxtLink
          v-for="item in menuItems"
          :key="item.href"
          :to="item.href"
          class="flex items-center gap-4 px-4 py-3.5 bg-white dark:bg-card-dark rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
        >
          <div class="flex items-center justify-center h-10 w-10 rounded-xl bg-primary/10">
            <component :is="item.icon" class="h-5 w-5 text-primary dark:text-primary-light" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              {{ item.label }}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {{ item.description }}
            </p>
          </div>
          <ChevronRightIcon class="h-5 w-5 text-gray-400" />
        </NuxtLink>
      </div>
    </div>
  </div>
</template>
