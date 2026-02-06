import type { AccountType, CategoryType, SyncStatus } from './enums'

export interface Account {
  id: string
  userId: string
  name: string
  type: AccountType
  balance: number
  currency: string
  color: number
  createdAt: string
  updatedAt: string
}

export interface Category {
  id: string
  userId: string | null
  name: string
  iconKey: string
  color: number
  type: CategoryType
  budgetLimit: number | null
  isDefault: boolean
  createdAt: string
  updatedAt: string
}

export interface Transaction {
  id: string
  userId: string
  accountId: string
  categoryId: string
  amount: number
  rawAmount: string
  date: string
  note: string | null
  rawNote: string | null
  recurringId: string | null
  isEncrypted: boolean
  syncStatus: SyncStatus
  createdAt: string
  updatedAt: string
}

export interface TransactionWithDetails extends Transaction {
  account: Account
  category: Category
}

export interface RecurringTransaction {
  id: string
  userId: string
  accountId: string
  categoryId: string
  amount: number
  rawAmount: string
  note: string | null
  rawNote: string | null
  originalDay: number
  startDate: string
  endDate: string | null
  lastGenerated: string | null
  isActive: boolean
  isEncrypted: boolean
  createdAt: string
  updatedAt: string
}

export interface RecurringWithDetails extends RecurringTransaction {
  account: Account
  category: Category
}

export interface UserBudget {
  id: string
  userId: string
  categoryId: string
  budgetLimit: number
  createdAt: string
  updatedAt: string
}

export interface BudgetProgress {
  budgetId: string
  category: Category
  budgetLimit: number
  monthlyBudgetLimit: number
  currentSpending: number
}

export interface UserSetting {
  userId: string
  key: string
  value: string
}

export interface FinancialSummary {
  totalBalance: number
  totalIncome: number
  totalExpense: number
  monthlyIncome: number
  monthlyExpense: number
}

export interface CategoryStatistics {
  categoryId: string
  categoryName: string
  total: number
  count: number
  percentage: number
}

export interface DailyStatistics {
  date: string
  income: number
  expense: number
}

export interface MonthlyStatistics {
  month: number
  year: number
  income: number
  expense: number
}
