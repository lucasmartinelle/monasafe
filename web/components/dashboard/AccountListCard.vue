<script setup lang="ts">
import type { Account } from '~/types/models'
import { AccountType, AccountTypeLabels } from '~/types/enums'
import { colorStyle } from '~/utils/colors'
import { PlusIcon } from '@heroicons/vue/24/outline'

interface Props {
  accounts: Account[]
  computedBalances?: Record<string, number>
}

const props = withDefaults(defineProps<Props>(), {
  computedBalances: () => ({}),
})

const emit = defineEmits<{
  'create-account': [type: AccountType]
}>()

const { format: formatMoney } = useCurrency()

function getBalance(account: Account): number {
  return props.computedBalances[account.id] ?? account.balance
}

const hasChecking = computed(() => props.accounts.some(a => a.type === AccountType.CHECKING))
const hasSavings = computed(() => props.accounts.some(a => a.type === AccountType.SAVINGS))
</script>

<template>
  <CommonAppCard>
    <h3 class="text-label-md text-gray-500 dark:text-gray-400 mb-3">
      Comptes
    </h3>
    <div class="space-y-3">
      <div
        v-for="account in props.accounts"
        :key="account.id"
        class="flex items-center gap-3"
      >
        <div
          class="w-3 h-3 rounded-full shrink-0"
          :style="{ backgroundColor: colorStyle(account.color) }"
        />
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
            {{ account.name }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400">
            {{ AccountTypeLabels[account.type] }}
          </p>
        </div>
        <p class="text-sm font-semibold text-gray-900 dark:text-white shrink-0">
          {{ formatMoney(getBalance(account)) }}
        </p>
      </div>

      <!-- Bouton créer compte courant si absent -->
      <button
        v-if="!hasChecking"
        type="button"
        class="w-full flex items-center gap-2 px-3 py-2 rounded-xl border border-dashed border-gray-300 dark:border-gray-600 text-sm text-gray-500 dark:text-gray-400 hover:border-primary hover:text-primary dark:hover:border-primary dark:hover:text-primary transition-colors"
        @click="emit('create-account', AccountType.CHECKING)"
      >
        <PlusIcon class="h-4 w-4 shrink-0" />
        Ajouter un compte courant
      </button>

      <!-- Bouton créer compte épargne si absent -->
      <button
        v-if="!hasSavings"
        type="button"
        class="w-full flex items-center gap-2 px-3 py-2 rounded-xl border border-dashed border-gray-300 dark:border-gray-600 text-sm text-gray-500 dark:text-gray-400 hover:border-primary hover:text-primary dark:hover:border-primary dark:hover:text-primary transition-colors"
        @click="emit('create-account', AccountType.SAVINGS)"
      >
        <PlusIcon class="h-4 w-4 shrink-0" />
        Ajouter un compte épargne
      </button>
    </div>
  </CommonAppCard>
</template>
