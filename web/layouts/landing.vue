<script setup lang="ts">
const user = useSupabaseUser()
const mobileMenuOpen = ref(false)
</script>

<template>
  <div class="min-h-screen flex flex-col bg-background-light dark:bg-background-dark">
    <!-- Header -->
    <header class="sticky top-0 z-50 bg-background-light/80 dark:bg-background-dark/80 backdrop-blur-lg border-b border-gray-200 dark:border-gray-800">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <!-- Logo -->
          <NuxtLink to="/" class="text-xl font-heading font-bold text-primary dark:text-primary-light">
            Monasafe
          </NuxtLink>

          <!-- Nav desktop -->
          <nav class="hidden md:flex items-center gap-8">
            <a href="/#features" class="text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-primary dark:hover:text-primary-light transition-colors">
              Fonctionnalités
            </a>
            <a href="/#security" class="text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-primary dark:hover:text-primary-light transition-colors">
              Sécurité
            </a>
            <a href="/#faq" class="text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-primary dark:hover:text-primary-light transition-colors">
              FAQ
            </a>
          </nav>

          <!-- CTA desktop -->
          <div class="hidden md:block">
            <NuxtLink
              :to="user ? '/dashboard' : '/auth'"
              class="inline-flex items-center px-5 py-2.5 rounded-xl bg-primary text-white text-sm font-medium hover:bg-primary-dark transition-colors"
            >
              {{ user ? 'Accéder au dashboard' : 'Commencer' }}
            </NuxtLink>
          </div>

          <!-- Burger mobile -->
          <button
            class="md:hidden p-2 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
            @click="mobileMenuOpen = !mobileMenuOpen"
          >
            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path v-if="!mobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Menu mobile -->
        <div v-if="mobileMenuOpen" class="md:hidden pb-4 space-y-2">
          <a href="/#features" class="block px-3 py-2 rounded-lg text-sm font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800" @click="mobileMenuOpen = false">
            Fonctionnalités
          </a>
          <a href="/#security" class="block px-3 py-2 rounded-lg text-sm font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800" @click="mobileMenuOpen = false">
            Sécurité
          </a>
          <a href="/#faq" class="block px-3 py-2 rounded-lg text-sm font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800" @click="mobileMenuOpen = false">
            FAQ
          </a>
          <NuxtLink
            :to="user ? '/dashboard' : '/auth'"
            class="block px-3 py-2 rounded-lg text-sm font-medium text-primary dark:text-primary-light"
            @click="mobileMenuOpen = false"
          >
            {{ user ? 'Accéder au dashboard' : 'Commencer' }}
          </NuxtLink>
        </div>
      </div>
    </header>

    <!-- Content -->
    <main class="flex-1">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="border-t border-gray-200 dark:border-gray-800 bg-white dark:bg-card-dark">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
          <p class="text-sm text-gray-500 dark:text-gray-400">
            &copy; {{ new Date().getFullYear() }} Monasafe. Tous droits réservés.
          </p>
          <div class="flex items-center gap-6">
            <NuxtLink to="/terms" class="text-sm text-gray-500 dark:text-gray-400 hover:text-primary dark:hover:text-primary-light transition-colors">
              Conditions d'utilisation
            </NuxtLink>
            <NuxtLink to="/privacy" class="text-sm text-gray-500 dark:text-gray-400 hover:text-primary dark:hover:text-primary-light transition-colors">
              Confidentialité
            </NuxtLink>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>
