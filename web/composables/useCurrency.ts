import { formatCurrency } from '~/utils/currency'

/**
 * Composable de formatage devise — réactif.
 *
 * Utilise le store settings pour lire la devise courante
 * et expose une fonction de formatage réactive.
 */
export function useCurrency() {
  const store = useSettingsStore()

  const currency = computed(() => store.currency)

  function format(amount: number): string {
    return formatCurrency(amount, store.currency)
  }

  return {
    currency,
    format,
  }
}
