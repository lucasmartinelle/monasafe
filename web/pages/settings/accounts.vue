<script setup lang="ts">
import {
  ArrowLeftIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  UserCircleIcon,
} from '@heroicons/vue/24/outline'

definePageMeta({
  layout: 'default',
})

const {
  isAnonymous,
  hasGoogleProvider,
  userEmail,
  isLoading,
  error,
  linkGoogle,
  signOut,
  clearError,
} = useAuth()

// Statut du compte
const statusLabel = computed(() =>
  hasGoogleProvider.value ? 'Connecté avec Google' : 'Compte local',
)

const statusDescription = computed(() =>
  hasGoogleProvider.value
    ? 'Vos données sont synchronisées avec votre compte Google.'
    : 'Données liées à cette session uniquement.',
)

// Modal déconnexion
const showLogoutConfirm = ref(false)

function openLogoutConfirm() {
  showLogoutConfirm.value = true
}

function cancelLogout() {
  showLogoutConfirm.value = false
  clearError()
}

async function handleLogout() {
  await signOut()
  showLogoutConfirm.value = false
}

// Linking Google
async function handleLinkGoogle() {
  clearError()
  await linkGoogle()
}
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
        Compte
      </h1>
    </div>

    <!-- Erreur -->
    <div
      v-if="error"
      class="mb-4 p-3 bg-red-50 dark:bg-red-900/20 text-error text-sm rounded-xl"
    >
      {{ error }}
    </div>

    <!-- Statut du compte -->
    <div class="bg-white dark:bg-card-dark rounded-xl p-5 mb-4">
      <div class="flex items-center gap-4">
        <div class="flex items-center justify-center h-12 w-12 rounded-full bg-primary/10">
          <UserCircleIcon class="h-7 w-7 text-primary dark:text-primary-light" />
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900 dark:text-white">
            {{ userEmail ?? 'Utilisateur anonyme' }}
          </p>
          <div class="flex items-center gap-1.5 mt-0.5">
            <CheckCircleIcon
              v-if="hasGoogleProvider"
              class="h-4 w-4 text-success shrink-0"
            />
            <p :class="[
              'text-xs',
              hasGoogleProvider
                ? 'text-success'
                : 'text-gray-500 dark:text-gray-400',
            ]">
              {{ statusLabel }}
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Synchronisation Google (pour comptes anonymes/locaux) -->
    <div v-if="isAnonymous && !hasGoogleProvider" class="space-y-4 mb-6">
      <div class="bg-white dark:bg-card-dark rounded-xl p-5">
        <h2 class="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2">
          Synchronisation
        </h2>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
          Connectez votre compte Google pour synchroniser vos données et les conserver en toute sécurité.
        </p>
        <CommonAppButton
          variant="primary"
          class="w-full"
          :loading="isLoading"
          @click="handleLinkGoogle"
        >
          Connecter Google
        </CommonAppButton>
      </div>

      <!-- Avertissement -->
      <div class="bg-warning/10 border border-warning/30 rounded-xl p-4">
        <div class="flex gap-3">
          <ExclamationTriangleIcon class="h-5 w-5 text-warning shrink-0 mt-0.5" />
          <div>
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              Compte local uniquement
            </p>
            <p class="text-xs text-gray-600 dark:text-gray-400 mt-1">
              Sans connexion Google, vos données seront perdues si vous videz les données du navigateur ou changez d'appareil.
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Infos compte Google connecté -->
    <div v-if="hasGoogleProvider" class="mb-6">
      <div class="bg-white dark:bg-card-dark rounded-xl p-5">
        <h2 class="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2">
          Synchronisation
        </h2>
        <div class="flex items-center gap-3">
          <CheckCircleIcon class="h-5 w-5 text-success shrink-0" />
          <p class="text-sm text-gray-600 dark:text-gray-400">
            {{ statusDescription }}
          </p>
        </div>
      </div>
    </div>

    <!-- Déconnexion -->
    <div class="mt-8">
      <CommonAppButton
        variant="danger"
        class="w-full"
        @click="openLogoutConfirm"
      >
        Se déconnecter
      </CommonAppButton>
    </div>

    <!-- Modal confirmation déconnexion -->
    <CommonAppModal
      :open="showLogoutConfirm"
      title="Déconnexion"
      size="sm"
      @close="cancelLogout"
    >
      <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
        <template v-if="hasGoogleProvider">
          Êtes-vous sûr de vouloir vous déconnecter ?
          Vos données resteront synchronisées et vous pourrez vous reconnecter à tout moment.
        </template>
        <template v-else>
          Êtes-vous sûr de vouloir vous déconnecter ?
          En tant que compte local, vos données pourraient être perdues.
        </template>
      </p>

      <div class="flex gap-3">
        <CommonAppButton
          variant="secondary"
          class="flex-1"
          @click="cancelLogout"
        >
          Annuler
        </CommonAppButton>
        <CommonAppButton
          variant="danger"
          class="flex-1"
          :loading="isLoading"
          @click="handleLogout"
        >
          Se déconnecter
        </CommonAppButton>
      </div>
    </CommonAppModal>
  </div>
</template>
