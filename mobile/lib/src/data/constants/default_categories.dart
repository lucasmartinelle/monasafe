import 'package:monasafe/src/data/models/enums.dart';

/// Représentation d'une catégorie par défaut à injecter dans le compte
/// d'un utilisateur lors de l'inscription ou de la migration.
class DefaultCategorySeed {
  const DefaultCategorySeed({
    required this.name,
    required this.iconKey,
    required this.color,
    required this.type,
  });

  final String name;
  final String iconKey;
  final int color;
  final CategoryType type;
}

/// Set minimal de catégories injectées dans le compte de l'utilisateur
/// à l'inscription. L'utilisateur en devient propriétaire et peut les
/// renommer, modifier ou supprimer librement.
///
/// Source de vérité partagée avec `web/utils/defaultCategories.ts` :
/// toute modification doit être répercutée des deux côtés pour rester
/// cohérent.
const List<DefaultCategorySeed> kDefaultCategories = [
  // Dépenses
  DefaultCategorySeed(name: 'Alimentation', iconKey: 'shopping-cart', color: 0xFFE87B4D, type: CategoryType.expense),
  DefaultCategorySeed(name: 'Logement', iconKey: 'home', color: 0xFF1B5E5A, type: CategoryType.expense),
  DefaultCategorySeed(name: 'Transport', iconKey: 'car', color: 0xFF2196F3, type: CategoryType.expense),
  DefaultCategorySeed(name: 'Loisirs', iconKey: 'gamepad-2', color: 0xFF9C27B0, type: CategoryType.expense),
  DefaultCategorySeed(name: 'Santé', iconKey: 'heart-pulse', color: 0xFFF44336, type: CategoryType.expense),
  DefaultCategorySeed(name: 'Autres dépenses', iconKey: 'ellipsis', color: 0xFF607D8B, type: CategoryType.expense),

  // Revenus
  DefaultCategorySeed(name: 'Salaire', iconKey: 'wallet', color: 0xFF4CAF50, type: CategoryType.income),
  DefaultCategorySeed(name: 'Autres revenus', iconKey: 'arrow-up-circle', color: 0xFF00BCD4, type: CategoryType.income),
];
