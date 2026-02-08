<script setup lang="ts">
interface Props {
  totalBalance: number
  monthlyIncome: number
  monthlyExpense: number
}

const props = defineProps<Props>()

const { format: formatMoney } = useCurrency()

const netMonthly = computed(() => props.monthlyIncome - props.monthlyExpense)
</script>

<template>
  <CommonAppCard>
    <h3 class="text-label-md text-gray-500 dark:text-gray-400">
      Solde total
    </h3>
    <p class="text-2xl font-heading font-bold text-gray-900 dark:text-white mt-1">
      {{ formatMoney(props.totalBalance) }}
    </p>
    <div class="flex items-center gap-4 mt-3">
      <div>
        <p class="text-xs text-gray-500 dark:text-gray-400">Revenus</p>
        <p class="text-sm font-semibold text-success">
          +{{ formatMoney(props.monthlyIncome) }}
        </p>
      </div>
      <div>
        <p class="text-xs text-gray-500 dark:text-gray-400">Dépenses</p>
        <p class="text-sm font-semibold text-error">
          -{{ formatMoney(props.monthlyExpense) }}
        </p>
      </div>
      <div>
        <p class="text-xs text-gray-500 dark:text-gray-400">Net</p>
        <p :class="['text-sm font-semibold', netMonthly >= 0 ? 'text-success' : 'text-error']">
          {{ netMonthly >= 0 ? '+' : '' }}{{ formatMoney(netMonthly) }}
        </p>
      </div>
    </div>
  </CommonAppCard>
</template>
