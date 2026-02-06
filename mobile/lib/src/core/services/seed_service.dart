import 'package:flutter/foundation.dart';
import 'package:simpleflow/src/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Service pour injecter les données par défaut dans Supabase
class SeedService {
  SeedService();

  static const _uuid = Uuid();

  /// Crée un client admin avec la secret key (bypass RLS)
  SupabaseClient? _createAdminClient() {
    if (!SupabaseConfig.hasSecretKey) {
      debugPrint('SeedService: Secret key non configurée, seeding ignoré');
      return null;
    }

    return SupabaseClient(
      SupabaseConfig.url,
      SupabaseConfig.secretKey,
    );
  }

  /// Catégories par défaut à injecter
  static final List<Map<String, dynamic>> _defaultCategories = [
    // Catégories de dépenses
    {
      'name': 'Alimentation',
      'icon_key': 'food',
      'color': 0xFFFF6B6B,
      'type': 'expense',
    },
    {
      'name': 'Transport',
      'icon_key': 'transport',
      'color': 0xFF4ECDC4,
      'type': 'expense',
    },
    {
      'name': 'Shopping',
      'icon_key': 'shopping',
      'color': 0xFFFFBE0B,
      'type': 'expense',
    },
    {
      'name': 'Loisirs',
      'icon_key': 'entertainment',
      'color': 0xFFFF006E,
      'type': 'expense',
    },
    {
      'name': 'Santé',
      'icon_key': 'health',
      'color': 0xFF8338EC,
      'type': 'expense',
    },
    {
      'name': 'Factures',
      'icon_key': 'bills',
      'color': 0xFF3A86FF,
      'type': 'expense',
    },
    {
      'name': 'Autres dépenses',
      'icon_key': 'other',
      'color': 0xFF6C757D,
      'type': 'expense',
    },
    // Catégories de revenus
    {
      'name': 'Salaire',
      'icon_key': 'salary',
      'color': 0xFF06D6A0,
      'type': 'income',
    },
    {
      'name': 'Freelance',
      'icon_key': 'freelance',
      'color': 0xFF118AB2,
      'type': 'income',
    },
    {
      'name': 'Investissements',
      'icon_key': 'investment',
      'color': 0xFF073B4C,
      'type': 'income',
    },
    {
      'name': 'Cadeaux',
      'icon_key': 'gift',
      'color': 0xFFEF476F,
      'type': 'income',
    },
    {
      'name': 'Autres revenus',
      'icon_key': 'other',
      'color': 0xFF6C757D,
      'type': 'income',
    },
  ];

  /// Vérifie et injecte les catégories par défaut si absentes
  Future<void> seedDefaultCategories() async {
    final adminClient = _createAdminClient();
    if (adminClient == null) return;

    try {
      // Vérifier si des catégories par défaut existent
      final existingDefaults = await adminClient
          .from('categories')
          .select('id')
          .eq('is_default', true)
          .limit(1);

      if ((existingDefaults as List).isNotEmpty) {
        debugPrint('SeedService: Les catégories par défaut existent déjà');
        return;
      }

      debugPrint('SeedService: Injection des catégories par défaut...');

      final now = DateTime.now().toIso8601String();
      final categoriesToInsert = _defaultCategories.map((category) {
        return {
          'id': _uuid.v4(),
          'user_id': null,
          'name': category['name'],
          'icon_key': category['icon_key'],
          'color': category['color'],
          'type': category['type'],
          'budget_limit': null,
          'is_default': true,
          'created_at': now,
          'updated_at': now,
        };
      }).toList();

      await adminClient.from('categories').insert(categoriesToInsert);

      debugPrint(
        'SeedService: ${categoriesToInsert.length} catégories par défaut insérées',
      );
    } catch (e) {
      debugPrint('SeedService: Erreur lors du seeding - $e');
      // Ne pas propager l'erreur pour ne pas bloquer le démarrage
    }
  }

  /// Exécute tous les seeds nécessaires
  Future<void> runAllSeeds() async {
    await seedDefaultCategories();
  }
}
