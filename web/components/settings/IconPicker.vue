<script setup lang="ts">
import { ICON_MAP, getIcon } from '~/utils/icons'
import { intToHex, contrastTextColor } from '~/utils/colors'

interface Props {
  modelValue: string
  color?: number
}

const props = withDefaults(defineProps<Props>(), {
  color: 0xFF1B5E5A,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

// Icônes principales dédupliquées (on ne garde que les clés canoniques)
const PICKER_ICONS: string[] = [
  // Dépenses
  'shopping_cart', 'restaurant', 'local_gas_station', 'home',
  'power', 'wifi', 'phone_android', 'movie', 'sports_esports',
  'fitness_center', 'medical_services', 'school', 'child_care',
  'pets', 'flight', 'hotel', 'beach_access', 'card_giftcard',
  'checkroom', 'content_cut', 'local_laundry_service', 'build',
  'store', 'local_grocery_store', 'local_cafe', 'local_bar',
  'fastfood', 'icecream', 'cake',
  // Revenus
  'work', 'attach_money', 'account_balance', 'trending_up',
  'card_membership', 'redeem', 'savings',
  // Divers
  'category', 'more_horiz', 'star', 'favorite', 'bookmark',
  'flag', 'label', 'lightbulb', 'extension', 'widgets',
  'auto_awesome', 'psychology', 'self_improvement', 'spa',
  'volunteer_activism', 'celebration', 'emoji_events',
  'military_tech', 'workspace_premium', 'diamond',
  'rocket_launch', 'science', 'biotech', 'memory', 'token', 'bolt',
]

const bgColor = computed(() => intToHex(props.color))
const textColorSelected = computed(() => contrastTextColor(props.color))

function select(key: string) {
  emit('update:modelValue', key)
}
</script>

<template>
  <div class="grid grid-cols-6 sm:grid-cols-8 gap-2">
    <button
      v-for="key in PICKER_ICONS"
      :key="key"
      type="button"
      :class="[
        'flex items-center justify-center w-10 h-10 rounded-xl transition-all duration-150',
        props.modelValue === key
          ? 'ring-2 ring-offset-2 ring-primary dark:ring-offset-card-dark scale-110'
          : 'bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 hover:scale-105',
      ]"
      :style="props.modelValue === key ? { backgroundColor: bgColor, color: textColorSelected } : {}"
      :title="key"
      @click="select(key)"
    >
      <component
        :is="getIcon(key)"
        :class="[
          'h-5 w-5',
          props.modelValue !== key ? 'text-gray-600 dark:text-gray-300' : '',
        ]"
      />
    </button>
  </div>
</template>
