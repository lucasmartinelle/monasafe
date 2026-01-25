import 'package:flutter/material.dart';

/// Maps iconKey strings to Flutter IconData.
///
/// Used to convert category iconKey values stored in the database
/// to Material Icons for display in the UI.
abstract final class IconMapper {
  /// Default icon when key is not found
  static const IconData defaultIcon = Icons.help_outline;

  /// Maps iconKey strings to their corresponding IconData
  static const Map<String, IconData> _iconMap = {
    // Expense categories
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'shopping': Icons.shopping_bag,
    'entertainment': Icons.movie,
    'health': Icons.local_hospital,
    'bills': Icons.receipt_long,
    'other': Icons.more_horiz,

    // Income categories
    'salary': Icons.work,
    'freelance': Icons.laptop_mac,
    'investment': Icons.trending_up,
    'gift': Icons.card_giftcard,

    // Account types
    'checking': Icons.account_balance,
    'savings': Icons.savings,
    'cash': Icons.payments,

    // Additional common icons
    'home': Icons.home,
    'education': Icons.school,
    'travel': Icons.flight,
    'subscription': Icons.subscriptions,
    'insurance': Icons.security,
    'pets': Icons.pets,
    'clothing': Icons.checkroom,
    'utilities': Icons.bolt,
    'phone': Icons.phone_android,
    'internet': Icons.wifi,
    'gym': Icons.fitness_center,
    'coffee': Icons.coffee,
    'groceries': Icons.local_grocery_store,
    'restaurant': Icons.restaurant_menu,
    'bar': Icons.local_bar,
    'taxi': Icons.local_taxi,
    'bus': Icons.directions_bus,
    'train': Icons.train,
    'parking': Icons.local_parking,
    'gas': Icons.local_gas_station,
    'maintenance': Icons.build,
    'beauty': Icons.spa,
    'books': Icons.menu_book,
    'music': Icons.music_note,
    'games': Icons.sports_esports,
    'sports': Icons.sports_soccer,
    'charity': Icons.volunteer_activism,
    'tax': Icons.account_balance_wallet,
    'bonus': Icons.star,
    'refund': Icons.replay,
    'dividend': Icons.pie_chart,
    'rental': Icons.apartment,
  };

  /// Gets the IconData for the given iconKey.
  ///
  /// Returns [defaultIcon] if the key is not found.
  static IconData getIcon(String? iconKey) {
    if (iconKey == null || iconKey.isEmpty) {
      return defaultIcon;
    }
    return _iconMap[iconKey.toLowerCase()] ?? defaultIcon;
  }

  /// Checks if an iconKey has a corresponding icon mapping.
  static bool hasIcon(String iconKey) {
    return _iconMap.containsKey(iconKey.toLowerCase());
  }

  /// Gets all available icon keys.
  static List<String> get availableKeys => _iconMap.keys.toList();

  /// Gets all available icons as a map.
  static Map<String, IconData> get allIcons => Map.unmodifiable(_iconMap);
}
