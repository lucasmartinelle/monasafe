import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:simpleflow/src/data/models/models.dart';

/// Service pour gérer les données d'onboarding en attente
/// pendant le flux OAuth (qui peut tuer/relancer l'app).
class PendingOnboardingService {
  PendingOnboardingService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'pending_onboarding_data';

  final FlutterSecureStorage _storage;

  /// Sauvegarde les données d'onboarding avant de lancer OAuth
  Future<void> savePendingData(PendingOnboardingData data) async {
    await _storage.write(key: _key, value: jsonEncode(data.toJson()));
  }

  /// Récupère les données d'onboarding en attente
  Future<PendingOnboardingData?> getPendingData() async {
    final json = await _storage.read(key: _key);
    if (json == null) return null;
    return PendingOnboardingData.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  /// Vérifie s'il y a des données en attente
  Future<bool> hasPendingData() async {
    return await _storage.read(key: _key) != null;
  }

  /// Supprime les données en attente (après complétion)
  Future<void> clearPendingData() async {
    await _storage.delete(key: _key);
  }
}
