import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/daos/account_dao.dart';
import 'package:simpleflow/src/data/local/daos/category_dao.dart';
import 'package:simpleflow/src/data/local/daos/statistics_dao.dart';
import 'package:simpleflow/src/data/local/daos/transaction_dao.dart';
import 'package:simpleflow/src/data/local/daos/user_settings_dao.dart';
import 'package:simpleflow/src/data/local/tables/accounts_table.dart';
import 'package:simpleflow/src/data/local/tables/categories_table.dart';
import 'package:simpleflow/src/data/local/tables/transactions_table.dart';
import 'package:simpleflow/src/data/local/tables/user_settings_table.dart';

part 'database.g.dart';

/// Base de données locale SQLite via Drift
///
/// Architecture Local-First : cette base est la source de vérité immédiate.
/// La synchronisation avec Supabase se fait en arrière-plan.
@DriftDatabase(
  tables: [Accounts, Categories, Transactions, UserSettings],
  daos: [AccountDao, CategoryDao, TransactionDao, StatisticsDao, UserSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur pour les tests avec une connexion personnalisée
  AppDatabase.forTesting(super.e);

  /// Version du schéma de la base de données
  /// Incrémenter lors des migrations
  @override
  int get schemaVersion => 1;

  /// Stratégie de migration pour les mises à jour de schéma
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insertion des catégories par défaut
        await _seedDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Futures migrations ici
      },
      beforeOpen: (details) async {
        // Active les clés étrangères (désactivées par défaut dans SQLite)
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Insère les catégories par défaut lors de la création de la base
  Future<void> _seedDefaultCategories() async {
    final defaultCategories = [
      // Dépenses
      CategoriesCompanion.insert(
        id: 'cat_food',
        name: 'Alimentation',
        iconKey: 'food',
        color: 0xFFFF6B6B,
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        id: 'cat_transport',
        name: 'Transport',
        iconKey: 'transport',
        color: 0xFF4ECDC4,
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        id: 'cat_shopping',
        name: 'Shopping',
        iconKey: 'shopping',
        color: 0xFFFFE66D,
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        id: 'cat_entertainment',
        name: 'Loisirs',
        iconKey: 'entertainment',
        color: 0xFF95E1D3,
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        id: 'cat_health',
        name: 'Santé',
        iconKey: 'health',
        color: 0xFFF38181,
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        id: 'cat_bills',
        name: 'Factures',
        iconKey: 'bills',
        color: 0xFFAA96DA,
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        id: 'cat_other_expense',
        name: 'Autres dépenses',
        iconKey: 'other',
        color: 0xFFA8A8A8,
        type: CategoryType.expense,
      ),
      // Revenus
      CategoriesCompanion.insert(
        id: 'cat_salary',
        name: 'Salaire',
        iconKey: 'salary',
        color: 0xFF6BCB77,
        type: CategoryType.income,
      ),
      CategoriesCompanion.insert(
        id: 'cat_freelance',
        name: 'Freelance',
        iconKey: 'freelance',
        color: 0xFF4D96FF,
        type: CategoryType.income,
      ),
      CategoriesCompanion.insert(
        id: 'cat_investment',
        name: 'Investissements',
        iconKey: 'investment',
        color: 0xFFFFD93D,
        type: CategoryType.income,
      ),
      CategoriesCompanion.insert(
        id: 'cat_gift',
        name: 'Cadeaux',
        iconKey: 'gift',
        color: 0xFFFF6B6B,
        type: CategoryType.income,
      ),
      CategoriesCompanion.insert(
        id: 'cat_other_income',
        name: 'Autres revenus',
        iconKey: 'other',
        color: 0xFFA8A8A8,
        type: CategoryType.income,
      ),
    ];

    await batch((batch) {
      batch.insertAll(categories, defaultCategories);
    });
  }
}

/// Ouvre la connexion à la base de données SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Utilise le dossier 'databases' standard pour la compatibilité avec App Inspection
    final dbFolder = await getApplicationDocumentsDirectory();
    final databasesFolder = Directory(p.join(dbFolder.parent.path, 'databases'));
    if (!await databasesFolder.exists()) {
      await databasesFolder.create(recursive: true);
    }
    final file = File(p.join(databasesFolder.path, 'simpleflow.db'));
    // TODO: Remettre createInBackground() en production pour de meilleures performances
return NativeDatabase(file);
  });
}
