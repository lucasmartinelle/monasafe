<script setup lang="ts">
import {
  ShieldCheckIcon,
  KeyIcon,
  TrashIcon,
  ExclamationTriangleIcon,
  ArrowLeftIcon,
} from '@heroicons/vue/24/outline'

definePageMeta({
  layout: 'default',
})

const vault = useVault()

// Modals
const showSetup = ref(false)
const showChangePassword = ref(false)
const showDeactivate = ref(false)

// Change password form
const currentPassword = ref('')
const newPassword = ref('')
const confirmNewPassword = ref('')
const changePasswordError = ref<string | undefined>(undefined)
const changePasswordSuccess = ref(false)

// Deactivate form
const deactivatePassword = ref('')
const deactivateError = ref<string | undefined>(undefined)

async function onChangePassword() {
  changePasswordError.value = undefined
  changePasswordSuccess.value = false

  if (newPassword.value.length < 8) {
    changePasswordError.value = '8 caractères minimum'
    return
  }

  if (newPassword.value !== confirmNewPassword.value) {
    changePasswordError.value = 'Les mots de passe ne correspondent pas'
    return
  }

  try {
    await vault.changeMasterPassword(currentPassword.value, newPassword.value)
    changePasswordSuccess.value = true
    currentPassword.value = ''
    newPassword.value = ''
    confirmNewPassword.value = ''
    setTimeout(() => {
      showChangePassword.value = false
      changePasswordSuccess.value = false
    }, 1500)
  } catch {
    changePasswordError.value = 'Mot de passe actuel incorrect'
  }
}

async function onDeactivate() {
  deactivateError.value = undefined

  try {
    await vault.deactivate(deactivatePassword.value)
    deactivatePassword.value = ''
    showDeactivate.value = false
  } catch {
    deactivateError.value = 'Mot de passe incorrect'
  }
}

function closeChangePassword() {
  currentPassword.value = ''
  newPassword.value = ''
  confirmNewPassword.value = ''
  changePasswordError.value = undefined
  changePasswordSuccess.value = false
  showChangePassword.value = false
}

