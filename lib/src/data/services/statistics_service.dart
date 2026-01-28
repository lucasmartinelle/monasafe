import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:simpleflow/src/data/models/models.dart';

/// Service Supabase pour les statistiques et agrégations
class StatisticsService {
  StatisticsService(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Calcule le total par catégorie sur une période
  Future<List<CategoryStatistics>> getTotalByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _client.rpc(
      'get_total_by_category',
      params: {
        'p_user_id': _userId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
      },
    );

    return (response as List).map((json) {
      final map = json as Map<String, dynamic>;
      return CategoryStatistics(
        categoryId: map['category_id'] as String,
        categoryName: map['category_name'] as String,
        iconKey: map['icon_key'] as String,
        color: map['color'] as int,
        type: CategoryType.fromString(map['type'] as String),
        total: (map['total'] as num).toDouble(),
        transactionCount: map['transaction_count'] as int,
      );
    }).toList();
  }

  /// Stream du total par catégorie
  Stream<List<CategoryStatistics>> watchTotalByCategory(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .asyncMap((_) => getTotalByCategory(startDate, endDate));
  }

  /// Calcule les totaux par catégorie pour un type spécifique
  Future<List<CategoryStatistics>> getTotalByCategoryAndType(
    DateTime startDate,
    DateTime endDate,
    CategoryType type,
  ) async {
    final response = await _client.rpc(
      'get_total_by_category_and_type',
      params: {
        'p_user_id': _userId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
        'p_type': type.name,
      },
    );

    return (response as List).map((json) {
      final map = json as Map<String, dynamic>;
      return CategoryStatistics(
        categoryId: map['category_id'] as String,
        categoryName: map['category_name'] as String,
        iconKey: map['icon_key'] as String,
        color: map['color'] as int,
        type: CategoryType.fromString(map['type'] as String),
        total: (map['total'] as num).toDouble(),
        transactionCount: map['transaction_count'] as int,
      );
    }).toList();
  }

  /// Calcule les statistiques mensuelles pour une année
  Future<List<MonthlyStatistics>> getMonthlyStatistics(int year) async {
    final response = await _client.rpc(
      'get_monthly_statistics',
      params: {
        'p_user_id': _userId,
        'p_year': year,
      },
    );

    return (response as List).map((json) {
      final map = json as Map<String, dynamic>;
      final totalIncome = (map['total_income'] as num).toDouble();
      final totalExpense = (map['total_expense'] as num).toDouble();
      return MonthlyStatistics(
        year: map['year'] as int,
        month: map['month'] as int,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
      );
    }).toList();
  }

  /// Stream des statistiques mensuelles
  Stream<List<MonthlyStatistics>> watchMonthlyStatistics(int year) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .asyncMap((_) => getMonthlyStatistics(year));
  }

  /// Calcule les statistiques journalières pour un mois donné
  Future<List<DailyStatistics>> getDailyStatistics(int year, int month) async {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final response = await _client
        .from('transactions')
        .select('date, amount, categories!inner(type)')
        .eq('user_id', _userId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String());

    // Grouper par jour
    final dailyMap = <int, ({double income, double expense})>{};

    for (final row in response as List) {
      final map = row as Map<String, dynamic>;
      final date = DateTime.parse(map['date'] as String);
      final amount = (map['amount'] as num).toDouble();
      final categoryType = (map['categories'] as Map<String, dynamic>)['type'] as String;
      final isIncome = categoryType == 'income';

      final day = date.day;
      final existing = dailyMap[day] ?? (income: 0.0, expense: 0.0);

      dailyMap[day] = (
        income: existing.income + (isIncome ? amount : 0),
        expense: existing.expense + (isIncome ? 0 : amount),
      );
    }

    // Convertir en liste de DailyStatistics
    return dailyMap.entries.map((entry) {
      return DailyStatistics(
        date: DateTime(year, month, entry.key),
        totalIncome: entry.value.income,
        totalExpense: entry.value.expense,
      );
    }).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
  }

  /// Stream des statistiques journalières pour un mois
  Stream<List<DailyStatistics>> watchDailyStatistics(int year, int month) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .asyncMap((_) => getDailyStatistics(year, month));
  }

  /// Calcule le solde réel d'un compte (solde initial + somme des transactions)
  Future<double> calculateAccountBalance(String accountId) async {
    final response = await _client.rpc(
      'calculate_account_balance',
      params: {
        'p_account_id': accountId,
      },
    );

    return (response as num?)?.toDouble() ?? 0.0;
  }

  /// Stream du solde calculé d'un compte
  Stream<double> watchAccountBalance(String accountId) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('account_id', accountId)
        .asyncMap((_) => calculateAccountBalance(accountId));
  }

  /// Calcule le résumé financier global
  Future<FinancialSummary> getFinancialSummary() async {
    final response = await _client.rpc(
      'get_financial_summary',
      params: {
        'p_user_id': _userId,
      },
    );

    if (response == null || (response as List).isEmpty) {
      return const FinancialSummary.empty();
    }

    final map = response[0] as Map<String, dynamic>;
    return FinancialSummary(
      totalBalance: (map['total_balance'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (map['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (map['total_expense'] as num?)?.toDouble() ?? 0.0,
      monthlyIncome: (map['monthly_income'] as num?)?.toDouble() ?? 0.0,
      monthlyExpense: (map['monthly_expense'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Stream du résumé financier
  Stream<FinancialSummary> watchFinancialSummary() {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .asyncMap((_) => getFinancialSummary());
  }

  /// Récupère les dépenses d'une catégorie ce mois
  Future<double> getCategorySpendingThisMonth(String categoryId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final response = await _client
        .from('transactions')
        .select('amount')
        .eq('user_id', _userId)
        .eq('category_id', categoryId)
        .gte('date', startOfMonth.toIso8601String())
        .lte('date', endOfMonth.toIso8601String());

    double total = 0;
    for (final row in response as List) {
      total += ((row as Map<String, dynamic>)['amount'] as num).toDouble();
    }
    return total;
  }

  /// Stream des dépenses d'une catégorie ce mois
  Stream<double> watchCategorySpendingThisMonth(String categoryId) {
    return _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('category_id', categoryId)
        .asyncMap((_) => getCategorySpendingThisMonth(categoryId));
  }
}
