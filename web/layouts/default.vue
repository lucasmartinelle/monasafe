<script setup lang="ts">
import {
  HomeIcon,
  ArrowsRightLeftIcon,
  ArrowPathIcon,
  ChartBarIcon,
  Cog6ToothIcon,
} from '@heroicons/vue/24/outline'

const route = useRoute()

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: HomeIcon },
  { name: 'Transactions', href: '/transactions', icon: ArrowsRightLeftIcon },
  { name: 'Récurrences', href: '/recurring', icon: ArrowPathIcon },
  { name: 'Statistiques', href: '/stats', icon: ChartBarIcon },
  { name: 'Paramètres', href: '/settings', icon: Cog6ToothIcon },
]

function isActive(href: string): boolean {
  return route.path.startsWith(href)
}
</script>

<template>
  <div class="min-h-screen bg-background-light dark:bg-background-dark">
    <!-- Sidebar (desktop) -->
    <aside class="fixed inset-y-0 left-0 z-40 hidden w-64 lg:flex flex-col bg-white dark:bg-surface-dark border-r border-gray-200 dark:border-gray-700">
      <!-- Logo -->
      <div class="flex items-center h-16 px-6 border-b border-gray-200 dark:border-gray-700">
        <h1 class="text-xl font-heading font-bold text-primary dark:text-primary-light">
          SimpleFlow
        </h1>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 px-3 py-4 space-y-1">
        <NuxtLink
          v-for="item in navigation"
          :key="item.name"
          :to="item.href"
          :class="[
            'flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors',
            isActive(item.href)
              ? 'bg-primary/10 text-primary dark:text-primary-light'
              : 'text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-gray-900 dark:hover:text-white',
          ]"
        >
          <component :is="item.icon" class="h-5 w-5" />
          {{ item.name }}
        </NuxtLink>
      </nav>
    </aside>

    <!-- Main content -->
    <div class="lg:pl-64">
      <!-- Top bar -->
      <header class="sticky top-0 z-30 flex items-center h-16 px-4 lg:px-8 bg-white/80 dark:bg-surface-dark/80 backdrop-blur-sm border-b border-gray-200 dark:border-gray-700">
        <div class="flex-1" />
      </header>

      <!-- Page content -->
      <main class="p-4 lg:p-8">
        <slot />
      </main>
    </div>

    <!-- Bottom navigation (mobile) -->
    <nav class="fixed bottom-0 inset-x-0 z-40 lg:hidden bg-white dark:bg-surface-dark border-t border-gray-200 dark:border-gray-700">
      <div class="flex items-center justify-around h-16">
        <NuxtLink
          v-for="item in navigation"
          :key="item.name"
          :to="item.href"
          :class="[
            'flex flex-col items-center gap-1 px-3 py-1 text-xs font-medium transition-colors',
            isActive(item.href)
              ? 'text-primary dark:text-primary-light'
              : 'text-gray-500 dark:text-gray-400',
          ]"
        >
          <component :is="item.icon" class="h-5 w-5" />
          <span>{{ item.name }}</span>
        </NuxtLink>
      </div>
    </nav>
  </div>
</template>