function closeDeactivate() {
  deactivatePassword.value = ''
  deactivateError.value = undefined
  showDeactivate.value = false
}
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink
        to="/settings"
        class="p-2 -ml-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
      >
        <ArrowLeftIcon class="h-5 w-5 text-gray-600 dark:text-gray-400" />
      </NuxtLink>
      <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
        Sécurité
      </h1>
    </div>

    <!-- Vault non activé -->
    <div v-if="!vault.isEnabled.value" class="space-y-4">
      <div class="p-6 bg-white dark:bg-card-dark rounded-xl">
        <div class="flex items-start gap-4">
          <div class="flex items-center justify-center h-12 w-12 rounded-xl bg-primary/10 flex-shrink-0">
            <ShieldCheckIcon class="h-6 w-6 text-primary dark:text-primary-light" />
          </div>
          <div class="flex-1">
            <h2 class="text-base font-semibold text-gray-900 dark:text-white mb-1">
              Vault de chiffrement
            </h2>
            <p class="text-sm text-gray-500 dark:text-gray-400 mb-4">
              Protégez vos montants et notes avec un chiffrement de bout en bout AES-256-GCM.
            </p>
            <CommonAppButton variant="primary" @click="showSetup = true">
              Activer le Vault
            </CommonAppButton>
          </div>
        </div>
      </div>
    </div>

    <!-- Vault activé -->
    <div v-else class="space-y-3">
      <!-- Badge statut -->
      <div class="p-4 bg-white dark:bg-card-dark rounded-xl">
        <div class="flex items-center gap-3">
          <div class="flex items-center justify-center h-10 w-10 rounded-xl bg-success/10 flex-shrink-0">
            <ShieldCheckIcon class="h-5 w-5 text-success" />
          </div>
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900 dark:text-white">
              Vault actif
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              Vos données sensibles sont chiffrées
            </p>
          </div>
          <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-success/10 text-success">
            Actif
          </span>
        </div>
      </div>

      <!-- Changer le mot de passe -->
      <button
        class="w-full flex items-center gap-4 p-4 bg-white dark:bg-card-dark rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors text-left"
        @click="showChangePassword = true"
      >
        <div class="flex items-center justify-center h-10 w-10 rounded-xl bg-primary/10 flex-shrink-0">
          <KeyIcon class="h-5 w-5 text-primary dark:text-primary-light" />
        </div>
        <div class="flex-1">
          <p class="text-sm font-medium text-gray-900 dark:text-white">
            Changer le mot de passe
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400">
            Modifier le mot de passe maître du vault
          </p>
        </div>
      </button>

      <!-- Désactiver -->
      <button
        class="w-full flex items-center gap-4 p-4 bg-white dark:bg-card-dark rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors text-left"
        @click="showDeactivate = true"
      >
        <div class="flex items-center justify-center h-10 w-10 rounded-xl bg-error/10 flex-shrink-0">
          <TrashIcon class="h-5 w-5 text-error" />
        </div>
        <div class="flex-1">
          <p class="text-sm font-medium text-gray-900 dark:text-white">
            Désactiver le Vault
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400">
            Déchiffrer toutes les données et désactiver le vault
          </p>
        </div>
      </button>
    </div>

    <!-- Modal setup -->
    <VaultSetupModal
      :open="showSetup"
      @close="showSetup = false"
      @activated="showSetup = false"
    />

    <!-- Modal changer mot de passe -->
    <CommonAppModal :open="showChangePassword" title="Changer le mot de passe" size="md" @close="closeChangePassword">
      <div class="space-y-4">
        <p v-if="changePasswordSuccess" class="text-sm text-success font-medium">
          Mot de passe modifié avec succès
        </p>
        <p v-if="changePasswordError" class="text-sm text-error">
          {{ changePasswordError }}
        </p>

        <form class="space-y-4" @submit.prevent="onChangePassword">
          <CommonAppInput
            v-model="currentPassword"
            type="password"
            label="Mot de passe actuel"
            placeholder="Votre mot de passe actuel"
          />
          <CommonAppInput
            v-model="newPassword"
            type="password"
            label="Nouveau mot de passe"
            placeholder="Minimum 8 caractères"
          />
          <CommonAppInput
            v-model="confirmNewPassword"
            type="password"
            label="Confirmer le nouveau mot de passe"
            placeholder="Retapez le nouveau mot de passe"
          />

          <div class="flex gap-3 pt-2">
            <CommonAppButton type="button" variant="secondary" class="flex-1" @click="closeChangePassword">
              Annuler
            </CommonAppButton>
            <CommonAppButton
              type="submit"
              variant="primary"
              class="flex-1"
              :loading="vault.isLoading.value"
            >
              Modifier
            </CommonAppButton>
          </div>
        </form>
      </div>
    </CommonAppModal>

    <!-- Modal désactiver -->
    <CommonAppModal :open="showDeactivate" title="Désactiver le Vault" size="md" @close="closeDeactivate">
      <div class="space-y-4">
        <!-- Warning -->
        <div class="flex items-start gap-3 p-4 bg-error/5 dark:bg-error/10 rounded-xl">
          <ExclamationTriangleIcon class="h-6 w-6 text-error flex-shrink-0 mt-0.5" />
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Cette action va déchiffrer toutes vos données et supprimer le vault.
            Les données ne seront plus protégées par le chiffrement.
          </p>
        </div>

        <p v-if="deactivateError" class="text-sm text-error">
          {{ deactivateError }}
        </p>

        <form class="space-y-4" @submit.prevent="onDeactivate">
          <CommonAppInput
            v-model="deactivatePassword"
            type="password"
            label="Mot de passe maître"
            placeholder="Entrez votre mot de passe pour confirmer"
          />

          <div class="flex gap-3 pt-2">
            <CommonAppButton type="button" variant="secondary" class="flex-1" @click="closeDeactivate">
              Annuler
            </CommonAppButton>
            <CommonAppButton
              type="submit"
              variant="danger"
              class="flex-1"
              :loading="vault.isLoading.value"
            >
              Désactiver
            </CommonAppButton>
          </div>
        </form>
      </div>
    </CommonAppModal>
  </div>
</template>
