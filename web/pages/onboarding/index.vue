<script setup lang="ts">
import { AccountType, AccountTypeLabels } from '~/types/enums'
import {
  CurrencyEuroIcon,
  BanknotesIcon,
  CheckCircleIcon,
  ArrowLeftIcon,
  ArrowRightIcon,
  BuildingLibraryIcon,
  BanknotesIcon as BanknotesIconSolid,
} from '@heroicons/vue/24/outline'

definePageMeta({
  layout: 'auth',
})

const router = useRouter()
const { updateSetting, completeOnboarding } = useSettings()
const { createAccount } = useAccounts()

// Étapes
const currentStep = ref(1)
const totalSteps = 3
const isSubmitting = ref(false)

// Step 1 — Devise (identique au mobile)
const currencies = [
  { code: 'USD', symbol: '$', label: 'U.S. Dollar' },
  { code: 'EUR', symbol: '€', label: 'Euro' },
  { code: 'GBP', symbol: '£', label: 'British Pound' },
  { code: 'CHF', symbol: 'Fr', label: 'Swiss Franc' },
]
const selectedCurrency = ref('EUR')

// Step 2 — Premier compte (type + solde uniquement, comme le mobile)
const accountType = ref<AccountType>(AccountType.CHECKING)
const accountBalance = ref(0)

// Nom auto-assigné selon le type (comme le mobile)
const accountName = computed(() =>
  accountType.value === AccountType.CHECKING ? 'Compte courant' : 'Compte épargne',
)

// Couleur hardcodée (comme le mobile)
const ACCOUNT_COLOR = 0xFF1B5E5A

const accountTypes = [
  {
    value: AccountType.CHECKING,
    label: 'Compte courant',
    description: 'Dépenses quotidiennes',
    icon: BuildingLibraryIcon,
  },
  {
    value: AccountType.SAVINGS,
    label: 'Compte épargne',
    description: 'Objectifs long terme',
    icon: BanknotesIconSolid,
  },
]

function nextStep() {
  if (currentStep.value < totalSteps) {
    currentStep.value++
  }
}

