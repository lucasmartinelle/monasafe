import 'package:drift/drift.dart';

import 'package:simpleflow/src/data/local/database.dart';
import 'package:simpleflow/src/data/local/tables/user_settings_table.dart';

part 'user_settings_dao.g.dart';

/// DAO pour la gestion des paramètres utilisateur
@DriftAccessor(tables: [UserSettings])
class UserSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$UserSettingsDaoMixin {
  UserSettingsDao(super.db);

  /// Récupère une valeur par sa clé
  Future<String?> getValue(String key) async {
    final query = select(userSettings)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  /// Définit une valeur pour une clé
  Future<void> setValue(String key, String value) async {
    await into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Supprime une valeur
  Future<void> deleteValue(String key) async {
    await (delete(userSettings)..where((t) => t.key.equals(key))).go();
  }

  /// Récupère toutes les valeurs
  Future<Map<String, String>> getAllValues() async {
    final results = await select(userSettings).get();
    return {for (final r in results) r.key: r.value};
  }

  /// Stream d'une valeur spécifique
  Stream<String?> watchValue(String key) {
    final query = select(userSettings)..where((t) => t.key.equals(key));
    return query.watchSingleOrNull().map((r) => r?.value);
  }

  /// Vérifie si une clé existe
  Future<bool> hasKey(String key) async {
    final result = await getValue(key);
    return result != null;
  }

  // ==================== HELPERS TYPÉS ====================

  /// Récupère un booléen
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final value = await getValue(key);
    if (value == null) return defaultValue;
    return value == 'true';
  }

  /// Définit un booléen
  Future<void> setBool(String key, bool value) async {
    await setValue(key, value.toString());
  }

  /// Stream d'un booléen
  Stream<bool> watchBool(String key, {bool defaultValue = false}) {
    return watchValue(key).map((v) => v == 'true' || defaultValue);
  }
}
