import 'package:meta/meta.dart';

/// Modèle représentant un paramètre utilisateur (clé-valeur)
@immutable
class UserSetting {
  const UserSetting({
    required this.userId,
    required this.key,
    required this.value,
    required this.updatedAt,
  });

  /// Crée un UserSetting depuis une Map JSON (Supabase)
  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
      userId: json['user_id'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String userId;
  final String key;
  final String value;
  final DateTime updatedAt;

  /// Convertit en Map JSON pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'key': key,
      'value': value,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Clés prédéfinies pour les paramètres utilisateur
abstract final class SettingsKeys {
  /// Onboarding complété (bool)
  static const String onboardingCompleted = 'onboarding_completed';

  /// Devise de l'utilisateur (String: EUR, USD, GBP)
  static const String currency = 'currency';

  /// Mode anonyme / local only (bool)
  static const String isAnonymous = 'is_anonymous';

  /// ID du compte principal (String)
  static const String primaryAccountId = 'primary_account_id';
}
