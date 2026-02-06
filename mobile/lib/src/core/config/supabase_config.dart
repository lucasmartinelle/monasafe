import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration Supabase chargée depuis le fichier .env
abstract class SupabaseConfig {
  /// URL du projet Supabase
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  /// Clé publique anonyme (anon key)
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Secret key (bypass RLS) - utilisée UNIQUEMENT pour le seeding en dev
  static String get secretKey => dotenv.env['SUPABASE_SECRET_KEY'] ?? '';

  /// Vérifie si la secret key est configurée
  static bool get hasSecretKey => secretKey.isNotEmpty;
}
