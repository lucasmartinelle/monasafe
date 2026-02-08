<script setup lang="ts">
import {
  TagIcon,
  BanknotesIcon,
  ShieldCheckIcon,
  TrashIcon,
  InformationCircleIcon,
} from '@heroicons/vue/24/outline'
import { ChevronRightIcon } from '@heroicons/vue/24/solid'

definePageMeta({
  layout: 'default',
})

const menuItems = [
  {
    label: 'Catégories',
    description: 'Gérer les catégories de transactions',
    icon: TagIcon,
    href: '/settings/categories',
  },
  {
    label: 'Comptes',
    description: 'Gérer les comptes et la devise',
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
</template>
