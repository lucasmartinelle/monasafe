<script setup lang="ts">
import {
  BanknotesIcon,
  ArrowsRightLeftIcon,
  ArrowPathIcon,
  ChartBarIcon,
  ShieldCheckIcon,
  MoonIcon,
  LockClosedIcon,
  EyeSlashIcon,
  ServerStackIcon,
  ChevronDownIcon,
} from '@heroicons/vue/24/outline'

useSeoMeta({
  title: 'Monasafe — Gestion de finances personnelles',
  description: 'Gérez vos finances personnelles simplement avec Monasafe : suivi de comptes, transactions, budgets, récurrences et statistiques. Sans publicité.',
})

definePageMeta({
  layout: 'landing',
})

const user = useSupabaseUser()

const features = [
  {
    icon: BanknotesIcon,
    title: 'Comptes',
    description: 'Gérez tous vos comptes (courant, épargne, espèces) et consultez vos soldes en un coup d\'oeil.',
  },
  {
    icon: ArrowsRightLeftIcon,
    title: 'Transactions',
    description: 'Enregistrez vos revenus et dépenses en quelques secondes. Catégorisation et notes intelligentes.',
  },
  {
    icon: ArrowPathIcon,
    title: 'Récurrences',
    description: 'Configurez vos paiements mensuels (loyer, abonnements, salaire). Génération automatique chaque mois.',
  },
  {
    icon: ChartBarIcon,
    title: 'Budgets',
    description: 'Définissez un budget par catégorie et suivez votre progression en temps réel.',
  },
  {
    icon: ChartBarIcon,
    title: 'Statistiques',
    description: 'Graphiques interactifs de cashflow, répartition des dépenses et évolution dans le temps.',
  },
  {
    icon: MoonIcon,
    title: 'Thème sombre',
    description: 'Mode clair, sombre ou automatique selon les préférences de votre système.',
  },
]

const securityPoints = [
  {
    icon: LockClosedIcon,
    title: 'Chiffrement de bout en bout',
    description: 'Le Vault chiffre vos montants et notes avec AES-256-GCM. Seul votre mot de passe maître peut les déchiffrer.',
  },
  {
    icon: EyeSlashIcon,
    title: 'Zéro tracking',
    description: 'Aucun analytics, aucune publicité, aucun partage de données avec des tiers. Vos finances restent privées.',
  },
  {
    icon: ServerStackIcon,
    title: 'Isolation des données',
    description: 'Chaque utilisateur ne voit que ses propres données grâce aux politiques de sécurité Row Level Security.',
  },
]

const faqItems = ref([
  {
    question: 'Puis-je utiliser Monasafe sans créer de compte ?',
    answer: 'Oui, vous pouvez utiliser Monasafe en mode anonyme. Vos données sont stockées localement. Vous pouvez ensuite lier un compte Google pour synchroniser vos données.',
    open: false,
  },
  {
    question: 'Mes données financières sont-elles en sécurité ?',
    answer: 'Vos données sont protégées par des politiques de sécurité au niveau des lignes (RLS). Vous pouvez également activer le Vault pour chiffrer vos montants et notes de bout en bout avec AES-256-GCM.',
    open: false,
  },
  {
    question: 'Monasafe est-il disponible sur mobile ?',
    answer: 'Oui, Monasafe est disponible en tant qu\'application native sur Android. Les deux versions partagent le même backend et vos données sont synchronisées.',
    open: false,
  },
  {
    question: 'Comment supprimer mes données ?',
    answer: 'Vous pouvez supprimer l\'intégralité de vos données depuis Paramètres > Données. La suppression est immédiate et définitive.',
    open: false,
  },
])

function toggleFaq(index: number) {
  faqItems.value[index].open = !faqItems.value[index].open
}
</script>

