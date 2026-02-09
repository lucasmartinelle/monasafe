<script setup lang="ts">
import { LockClosedIcon } from '@heroicons/vue/24/outline'

const vault = useVault()

const password = ref('')
const error = ref<string | undefined>(undefined)

async function onUnlock() {
  error.value = undefined

  try {
    await vault.unlock(password.value)
    password.value = ''
  } catch {
    error.value = 'Mot de passe incorrect'
    password.value = ''
  }
}
</script>

<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-background-light dark:bg-background-dark">
    <div class="w-full max-w-sm mx-4 text-center space-y-6">
      <!-- Icône cadenas -->
      <div class="flex items-center justify-center mx-auto h-20 w-20 rounded-full bg-primary/10">
        <LockClosedIcon class="h-10 w-10 text-primary dark:text-primary-light" />
      </div>

      <!-- Titre -->
      <div>
        <h1 class="text-2xl font-heading font-bold text-gray-900 dark:text-white">
          SimpleFlow verrouillé
        </h1>
        <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">
          Entrez votre mot de passe maître pour déverrouiller l'application
        </p>
      </div>

      <!-- Erreur -->
      <p v-if="error" class="text-sm text-error">
        {{ error }}
      </p>

      <!-- Formulaire -->
      <form class="space-y-4" @submit.prevent="onUnlock">
        <CommonAppInput
          v-model="password"
          type="password"
          placeholder="Mot de passe maître"
          :error="undefined"
        />

        <CommonAppButton
          type="submit"
          variant="primary"
          block
          :loading="vault.isLoading.value"
          :disabled="!password"
        >
          Déverrouiller
        </CommonAppButton>
      </form>
    </div>
  </div>
</template>
