<script setup lang="ts">
import type { Account } from '~/types/models'
import { AccountTypeLabels } from '~/types/enums'
import { colorStyle } from '~/utils/colors'

interface Props {
  accounts: Account[]
  computedBalances?: Record<string, number>
}

const props = withDefaults(defineProps<Props>(), {
  computedBalances: () => ({}),
})

const { format: formatMoney } = useCurrency()

function getBalance(account: Account): number {
  return props.computedBalances[account.id] ?? account.balance
}
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

      <div
        v-if="props.accounts.length === 0"
        class="text-center py-4 text-sm text-gray-400 dark:text-gray-500"
      >
        Aucun compte
      </div>
    </div>
  </CommonAppCard>
</template>
