<script setup lang="ts">
import { AccountType } from '~/types/enums'

definePageMeta({
  layout: 'blank',
})

const router = useRouter()
const { updateSetting, completeOnboarding } = useSettings()
const { createAccount } = useAccounts()

// Navigation
const questionIndex = ref(0)
const direction = ref(1)
const isCompleting = ref(false)
const isSubmitting = ref(false)
const errorMessage = ref<string | null>(null)

// Q0 — Devise
const currency = ref('EUR')
const currencies = [
  { code: 'EUR', symbol: '€', label: 'Euro' },
  { code: 'USD', symbol: '$', label: 'U.S. Dollar' },
  { code: 'GBP', symbol: '£', label: 'British Pound' },
  { code: 'CHF', symbol: 'Fr', label: 'Swiss Franc' },
]

// Q1 — Compte courant
const wantsChecking = ref<boolean | null>(null)
const checkingBalance = ref(0)

// Q2 — Compte épargne
const wantsSavings = ref<boolean | null>(null)
const savingsBalance = ref(0)

const transitionName = computed(() =>
  direction.value > 0 ? 'question-forward' : 'question-backward',
)

function goNext() {
  errorMessage.value = null
  direction.value = 1
  questionIndex.value++
}

function goPrev() {
  errorMessage.value = null
  direction.value = -1
  questionIndex.value--
}

function selectChecking(val: boolean) {
  wantsChecking.value = val
  if (!val) checkingBalance.value = 0
}

function selectSavings(val: boolean) {
  wantsSavings.value = val
  if (!val) savingsBalance.value = 0
}

async function finish() {
  errorMessage.value = null

  if (!wantsChecking.value && !wantsSavings.value) {
    errorMessage.value = 'Vous devez créer au moins un compte pour continuer.'
    return
  }

  isSubmitting.value = true

  try {
    await updateSetting('currency', currency.value)

    if (wantsChecking.value) {
      await createAccount({
        name: 'Compte courant',
        type: AccountType.CHECKING,
        balance: checkingBalance.value,
        currency: currency.value,
        color: 0xFF1B5E5A,
      })
    }

    if (wantsSavings.value) {
      await createAccount({
        name: 'Compte épargne',
        type: AccountType.SAVINGS,
        balance: savingsBalance.value,
        currency: currency.value,
        color: 0xFF4CAF50,
      })
    }

    await completeOnboarding()
    isCompleting.value = true
  }
  catch {
    isSubmitting.value = false
  }
}

async function onComplete() {
  await router.push('/dashboard')
}
</script>

