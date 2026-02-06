export enum AccountType {
  CHECKING = 'checking',
  SAVINGS = 'savings',
  CASH = 'cash',
}

export enum CategoryType {
  INCOME = 'income',
  EXPENSE = 'expense',
}

export enum SyncStatus {
  PENDING = 'pending',
  SYNCED = 'synced',
}

export const AccountTypeLabels: Record<AccountType, string> = {
  [AccountType.CHECKING]: 'Courant',
  [AccountType.SAVINGS]: 'Épargne',
  [AccountType.CASH]: 'Espèces',
}

export const CategoryTypeLabels: Record<CategoryType, string> = {
  [CategoryType.INCOME]: 'Revenus',
  [CategoryType.EXPENSE]: 'Dépenses',
}
