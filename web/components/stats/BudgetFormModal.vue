<script setup lang="ts">
import { CategoryType } from '~/types/enums'
import { intToHex } from '~/utils/colors'
import { getIcon } from '~/utils/icons'

interface Props {
  open: boolean
  existingCategoryIds: string[]
}

const props = defineProps<Props>()
const emit = defineEmits<{
  close: []
  submit: [categoryId: string, budgetLimit: number]
}>()

const { categories } = storeToRefs(useCategoriesStore())

// Catégories dépenses sans budget existant
const availableCategories = computed(() =>
  categories.value.filter(
    c => c.type === CategoryType.EXPENSE && !props.existingCategoryIds.includes(c.id),
  ),
)

const selectedCategoryId = ref<string | null>(null)
const budgetAmount = ref('')

const isValid = computed(() => {
  if (!selectedCategoryId.value) return false
  const amount = parseFloat(budgetAmount.value.replace(',', '.'))
  return !isNaN(amount) && amount > 0
})

function handleSubmit() {
  if (!isValid.value || !selectedCategoryId.value) return
  const amount = parseFloat(budgetAmount.value.replace(',', '.'))
  emit('submit', selectedCategoryId.value, Math.round(amount * 100) / 100)
}

function handleClose() {
  selectedCategoryId.value = null
  budgetAmount.value = ''
  emit('close')
}

watch(() => props.open, (val) => {
  if (val) {
    selectedCategoryId.value = null
    budgetAmount.value = ''
  }
})
</script>

<template>
  <CommonAppModal
    :open="props.open"
    title="Nouveau budget"
    size="sm"
    @close="handleClose"
  >
    <div class="space-y-4">
      <!-- Sélection catégorie -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Catégorie
        </label>

        <div v-if="availableCategories.length > 0" class="grid grid-cols-4 gap-2">
          <button
            v-for="cat in availableCategories"
            :key="cat.id"
            type="button"
            :class="[
              'flex flex-col items-center gap-1 p-2.5 rounded-xl border transition-colors',
              selectedCategoryId === cat.id
                ? 'border-primary bg-primary/5'
                : 'border-gray-200 dark:border-gray-600 hover:border-primary/50',
            ]"
            @click="selectedCategoryId = cat.id"
          >
            <div
              class="flex items-center justify-center h-8 w-8 rounded-lg"
              :style="{ backgroundColor: intToHex(cat.color) + '20' }"
            >
              <component
                :is="getIcon(cat.iconKey)"
                class="h-4 w-4"
                :style="{ color: intToHex(cat.color) }"
              />
            </div>
            <span class="text-xs text-gray-700 dark:text-gray-300 text-center truncate w-full">
              {{ cat.name }}
            </span>
          </button>
        </div>

        <p v-else class="text-sm text-gray-400 dark:text-gray-500">
          Toutes les catégories ont déjà un budget.
        </p>
      </div>

      <!-- Montant -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Plafond mensuel
        </label>
        <div class="relative">
          <input
            v-model="budgetAmount"
            type="text"
            inputmode="decimal"
            placeholder="0,00"
            class="w-full px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-right pr-10 focus:ring-2 focus:ring-primary/50 focus:border-primary outline-none"
          >
          <span class="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 text-sm">
            &euro;
          </span>
        </div>
      </div>

      <!-- Actions -->
      <div class="flex gap-3 pt-2">
        <CommonAppButton
          variant="secondary"
          class="flex-1"
          @click="handleClose"
        >
          Annuler
        </CommonAppButton>
        <CommonAppButton
          variant="primary"
          class="flex-1"
          :disabled="!isValid"
          @click="handleSubmit"
        >
          Créer
        </CommonAppButton>
      </div>
    </div>
  </CommonAppModal>
</template>
