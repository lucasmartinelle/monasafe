<script setup lang="ts">
import { AccountType, AccountTypeLabels } from '~/types/enums'

interface Props {
  type: AccountType
}

const props = defineProps<Props>()

const badgeColors: Record<AccountType, string> = {
  [AccountType.CHECKING]: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300',
  [AccountType.SAVINGS]: 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300',
  [AccountType.CASH]: 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300',
}
</script>

<template>
  <span
    :class="[
      'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
      badgeColors[props.type],
    ]"
  >
    {{ AccountTypeLabels[props.type] }}
  </span>
</template>
