<script setup lang="ts">
import { ShieldCheckIcon, ExclamationTriangleIcon } from '@heroicons/vue/24/outline'

interface Props {
  open: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  activated: []
}>()

const vault = useVault()

const password = ref('')
const confirmPassword = ref('')
const passwordError = ref<string | undefined>(undefined)
const confirmError = ref<string | undefined>(undefined)

// Nettoyer toutes les erreurs à l'ouverture de la modal
watch(() => props.open, (isOpen) => {
  if (isOpen) {
    password.value = ''
    confirmPassword.value = ''
    passwordError.value = undefined
    confirmError.value = undefined
    vault.clearError()
  }
})

// Effacer les erreurs de champ dès que l'utilisateur tape
watch(password, () => { passwordError.value = undefined })
watch(confirmPassword, () => { confirmError.value = undefined })

function validate(): boolean {
  let valid = true
  passwordError.value = undefined
  confirmError.value = undefined

  if (password.value.length < 8) {
    passwordError.value = '8 caractères minimum'
    valid = false
  }

  if (password.value !== confirmPassword.value) {
    confirmError.value = 'Les mots de passe ne correspondent pas'
    valid = false
  }

  return valid
}

async function onSubmit() {
  if (!validate()) return

  try {
    await vault.activate(password.value)
    password.value = ''
    confirmPassword.value = ''
    emit('activated')
    emit('close')
  } catch {
    // L'erreur est affichée via vault.error
  }
}

function onClose() {
  password.value = ''
  confirmPassword.value = ''
  passwordError.value = undefined
  confirmError.value = undefined
  vault.clearError()
  emit('close')
}
</script>

<template>
  <CommonAppModal :open="open" title="Activer le Vault" size="md" @close="onClose">
    <div class="space-y-5">
      <!-- Explication -->
      <div class="flex items-start gap-3 p-4 bg-primary/5 dark:bg-primary/10 rounded-xl">
        <ShieldCheckIcon class="h-6 w-6 text-primary dark:text-primary-light flex-shrink-0 mt-0.5" />
        <div>
          <p class="text-sm font-medium text-gray-900 dark:text-white mb-1">
            Qu'est-ce que le Vault ?
          </p>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Le Vault chiffre vos montants et notes de transactions avec un chiffrement de bout en bout (AES-256-GCM).
            Vos données sensibles sont protégées même en cas d'accès non autorisé à la base de données.
          </p>
        </div>
      </div>

      <!-- Warning -->
      <div class="flex items-start gap-3 p-4 bg-warning/10 rounded-xl">
        <ExclamationTriangleIcon class="h-6 w-6 text-warning flex-shrink-0 mt-0.5" />
        <div>
          <p class="text-sm font-medium text-gray-900 dark:text-white mb-1">
            Important
          </p>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Si vous perdez votre mot de passe, vos données chiffrées seront irrécupérables.
            Aucune procédure de récupération n'est possible.
          </p>
        </div>
      </div>

      <!-- Erreur vault -->
      <p v-if="vault.error.value" class="text-sm text-error">
        {{ vault.error.value }}
      </p>

      <!-- Formulaire -->
      <form class="space-y-4" @submit.prevent="onSubmit">
        <CommonAppInput
          v-model="password"
          type="password"
          label="Mot de passe maître"
          placeholder="Minimum 8 caractères"
          :error="passwordError"
        />

        <CommonAppInput
          v-model="confirmPassword"
          type="password"
          label="Confirmer le mot de passe"
          placeholder="Retapez le mot de passe"
          :error="confirmError"
        />

        <div class="flex gap-3 pt-2">
          <CommonAppButton type="button" variant="secondary" class="flex-1" @click="onClose">
            Annuler
          </CommonAppButton>
          <CommonAppButton
            type="submit"
            variant="primary"
            class="flex-1"
            :loading="vault.isLoading.value"
          >
            Activer le Vault
          </CommonAppButton>
        </div>
      </form>
    </div>
  </CommonAppModal>
</template>