<template>
  <div>
    <!-- Hero -->
    <section class="py-20 sm:py-28 px-4">
      <div class="max-w-4xl mx-auto text-center">
        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-heading font-bold text-gray-900 dark:text-white leading-tight">
          Reprenez le contrôle de
          <span class="text-primary dark:text-primary-light">vos finances</span>
        </h1>
        <p class="mt-6 text-lg sm:text-xl text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
          Suivez vos comptes, catégorisez vos dépenses, fixez des budgets et visualisez vos habitudes financières — simplement et en toute sécurité.
        </p>
        <div class="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
          <NuxtLink
            :to="user ? '/dashboard' : '/auth'"
            class="inline-flex items-center px-8 py-3.5 rounded-xl bg-primary text-white text-base font-semibold hover:bg-primary-dark transition-colors shadow-lg shadow-primary/25"
          >
            {{ user ? 'Accéder au dashboard' : 'Créer un compte' }}
          </NuxtLink>
          <a
            href="#features"
            class="inline-flex items-center px-8 py-3.5 rounded-xl border border-gray-300 dark:border-gray-600 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
          >
            Découvrir
          </a>
        </div>
        <p class="mt-4 text-sm text-gray-500 dark:text-gray-500">
          Sans publicité, sans engagement.
        </p>
      </div>
    </section>

    <!-- Features -->
    <section id="features" class="py-20 px-4 bg-white dark:bg-card-dark">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-16">
          <h2 class="text-3xl sm:text-4xl font-heading font-bold text-gray-900 dark:text-white">
            Tout ce qu'il faut pour gérer votre argent
          </h2>
          <p class="mt-4 text-lg text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
            Des outils simples et puissants pour suivre chaque euro, sans prise de tête.
          </p>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <div
            v-for="feature in features"
            :key="feature.title"
            class="p-6 rounded-xl bg-gray-50 dark:bg-background-dark border border-gray-100 dark:border-gray-800"
          >
            <div class="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
              <component :is="feature.icon" class="h-6 w-6 text-primary dark:text-primary-light" />
            </div>
            <h3 class="text-lg font-heading font-semibold text-gray-900 dark:text-white mb-2">
              {{ feature.title }}
            </h3>
            <p class="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
              {{ feature.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Security -->
    <section id="security" class="py-20 px-4">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-16">
          <h2 class="text-3xl sm:text-4xl font-heading font-bold text-gray-900 dark:text-white">
            Vos données vous appartiennent
          </h2>
          <p class="mt-4 text-lg text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
            La sécurité de vos données financières n'est pas une option, c'est une priorité.
          </p>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div
            v-for="point in securityPoints"
            :key="point.title"
            class="p-6 rounded-xl bg-white dark:bg-card-dark border border-gray-100 dark:border-gray-800 text-center"
          >
            <div class="w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
              <component :is="point.icon" class="h-7 w-7 text-primary dark:text-primary-light" />
            </div>
            <h3 class="text-lg font-heading font-semibold text-gray-900 dark:text-white mb-2">
              {{ point.title }}
            </h3>
            <p class="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
              {{ point.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- FAQ -->
    <section id="faq" class="py-20 px-4 bg-white dark:bg-card-dark">
      <div class="max-w-3xl mx-auto">
        <div class="text-center mb-12">
          <h2 class="text-3xl sm:text-4xl font-heading font-bold text-gray-900 dark:text-white">
            Questions fréquentes
          </h2>
        </div>
        <div class="space-y-3">
          <div
            v-for="(item, index) in faqItems"
            :key="index"
            class="rounded-xl border border-gray-100 dark:border-gray-800 overflow-hidden"
          >
            <button
              class="w-full flex items-center justify-between px-6 py-4 text-left hover:bg-gray-50 dark:hover:bg-background-dark transition-colors"
              @click="toggleFaq(index)"
            >
              <span class="text-base font-medium text-gray-900 dark:text-white pr-4">
                {{ item.question }}
              </span>
              <ChevronDownIcon
                class="h-5 w-5 text-gray-500 shrink-0 transition-transform duration-200"
                :class="{ 'rotate-180': item.open }"
              />
            </button>
            <div
              v-if="item.open"
              class="px-6 pb-4 text-sm text-gray-600 dark:text-gray-400 leading-relaxed"
            >
              {{ item.answer }}
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA final -->
    <section class="py-20 px-4">
      <div class="max-w-3xl mx-auto text-center">
        <h2 class="text-3xl sm:text-4xl font-heading font-bold text-gray-900 dark:text-white">
          Prêt à reprendre le contrôle ?
        </h2>
        <p class="mt-4 text-lg text-gray-600 dark:text-gray-400">
          Créez votre compte en quelques secondes. Sans publicité et respectueux de votre vie privée.
        </p>
        <NuxtLink
          :to="user ? '/dashboard' : '/auth'"
          class="inline-flex items-center mt-8 px-8 py-3.5 rounded-xl bg-primary text-white text-base font-semibold hover:bg-primary-dark transition-colors shadow-lg shadow-primary/25"
        >
          {{ user ? 'Accéder au dashboard' : 'Créer un compte' }}
        </NuxtLink>
      </div>
    </section>
  </div>
</template>