<template>
  <div class="h-screen flex flex-col bg-background-light dark:bg-background-dark overflow-hidden">

    <!-- Écran de complétion -->
    <OnboardingCompletionScreen
      v-if="isCompleting"
      class="flex-1"
      @complete="onComplete"
    />

    <template v-else>
      <!-- Header : logo + progression -->
      <div class="flex flex-col items-center gap-4 pt-10 pb-2 px-6 shrink-0">
        <span class="text-h2 text-primary dark:text-primary-light">Monasafe</span>
        <OnboardingProgress :current-step="questionIndex" :total-steps="3" />
      </div>

      <!-- Zone de question (full height, overflow masqué pour le slide) -->
      <div class="flex-1 relative overflow-hidden">
        <Transition :name="transitionName" mode="out-in">

          <!-- Q0 : Devise -->
          <div v-if="questionIndex === 0" key="q0" class="absolute inset-0 flex flex-col items-center justify-center px-6">
            <div class="w-full max-w-sm space-y-6">
              <div class="text-center space-y-1">
                <h2 class="text-h3 text-gray-900 dark:text-white">
                  Quelle est votre devise ?
                </h2>
                <p class="text-body-md text-gray-500 dark:text-gray-400">
                  Vous pourrez la modifier dans les paramètres
                </p>
              </div>

              <div class="grid grid-cols-2 gap-3">
                <button
                  v-for="curr in currencies"
                  :key="curr.code"
                  type="button"
                  :class="[
                    'flex items-center gap-3 px-4 py-4 rounded-2xl border-2 text-left transition-all duration-200',
                    currency === curr.code
                      ? 'border-primary bg-primary/5 dark:bg-primary/10'
                      : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600 bg-white dark:bg-card-dark',
                  ]"
                  @click="currency = curr.code"
                >
                  <span class="w-10 h-10 rounded-xl bg-gray-100 dark:bg-gray-800 flex items-center justify-center text-lg font-bold text-gray-700 dark:text-gray-200 shrink-0">
                    {{ curr.symbol }}
                  </span>
                  <div>
                    <div class="text-sm font-semibold text-gray-900 dark:text-white leading-tight">
                      {{ curr.label }}
                    </div>
                    <div class="text-xs text-gray-500 dark:text-gray-400">
                      {{ curr.code }}
                    </div>
                  </div>
                </button>
              </div>
            </div>
          </div>

          <!-- Q1 : Compte courant -->
          <div v-else-if="questionIndex === 1" key="q1" class="absolute inset-0 flex flex-col items-center justify-center px-6">
            <div class="w-full max-w-sm space-y-8">
              <div class="text-center space-y-1">
                <h2 class="text-h3 text-gray-900 dark:text-white">
                  Un compte courant ?
                </h2>
                <p class="text-body-md text-gray-500 dark:text-gray-400">
                  Pour suivre vos dépenses quotidiennes
                </p>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <button
                  type="button"
                  :class="[
                    'py-5 rounded-2xl border-2 text-base font-semibold transition-all duration-200',
                    wantsChecking === true
                      ? 'border-primary bg-primary text-white'
                      : 'border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-300 bg-white dark:bg-card-dark hover:border-gray-300 dark:hover:border-gray-600',
                  ]"
                  @click="selectChecking(true)"
                >
                  Oui
                </button>
                <button
                  type="button"
                  :class="[
                    'py-5 rounded-2xl border-2 text-base font-semibold transition-all duration-200',
                    wantsChecking === false
                      ? 'border-primary bg-primary text-white'
                      : 'border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-300 bg-white dark:bg-card-dark hover:border-gray-300 dark:hover:border-gray-600',
                  ]"
                  @click="selectChecking(false)"
                >
                  Non
                </button>
              </div>

              <Transition name="amount">
                <div v-if="wantsChecking === true">
                  <CommonAppInput
                    v-model="checkingBalance"
                    type="number"
                    label="Solde initial"
                    placeholder="0.00"
                  />
                </div>
              </Transition>
            </div>
          </div>

          <!-- Q2 : Compte épargne -->
          <div v-else-if="questionIndex === 2" key="q2" class="absolute inset-0 flex flex-col items-center justify-center px-6">
            <div class="w-full max-w-sm space-y-8">
              <div class="text-center space-y-1">
                <h2 class="text-h3 text-gray-900 dark:text-white">
                  Et un compte épargne ?
                </h2>
                <p class="text-body-md text-gray-500 dark:text-gray-400">
                  Pour vos objectifs à long terme
                </p>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <button
                  type="button"
                  :class="[
                    'py-5 rounded-2xl border-2 text-base font-semibold transition-all duration-200',
                    wantsSavings === true
                      ? 'border-primary bg-primary text-white'
                      : 'border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-300 bg-white dark:bg-card-dark hover:border-gray-300 dark:hover:border-gray-600',
                  ]"
                  @click="selectSavings(true)"
                >
                  Oui
                </button>
                <button
                  type="button"
                  :class="[
                    'py-5 rounded-2xl border-2 text-base font-semibold transition-all duration-200',
                    wantsSavings === false
                      ? 'border-primary bg-primary text-white'
                      : 'border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-300 bg-white dark:bg-card-dark hover:border-gray-300 dark:hover:border-gray-600',
                  ]"
                  @click="selectSavings(false)"
                >
                  Non
                </button>
              </div>

              <Transition name="amount">
                <div v-if="wantsSavings === true">
                  <CommonAppInput
                    v-model="savingsBalance"
                    type="number"
                    label="Solde initial"
                    placeholder="0.00"
                  />
                </div>
              </Transition>

              <Transition name="amount">
                <p v-if="errorMessage" class="text-sm text-error text-center">
                  {{ errorMessage }}
                </p>
              </Transition>
            </div>
          </div>

        </Transition>
      </div>

      <!-- Navigation (bas de page fixe) -->
      <div class="shrink-0 px-6 pb-10 pt-4">
        <div class="flex gap-3 max-w-sm mx-auto">
          <CommonAppButton
            v-if="questionIndex > 0"
            variant="secondary"
            class="flex-1"
            @click="goPrev"
          >
            Retour
          </CommonAppButton>

          <CommonAppButton
            v-if="questionIndex < 2"
            variant="primary"
            class="flex-1"
            :disabled="questionIndex === 1 && wantsChecking === null"
            @click="goNext"
          >
            Suivant
          </CommonAppButton>

          <CommonAppButton
            v-if="questionIndex === 2"
            variant="primary"
            class="flex-1"
            :loading="isSubmitting"
            :disabled="wantsSavings === null"
            @click="finish"
          >
            Terminer
          </CommonAppButton>
        </div>
      </div>
    </template>
  </div>
</template>
