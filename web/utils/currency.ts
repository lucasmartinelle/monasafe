const currencyFormatters = new Map<string, Intl.NumberFormat>()

function getFormatter(currency: string): Intl.NumberFormat {
  if (!currencyFormatters.has(currency)) {
    currencyFormatters.set(
      currency,
      new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency,
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }),
    )
  }
  return currencyFormatters.get(currency)!
}

export function formatCurrency(amount: number, currency = 'EUR'): string {
  return getFormatter(currency).format(amount)
}

export function formatAmount(amount: number): string {
  return new Intl.NumberFormat('fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount)
}

export function parseCurrencyInput(value: string): number {
  const cleaned = value.replace(/[^\d,.-]/g, '').replace(',', '.')
  const parsed = parseFloat(cleaned)
  return isNaN(parsed) ? 0 : Math.round(parsed * 100) / 100
}
