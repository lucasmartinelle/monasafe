<script setup lang="ts">
import { PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'
import type { Account } from '~/types/models'
import { intToHex, contrastTextColor } from '~/utils/colors'

interface Props {
  account: Account
}

const props = defineProps<Props>()

defineEmits<{
  click: []
  edit: []
  delete: []
}>()

const { format } = useCurrency()

const colorHex = computed(() => intToHex(props.account.color))
const textColor = computed(() => contrastTextColor(props.account.color))
</script>

<template>
  <CommonAppCard hoverable class="relative overflow-hidden" @click="$emit('click')">
    <!-- Bande de couleur -->
    <div
      class="absolute top-0 left-0 w-1.5 h-full"
      :style="{ backgroundColor: colorHex }"
    />

    <div class="flex items-center justify-between pl-3">
      <div class="flex items-center gap-3">
        <!-- Pastille couleur -->
        <div
          class="w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold shrink-0"
          :style="{ backgroundColor: colorHex, color: textColor }"
        >
          {{ account.name.charAt(0).toUpperCase() }}
        </div>

        <div>
          <h3 class="text-sm font-semibold text-gray-900 dark:text-white">
            {{ account.name }}
          </h3>
          <CommonAccountTypeBadge :type="account.type" />
        </div>
      </div>

      <div class="flex items-center gap-2">
        <span class="text-lg font-semibold text-gray-900 dark:text-white">
          {{ format(account.balance) }}
        </span>

        <!-- Actions -->
        <div class="flex items-center gap-1 ml-2">
          <button
            class="p-1.5 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            @click.stop="$emit('edit')"
          >
            <PencilIcon class="h-4 w-4 text-gray-500" />
          </button>
          <button
            class="p-1.5 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
            @click.stop="$emit('delete')"
          >
            <TrashIcon class="h-4 w-4 text-error" />
          </button>
        </div>
      </div>
    </div>
  </CommonAppCard>
</template>
