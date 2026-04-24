import { CategoryType } from '~/types/enums'

export interface DefaultCategorySeed {
  name: string
  iconKey: string
  color: number
  type: CategoryType
}

/**
 * Set minimal de catégories injectées dans le compte de l'utilisateur
 * à l'inscription. L'utilisateur en devient propriétaire et peut les
 * renommer, modifier ou supprimer librement.
 */
export const DEFAULT_CATEGORIES: DefaultCategorySeed[] = [
  // Dépenses
  { name: 'Alimentation', iconKey: 'shopping-cart', color: 0xFFE87B4D, type: CategoryType.EXPENSE },
  { name: 'Logement', iconKey: 'home', color: 0xFF1B5E5A, type: CategoryType.EXPENSE },
  { name: 'Transport', iconKey: 'car', color: 0xFF2196F3, type: CategoryType.EXPENSE },
  { name: 'Loisirs', iconKey: 'gamepad-2', color: 0xFF9C27B0, type: CategoryType.EXPENSE },
  { name: 'Santé', iconKey: 'heart-pulse', color: 0xFFF44336, type: CategoryType.EXPENSE },
  { name: 'Autres dépenses', iconKey: 'ellipsis', color: 0xFF607D8B, type: CategoryType.EXPENSE },

  // Revenus
  { name: 'Salaire', iconKey: 'wallet', color: 0xFF4CAF50, type: CategoryType.INCOME },
  { name: 'Autres revenus', iconKey: 'arrow-up-circle', color: 0xFF00BCD4, type: CategoryType.INCOME },
]
