import 'package:drift/drift.dart';

import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/local/tables/accounts_table.dart';
import 'package:simpleflow/src/data/local/tables/categories_table.dart';
import 'package:simpleflow/src/data/local/tables/transactions_table.dart';

part 'statistics_dao.g.dart';

/// DTO pour les statistiques par catégorie
class CategoryStatistics {

  CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.iconKey,
    required this.color,
    required this.type,
    required this.total,
    required this.transactionCount,
  });
  final String categoryId;
  final String categoryName;
  final String iconKey;
  final int color;
  final CategoryType type;
  final double total;
  final int transactionCount;
}

/// DTO pour les statistiques mensuelles
class MonthlyStatistics {

  MonthlyStatistics({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double balance;
}

/// DTO pour le résumé financier
class FinancialSummary {

  FinancialSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double monthlyIncome;
  final double monthlyExpense;
}

/// DAO pour les requêtes statistiques agrégées
///
/// Optimisations :
/// - Utilise les index sur date et category_id pour les GROUP BY
/// - Requêtes SQL brutes quand nécessaire pour les agrégations complexes
/// - Streams réactifs pour mise à jour automatique des graphiques
@DriftAccessor(tables: [Transactions, Accounts, Categories])
class StatisticsDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticsDaoMixin {
  StatisticsDao(super.db);

  /// Calcule le total par catégorie sur une période
  /// Utilise idx_transactions_date + idx_transactions_category_id
  ///
  /// Requête SQL optimisée :
  /// SELECT c.*, SUM(t.amount) as total, COUNT(t.id) as count
  /// FROM transactions t
  /// JOIN categories c ON t.category_id = c.id
  /// WHERE t.date BETWEEN ? AND ?
  /// GROUP BY t.category_id
  Future<List<CategoryStatistics>> getTotalByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sumAmount = transactions.amount.sum();
    final countTx = transactions.id.count();

    final query = selectOnly(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..addColumns([
        categories.id,
        categories.name,
        categories.iconKey,
        categories.color,
        categories.type,
        sumAmount,
        countTx,
      ])
      ..where(transactions.date.isBetweenValues(startDate, endDate))
      ..groupBy([categories.id]);

    final results = await query.get();
    return results.map((row) {
      return CategoryStatistics(
        categoryId: row.read(categories.id)!,
        categoryName: row.read(categories.name)!,
        iconKey: row.read(categories.iconKey)!,
        color: row.read(categories.color)!,
        type: CategoryType.values[row.read(categories.type)!],
        total: row.read(sumAmount) ?? 0.0,
        transactionCount: row.read(countTx) ?? 0,
      );
    }).toList();
  }

  /// Stream du total par catégorie
  Stream<List<CategoryStatistics>> watchTotalByCategory(
    DateTime startDate,
    DateTime endDate,
  ) {
    final sumAmount = transactions.amount.sum();
    final countTx = transactions.id.count();

    final query = selectOnly(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..addColumns([
        categories.id,
        categories.name,
        categories.iconKey,
        categories.color,
        categories.type,
        sumAmount,
        countTx,
      ])
      ..where(transactions.date.isBetweenValues(startDate, endDate))
      ..groupBy([categories.id]);

    return query.watch().map((results) {
      return results.map((row) {
        return CategoryStatistics(
          categoryId: row.read(categories.id)!,
          categoryName: row.read(categories.name)!,
          iconKey: row.read(categories.iconKey)!,
          color: row.read(categories.color)!,
          type: CategoryType.values[row.read(categories.type)!],
          total: row.read(sumAmount) ?? 0.0,
          transactionCount: row.read(countTx) ?? 0,
        );
      }).toList();
    });
  }

  /// Calcule les totaux par catégorie pour un type spécifique (income/expense)
  Future<List<CategoryStatistics>> getTotalByCategoryAndType(
    DateTime startDate,
    DateTime endDate,
    CategoryType type,
  ) async {
    final sumAmount = transactions.amount.sum();
    final countTx = transactions.id.count();

    final query = selectOnly(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])
      ..addColumns([
        categories.id,
        categories.name,
        categories.iconKey,
        categories.color,
        categories.type,
        sumAmount,
        countTx,
      ])
      ..where(transactions.date.isBetweenValues(startDate, endDate) &
          categories.type.equals(type.index))
      ..groupBy([categories.id])
      ..orderBy([OrderingTerm.desc(sumAmount)]);

    final results = await query.get();
    return results.map((row) {
      return CategoryStatistics(
        categoryId: row.read(categories.id)!,
        categoryName: row.read(categories.name)!,
        iconKey: row.read(categories.iconKey)!,
        color: row.read(categories.color)!,
        type: CategoryType.values[row.read(categories.type)!],
        total: row.read(sumAmount) ?? 0.0,
        transactionCount: row.read(countTx) ?? 0,
      );
    }).toList();
  }

  /// Calcule les statistiques mensuelles pour une année
  /// Utilise idx_transactions_date
  Future<List<MonthlyStatistics>> getMonthlyStatistics(int year) async {
    // Drift stocke les DateTime en secondes depuis epoch
    // On utilise datetime() pour convertir avant strftime
    final query = customSelect(
      '''
      SELECT
        strftime('%Y', datetime(t.date, 'unixepoch')) as year,
        strftime('%m', datetime(t.date, 'unixepoch')) as month,
        SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END) as total_income,
        SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END) as total_expense
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE strftime('%Y', datetime(t.date, 'unixepoch')) = ?
      GROUP BY strftime('%Y-%m', datetime(t.date, 'unixepoch'))
      ORDER BY month ASC
      ''',
      variables: [
        Variable.withInt(CategoryType.income.index),
        Variable.withInt(CategoryType.expense.index),
        Variable.withString(year.toString()),
      ],
      readsFrom: {transactions, categories},
    );

    final results = await query.get();
    return results.map((row) {
      final totalIncome = row.read<double?>('total_income') ?? 0.0;
      final totalExpense = row.read<double?>('total_expense') ?? 0.0;
      return MonthlyStatistics(
        year: int.parse(row.read<String>('year')),
        month: int.parse(row.read<String>('month')),
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
      );
    }).toList();
  }

  /// Stream des statistiques mensuelles
  Stream<List<MonthlyStatistics>> watchMonthlyStatistics(int year) {
    final query = customSelect(
      '''
      SELECT
        strftime('%Y', datetime(t.date, 'unixepoch')) as year,
        strftime('%m', datetime(t.date, 'unixepoch')) as month,
        SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END) as total_income,
        SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END) as total_expense
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE strftime('%Y', datetime(t.date, 'unixepoch')) = ?
      GROUP BY strftime('%Y-%m', datetime(t.date, 'unixepoch'))
      ORDER BY month ASC
      ''',
      variables: [
        Variable.withInt(CategoryType.income.index),
        Variable.withInt(CategoryType.expense.index),
        Variable.withString(year.toString()),
      ],
      readsFrom: {transactions, categories},
    );

    return query.watch().map((results) {
      return results.map((row) {
        final totalIncome = row.read<double?>('total_income') ?? 0.0;
        final totalExpense = row.read<double?>('total_expense') ?? 0.0;
        return MonthlyStatistics(
          year: int.parse(row.read<String>('year')),
          month: int.parse(row.read<String>('month')),
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          balance: totalIncome - totalExpense,
        );
      }).toList();
    });
  }

  /// Calcule le solde réel d'un compte (solde initial + somme des transactions)
  /// Utilise idx_transactions_account_id
  Future<double> calculateAccountBalance(String accountId) async {
    // Récupère le solde initial
    final account = await (select(accounts)
          ..where((t) => t.id.equals(accountId)))
        .getSingleOrNull();

    if (account == null) return 0.0;

    // Calcule la somme des transactions avec CASE WHEN pour income/expense
    final query = customSelect(
      '''
      SELECT
        SUM(CASE WHEN c.type = ? THEN t.amount ELSE -t.amount END) as net
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE t.account_id = ?
      ''',
      variables: [
        Variable.withInt(CategoryType.income.index),
        Variable.withString(accountId),
      ],
      readsFrom: {transactions, categories},
    );

    final result = await query.getSingleOrNull();
    final netTransactions = result?.read<double?>('net') ?? 0.0;

    return account.balance + netTransactions;
  }

  /// Stream du solde calculé d'un compte
  Stream<double> watchAccountBalance(String accountId) {
    final query = customSelect(
      '''
      SELECT
        a.balance as initial_balance,
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE -t.amount END), 0) as net
      FROM accounts a
      LEFT JOIN transactions t ON t.account_id = a.id
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE a.id = ?
      GROUP BY a.id
      ''',
      variables: [
        Variable.withInt(CategoryType.income.index),
        Variable.withString(accountId),
      ],
      readsFrom: {accounts, transactions, categories},
    );

    return query.watchSingle().map((row) {
      final initial = row.read<double?>('initial_balance') ?? 0.0;
      final net = row.read<double?>('net') ?? 0.0;
      return initial + net;
    });
  }

  /// Calcule le résumé financier global
  Future<FinancialSummary> getFinancialSummary() async {
    // Solde total de tous les comptes (requête séparée pour éviter la multiplication)
    final accountsBalanceQuery = customSelect(
      'SELECT COALESCE(SUM(balance), 0) as total FROM accounts',
      readsFrom: {accounts},
    );

    // Net des transactions (income - expense)
    final transactionsNetQuery = customSelect(
      '''
      SELECT
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE -t.amount END), 0) as net
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      ''',
      variables: [Variable.withInt(CategoryType.income.index)],
      readsFrom: {transactions, categories},
    );

    // Totaux all-time
    final allTimeQuery = customSelect(
      '''
      SELECT
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END), 0) as total_income,
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END), 0) as total_expense
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      ''',
      variables: [
        Variable.withInt(CategoryType.income.index),
        Variable.withInt(CategoryType.expense.index),
      ],
      readsFrom: {transactions, categories},
    );

    // Totaux du mois en cours
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthlyQuery = customSelect(
      '''
      SELECT
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END), 0) as monthly_income,
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END), 0) as monthly_expense
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      WHERE t.date BETWEEN ? AND ?
      ''',
      variables: [
        Variable.withInt(CategoryType.income.index),
        Variable.withInt(CategoryType.expense.index),
        Variable.withDateTime(startOfMonth),
        Variable.withDateTime(endOfMonth),
      ],
      readsFrom: {transactions, categories},
    );

    final accountsResult = await accountsBalanceQuery.getSingle();
    final netResult = await transactionsNetQuery.getSingle();
    final allTimeResult = await allTimeQuery.getSingle();
    final monthlyResult = await monthlyQuery.getSingle();

    final accountsBalance = accountsResult.read<double?>('total') ?? 0.0;
    final transactionsNet = netResult.read<double?>('net') ?? 0.0;

    return FinancialSummary(
      totalBalance: accountsBalance + transactionsNet,
      totalIncome: allTimeResult.read<double?>('total_income') ?? 0.0,
      totalExpense: allTimeResult.read<double?>('total_expense') ?? 0.0,
      monthlyIncome: monthlyResult.read<double?>('monthly_income') ?? 0.0,
      monthlyExpense: monthlyResult.read<double?>('monthly_expense') ?? 0.0,
    );
  }

  /// Stream du résumé financier (se met à jour automatiquement)
  Stream<FinancialSummary> watchFinancialSummary() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final query = customSelect(
      '''
      SELECT
        (SELECT COALESCE(SUM(balance), 0) FROM accounts) as accounts_balance,
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE -t.amount END), 0) as transactions_net,
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END), 0) as total_income,
        COALESCE(SUM(CASE WHEN c.type = ? THEN t.amount ELSE 0 END), 0) as total_expense,
        COALESCE(SUM(CASE WHEN c.type = ? AND t.date BETWEEN ? AND ? THEN t.amount ELSE 0 END), 0) as monthly_income,
        COALESCE(SUM(CASE WHEN c.type = ? AND t.date BETWEEN ? AND ? THEN t.amount ELSE 0 END), 0) as monthly_expense
      FROM transactions t
      INNER JOIN categories c ON t.category_id = c.id
      ''',
      variables: [
        Variable.withInt(CategoryType.income.index),
        Variable.withInt(CategoryType.income.index),
        Variable.withInt(CategoryType.expense.index),
        Variable.withInt(CategoryType.income.index),
        Variable.withDateTime(startOfMonth),
        Variable.withDateTime(endOfMonth),
        Variable.withInt(CategoryType.expense.index),
        Variable.withDateTime(startOfMonth),
        Variable.withDateTime(endOfMonth),
      ],
      readsFrom: {accounts, transactions, categories},
    );

    return query.watchSingle().map((row) {
      final accountsBalance = row.read<double?>('accounts_balance') ?? 0.0;
      final transactionsNet = row.read<double?>('transactions_net') ?? 0.0;
      return FinancialSummary(
        totalBalance: accountsBalance + transactionsNet,
        totalIncome: row.read<double?>('total_income') ?? 0.0,
        totalExpense: row.read<double?>('total_expense') ?? 0.0,
        monthlyIncome: row.read<double?>('monthly_income') ?? 0.0,
        monthlyExpense: row.read<double?>('monthly_expense') ?? 0.0,
      );
    });
  }

  /// Vérifie si le budget d'une catégorie est dépassé pour le mois en cours
  Future<double> getCategorySpendingThisMonth(String categoryId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final sumAmount = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([sumAmount])
      ..where(transactions.categoryId.equals(categoryId) &
          transactions.date.isBetweenValues(startOfMonth, endOfMonth));

    final result = await query.getSingle();
    return result.read(sumAmount) ?? 0.0;
  }

  /// Stream des dépenses d'une catégorie ce mois
  Stream<double> watchCategorySpendingThisMonth(String categoryId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final sumAmount = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([sumAmount])
      ..where(transactions.categoryId.equals(categoryId) &
          transactions.date.isBetweenValues(startOfMonth, endOfMonth));

    return query.watchSingle().map((result) => result.read(sumAmount) ?? 0.0);
  }
}
