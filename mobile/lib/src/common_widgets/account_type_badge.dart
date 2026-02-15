import 'package:flutter/material.dart';

import 'package:monasafe/src/data/models/models.dart';

/// TODO : À réfacto pour respecter DDD

/// Retourne l'icône pour un type de compte.
IconData getAccountTypeIcon(AccountType type) {
  return switch (type) {
    AccountType.checking => Icons.account_balance,
    AccountType.savings => Icons.savings,
    AccountType.cash => Icons.payments,
  };
}

/// Retourne le label français pour un type de compte.
String getAccountTypeLabel(AccountType type) {
  return switch (type) {
    AccountType.checking => 'Courant',
    AccountType.savings => 'Épargne',
    AccountType.cash => 'Espèces',
  };
}
