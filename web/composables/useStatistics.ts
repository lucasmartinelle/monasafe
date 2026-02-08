import type { FinancialSummary, CategoryStatistics, MonthlyStatistics, DailyStatistics } from '~/types/models'
import { CategoryType } from '~/types/enums'
import { getMonthRange, toISODateString } from '~/utils/dates'

/**
 * Composable statistiques — logique métier.
 *
 * Calculs financiers à partir des stores accounts, transactions et categories.
 * Pas d'appels API : lecture seule depuis les stores.
 */
export function useStatistics() {
  const accountsStore = useAccountsStore()
  const transactionsStore = useTransactionsStore()
  const categoriesStore = useCategoriesStore()

  /**
   * Résumé financier global
   */
  function calculateFinancialSummary(startDate?: string, endDate?: string): FinancialSummary {
    const totalBalance = accountsStore.totalBalance

    const allTransactions = transactionsStore.transactions
    const categories = categoriesStore.categories

    const categoryTypeMap = new Map(categories.map(c => [c.id, c.type]))

    let totalIncome = 0
    let totalExpense = 0
    let monthlyIncome = 0
    let monthlyExpense = 0

    const now = new Date()
    const { start: monthStart, end: monthEnd } = getMonthRange(now)
    const monthStartStr = toISODateString(monthStart)
    const monthEndStr = toISODateString(monthEnd)

    for (const tx of allTransactions) {
      const catType = categoryTypeMap.get(tx.categoryId)
      const amount = Math.abs(tx.amount)

      if (catType === CategoryType.INCOME) {
        totalIncome += amount
      } else {
        totalExpense += amount
      }

      // Filtrer pour le mois courant
      if (tx.date >= monthStartStr && tx.date <= monthEndStr) {
        if (catType === CategoryType.INCOME) {
          monthlyIncome += amount
        } else {
          monthlyExpense += amount
        }
      }
    }

    return {
      totalBalance,
      totalIncome,
      totalExpense,
      monthlyIncome,
      monthlyExpense,
    }
  }

  /**
   * Statistiques par catégorie pour une période
   */
  function calculateCategoryStats(
    startDate: string,
    endDate: string,
    type?: CategoryType,
    accountId?: string | null,
  ): CategoryStatistics[] {
    const categories = categoriesStore.categories
    const transactions = transactionsStore.transactions

    const categoryTypeMap = new Map(categories.map(c => [c.id, c]))

    // Filtrer les transactions par période et compte
    const filtered = transactions.filter(tx => {
      if (tx.date < startDate || tx.date > endDate) return false
      if (accountId && tx.accountId !== accountId) return false
      if (type) {
        const cat = categoryTypeMap.get(tx.categoryId)
        if (cat?.type !== type) return false
      }
      return true
    })

    // Grouper par catégorie
    const grouped = new Map<string, { total: number; count: number }>()

    for (const tx of filtered) {
      const existing = grouped.get(tx.categoryId) ?? { total: 0, count: 0 }
      existing.total += Math.abs(tx.amount)
      existing.count += 1
      grouped.set(tx.categoryId, existing)
    }

    // Calculer le total pour les pourcentages
    let grandTotal = 0
    for (const { total } of grouped.values()) {
      grandTotal += total
    }

    // Construire les résultats
    const results: CategoryStatistics[] = []
    for (const [categoryId, { total, count }] of grouped) {
      const cat = categoryTypeMap.get(categoryId)
      results.push({
        categoryId,
        categoryName: cat?.name ?? 'Inconnue',
        total,
        count,
        percentage: grandTotal > 0 ? (total / grandTotal) * 100 : 0,
      })
    }

    return results.sort((a, b) => b.total - a.total)
  }

  /**
   * Statistiques mensuelles (revenus vs dépenses)
   */
  function calculateMonthlyStats(year: number): MonthlyStatistics[] {
    const categories = categoriesStore.categories
    const transactions = transactionsStore.transactions

    const categoryTypeMap = new Map(categories.map(c => [c.id, c.type]))

    const months: MonthlyStatistics[] = []

    for (let month = 0; month < 12; month++) {
      const date = new Date(year, month, 1)
      const { start, end } = getMonthRange(date)
      const startStr = toISODateString(start)
      const endStr = toISODateString(end)

      let income = 0
      let expense = 0

      for (const tx of transactions) {
        if (tx.date < startStr || tx.date > endStr) continue

        const catType = categoryTypeMap.get(tx.categoryId)
        const amount = Math.abs(tx.amount)

        if (catType === CategoryType.INCOME) {
          income += amount
        } else {
          expense += amount
        }
      }

      months.push({ month: month + 1, year, income, expense })
    }

    return months
  }

  /**
   * Statistiques journalières pour une période
   */
  function calculateDailyStats(startDate: string, endDate: string): DailyStatistics[] {
    const categories = categoriesStore.categories
    const transactions = transactionsStore.transactions

    const categoryTypeMap = new Map(categories.map(c => [c.id, c.type]))

    const dailyMap = new Map<string, { income: number; expense: number }>()

    for (const tx of transactions) {
      if (tx.date < startDate || tx.date > endDate) continue

      const existing = dailyMap.get(tx.date) ?? { income: 0, expense: 0 }
      const catType = categoryTypeMap.get(tx.categoryId)
      const amount = Math.abs(tx.amount)

      if (catType === CategoryType.INCOME) {
        existing.income += amount
      } else {
        existing.expense += amount
      }

      dailyMap.set(tx.date, existing)
    }

    const results: DailyStatistics[] = []
    for (const [date, { income, expense }] of dailyMap) {
      results.push({ date, income, expense })
    }

    return results.sort((a, b) => a.date.localeCompare(b.date))
  }

  return {
    calculateFinancialSummary,
    calculateCategoryStats,
    calculateMonthlyStats,
    calculateDailyStats,
  }
}
