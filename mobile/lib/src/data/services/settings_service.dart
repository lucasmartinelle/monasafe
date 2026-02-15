import 'package:supabase_flutter/supabase_flutter.dart';

/// Service Supabase pour la gestion des paramètres utilisateur
class SettingsService {
  SettingsService(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  /// Récupère une valeur par sa clé
  Future<String?> getValue(String key) async {
    final response = await _client
        .from('user_settings')
        .select('value')
        .eq('user_id', _userId)
        .eq('key', key)
        .maybeSingle();

    return response?['value'] as String?;
  }

  /// Stream d'une valeur
  Stream<String?> watchValue(String key) {
    return _client
        .from('user_settings')
        .stream(primaryKey: ['user_id', 'key'])
        .eq('user_id', _userId)
        .map((data) {
          final setting = data.where((s) => s['key'] == key).firstOrNull;
          return setting?['value'] as String?;
        });
  }

  /// Définit une valeur
  Future<void> setValue(String key, String value) async {
    await _client.from('user_settings').upsert({
      'user_id': _userId,
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Récupère une valeur booléenne
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final value = await getValue(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Stream d'une valeur booléenne
  Stream<bool> watchBool(String key, {bool defaultValue = false}) {
    return watchValue(key).map((value) {
      if (value == null) return defaultValue;
      return value.toLowerCase() == 'true';
    });
  }

  /// Définit une valeur booléenne
  Future<void> setBool(String key, {required bool value}) async {
    await setValue(key, value.toString());
  }

  /// Supprime une valeur
  Future<void> deleteValue(String key) async {
    await _client
        .from('user_settings')
        .delete()
        .eq('user_id', _userId)
        .eq('key', key);
  }

  /// Récupère toutes les valeurs
  Future<Map<String, String>> getAllValues() async {
    final response = await _client
        .from('user_settings')
        .select()
        .eq('user_id', _userId);

    final result = <String, String>{};
    for (final row in response as List) {
      final map = row as Map<String, dynamic>;
      result[map['key'] as String] = map['value'] as String;
    }
    return result;
  }

  /// Vérifie si une clé existe
  Future<bool> hasKey(String key) async {
    final response = await _client
        .from('user_settings')
        .select('key')
        .eq('user_id', _userId)
        .eq('key', key)
        .maybeSingle();

    return response != null;
  }
}