function prevStep() {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

async function finish() {
  isSubmitting.value = true

  try {
    // Sauvegarder la devise
    await updateSetting('currency', selectedCurrency.value)

    // Créer le premier compte
    const account = await createAccount({
      name: accountName.value,
      type: accountType.value,
      balance: accountBalance.value,
      currency: selectedCurrency.value,
      color: ACCOUNT_COLOR,
    })

    if (!account) {
      isSubmitting.value = false
      return
    }

    // Compléter l'onboarding
    await completeOnboarding()

    // Redirect vers le dashboard
    await router.push('/dashboard')
  } catch {
    isSubmitting.value = false
  }
}
</script>

<template>
  <CommonAppCard>
    <div class="space-y-6">
      <!-- Progress bar -->
      <div class="flex items-center gap-2">
        <div
          v-for="step in totalSteps"
          :key="step"
          :class="[
            'h-1.5 flex-1 rounded-full transition-colors duration-300',
            step <= currentStep ? 'bg-primary' : 'bg-gray-200 dark:bg-gray-700',
          ]"
        />
      </div>

      <!-- Step 1 : Devise -->
      <div v-if="currentStep === 1" class="space-y-5">
        <div class="text-center">
          <div class="mx-auto w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center mb-3">
            <CurrencyEuroIcon class="h-6 w-6 text-primary" />
          </div>
          <h2 class="text-h3 text-gray-900 dark:text-white">
            Choisissez votre devise
          </h2>
          <p class="text-body-md text-gray-500 dark:text-gray-400 mt-1">
            Vous pourrez la modifier plus tard dans les paramètres
          </p>
        </div>

        <div class="grid grid-cols-1 gap-2">
          <button
            v-for="curr in currencies"
            :key="curr.code"
            type="button"
            :class="[
              'flex items-center gap-3 px-4 py-3 rounded-xl border text-left transition-all duration-150',
              selectedCurrency === curr.code
                ? 'border-primary bg-primary/5 ring-1 ring-primary'
                : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600',
            ]"
            @click="selectedCurrency = curr.code"
          >
            <span class="w-10 h-10 rounded-lg bg-gray-100 dark:bg-gray-800 flex items-center justify-center text-lg font-semibold text-gray-700 dark:text-gray-300">
              {{ curr.symbol }}
            </span>
            <div>
              <div class="text-sm font-medium text-gray-900 dark:text-white">
                {{ curr.label }}
              </div>
              <div class="text-xs text-gray-500 dark:text-gray-400">
                {{ curr.code }}
              </div>
            </div>
          </button>
        </div>
      </div>

      <!-- Step 2 : Premier compte -->
      <div v-if="currentStep === 2" class="space-y-5">
        <div class="text-center">
          <div class="mx-auto w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center mb-3">
            <BanknotesIcon class="h-6 w-6 text-primary" />
          </div>
          <h2 class="text-h3 text-gray-900 dark:text-white">
            Créez votre premier compte
          </h2>
          <p class="text-body-md text-gray-500 dark:text-gray-400 mt-1">
            Vous pourrez en ajouter d'autres plus tard
          </p>
        </div>

        <!-- Type de compte (toggle) -->
        <div class="grid grid-cols-2 gap-3">
          <button
            v-for="at in accountTypes"
            :key="at.value"
            type="button"
            :class="[
              'flex flex-col items-center gap-2 p-4 rounded-xl border text-center transition-all duration-150',
              accountType === at.value
                ? 'border-primary bg-primary/5 ring-1 ring-primary'
                : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600',
            ]"
            @click="accountType = at.value"
          >
            <component :is="at.icon" class="h-6 w-6 text-primary" />
            <div>
              <div class="text-sm font-medium text-gray-900 dark:text-white">
                {{ at.label }}
              </div>
              <div class="text-xs text-gray-500 dark:text-gray-400">
                {{ at.description }}
              </div>
            </div>
          </button>
        </div>

        <!-- Solde initial -->
        <CommonAppInput
          v-model="accountBalance"
          type="number"
          label="Solde initial"
          placeholder="0.00"
        />
      </div>

      <!-- Step 3 : Confirmation -->
      <div v-if="currentStep === 3" class="space-y-5">
        <div class="text-center">
          <div class="mx-auto w-12 h-12 rounded-xl bg-success/10 flex items-center justify-center mb-3">
            <CheckCircleIcon class="h-6 w-6 text-success" />
          </div>
          <h2 class="text-h3 text-gray-900 dark:text-white">
            Tout est prêt !
          </h2>
          <p class="text-body-md text-gray-500 dark:text-gray-400 mt-1">
            Voici un récapitulatif de votre configuration
          </p>
        </div>

        <!-- Récap -->
        <div class="space-y-3">
          <div class="flex items-center justify-between p-3 rounded-xl bg-gray-50 dark:bg-gray-800/50">
            <span class="text-sm text-gray-500 dark:text-gray-400">Devise</span>
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              {{ currencies.find(c => c.code === selectedCurrency)?.label }} ({{ selectedCurrency }})
            </span>
          </div>
          <div class="flex items-center justify-between p-3 rounded-xl bg-gray-50 dark:bg-gray-800/50">
            <span class="text-sm text-gray-500 dark:text-gray-400">Compte</span>
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              {{ accountName }}
            </span>
          </div>
          <div class="flex items-center justify-between p-3 rounded-xl bg-gray-50 dark:bg-gray-800/50">
            <span class="text-sm text-gray-500 dark:text-gray-400">Solde initial</span>
            <span class="text-sm font-medium text-gray-900 dark:text-white">
              {{ accountBalance.toLocaleString('fr-FR', { minimumFractionDigits: 2 }) }} {{ selectedCurrency }}
            </span>
          </div>
        </div>
      </div>

      <!-- Navigation -->
      <div class="flex gap-3">
        <CommonAppButton
          v-if="currentStep > 1"
          variant="secondary"
          class="flex-1"
          @click="prevStep"
        >
          <ArrowLeftIcon class="h-4 w-4 mr-1" />
          Retour
        </CommonAppButton>

        <CommonAppButton
          v-if="currentStep < totalSteps"
          variant="primary"
          class="flex-1"
          @click="nextStep"
        >
          Suivant
          <ArrowRightIcon class="h-4 w-4 ml-1" />
        </CommonAppButton>

        <CommonAppButton
          v-if="currentStep === totalSteps"
          variant="primary"
          class="flex-1"
          :loading="isSubmitting"
          @click="finish"
        >
          Commencer
        </CommonAppButton>
      </div>
    </div>
  </CommonAppCard>
</template>
