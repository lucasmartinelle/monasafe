<script setup lang="ts">
import { z } from 'zod'
import type { Category } from '~/types/models'
import { CategoryType, CategoryTypeLabels } from '~/types/enums'
import { COLOR_PALETTE } from '~/utils/colors'

interface Props {
  open: boolean
  category?: Category | null
}

const props = withDefaults(defineProps<Props>(), {
  category: null,
})

const emit = defineEmits<{
  close: []
  submit: [data: { name: string; iconKey: string; color: number; type: CategoryType; budgetLimit: number | null }]
}>()

const isEditing = computed(() => !!props.category)

// Form state
const name = ref('')
const iconKey = ref('category')
const color = ref(COLOR_PALETTE[0])
const type = ref<CategoryType>(CategoryType.EXPENSE)
const budgetLimit = ref(0)
const hasBudget = ref(false)

// Validation
const schema = z.object({
  name: z.string().min(1, 'Le nom est requis').max(50, '50 caractères maximum'),
  iconKey: z.string().min(1, 'Choisissez une icône'),
  color: z.number(),
  type: z.nativeEnum(CategoryType),
})

const errors = ref<Record<string, string>>({})

function resetForm() {
  name.value = ''
  iconKey.value = 'category'
  color.value = COLOR_PALETTE[0]
  type.value = CategoryType.EXPENSE
  budgetLimit.value = 0
  hasBudget.value = false
  errors.value = {}
}

function syncFromCategory(cat: Category | null) {
  if (cat) {
    name.value = cat.name
    iconKey.value = cat.iconKey
    color.value = cat.color
    type.value = cat.type
    budgetLimit.value = cat.budgetLimit ?? 0
    hasBudget.value = cat.budgetLimit !== null && cat.budgetLimit > 0
  } else {
    resetForm()
  }
}

// Sync props → state quand la modal s'ouvre
watch(() => props.open, (isOpen) => {
  if (isOpen) {
    syncFromCategory(props.category ?? null)
  }
})

function validate(): boolean {
  const result = schema.safeParse({
    name: name.value,
    iconKey: iconKey.value,
    color: color.value,
    type: type.value,
  })

  if (!result.success) {
    errors.value = {}
    for (const issue of result.error.issues) {
      const key = issue.path[0] as string
      errors.value[key] = issue.message
    }
    return false
  }

  errors.value = {}
  return true
}

function handleSubmit() {
  if (!validate()) return

  emit('submit', {
    name: name.value.trim(),
    iconKey: iconKey.value,
    color: color.value,
    type: type.value,
    budgetLimit: hasBudget.value && budgetLimit.value && budgetLimit.value > 0
      ? budgetLimit.value
      : null,
  })
}
</script>

<template>
  <CommonAppModal
    :open="props.open"
    :title="isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie'"
    size="lg"
    @close="emit('close')"
  >
    <form class="space-y-5" @submit.prevent="handleSubmit">
      <!-- Nom -->
      <CommonAppInput
        v-model="name"
        label="Nom"
        placeholder="Ex : Alimentation"
        :error="errors.name"
      />

      <!-- Type -->
      <div v-if="!isEditing" class="w-full">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Type
        </label>
        <select
          v-model="type"
          class="w-full px-4 py-2.5 rounded-[12px] border border-gray-300 dark:border-gray-600 bg-white dark:bg-card-dark text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary transition-colors duration-150"
        >
          <option
            v-for="(label, key) in CategoryTypeLabels"
            :key="key"
            :value="key"
          >
            {{ label }}
          </option>
        </select>
      </div>

      <!-- Icône -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Icône
        </label>
        <p v-if="errors.iconKey" class="mb-1 text-sm text-error">{{ errors.iconKey }}</p>
        <SettingsIconPicker v-model="iconKey" :color="color" />
      </div>

      <!-- Couleur -->
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Couleur
        </label>
        <CommonColorPicker v-model="color" />
      </div>

      <!-- Budget (dépenses uniquement) -->
      <div v-if="type === CategoryType.EXPENSE">
        <label class="flex items-center gap-2 text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          <input
            v-model="hasBudget"
            type="checkbox"
            class="rounded border-gray-300 text-primary focus:ring-primary"
          >
          Définir un budget mensuel
        </label>
        <CommonAppInput
          v-if="hasBudget"
          v-model="budgetLimit"
          type="number"
          placeholder="0.00"
          label=""
        />
      </div>

      <!-- Actions -->
      <div class="flex gap-3 pt-2">
        <CommonAppButton
          type="button"
          variant="secondary"
          class="flex-1"
          @click="emit('close')"
        >
          Annuler
        </CommonAppButton>
        <CommonAppButton
          type="submit"
          variant="primary"
          class="flex-1"
        >
          {{ isEditing ? 'Modifier' : 'Créer' }}
        </CommonAppButton>
      </div>
    </form>
  </CommonAppModal>
</template>
