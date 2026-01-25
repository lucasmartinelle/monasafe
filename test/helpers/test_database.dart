import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:simpleflow/src/data/data.dart';

/// Crée une base de données en mémoire pour les tests
///
/// Chaque appel crée une nouvelle instance isolée
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(
    NativeDatabase.memory(),
  );
}

/// Helper pour créer un compte de test
AccountsCompanion createTestAccount({
  String id = 'test-account-1',
  String name = 'Compte Test',
  int type = 0, // checking
  double balance = 1000.0,
  String currency = 'EUR',
  int color = 0xFF4CAF50,
}) {
  return AccountsCompanion.insert(
    id: id,
    name: name,
    type: const AccountTypeConverter().fromSql(type),
    balance: Value(balance),
    currency: currency,
    color: color,
  );
}

/// Helper pour créer une transaction de test
TransactionsCompanion createTestTransaction({
  String id = 'test-transaction-1',
  String accountId = 'test-account-1',
  String categoryId = 'cat_food',
  double amount = 50.0,
  DateTime? date,
  String? note,
  bool isRecurring = false,
  int syncStatus = 0, // pending
}) {
  return TransactionsCompanion.insert(
    id: id,
    accountId: accountId,
    categoryId: categoryId,
    amount: amount,
    date: date ?? DateTime.now(),
    note: Value(note),
    isRecurring: Value(isRecurring),
    syncStatus: Value(const SyncStatusConverter().fromSql(syncStatus)),
  );
}
