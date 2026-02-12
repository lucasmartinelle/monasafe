import 'package:monasafe/src/data/models/enums.dart';

/// Données d'onboarding en attente de complétion après OAuth
class PendingOnboardingData {
  const PendingOnboardingData({
    required this.currency,
    required this.initialBalance,
    required this.accountType,
  });

  factory PendingOnboardingData.fromJson(Map<String, dynamic> json) {
    return PendingOnboardingData(
      currency: json['currency'] as String,
      initialBalance: (json['initialBalance'] as num).toDouble(),
      accountType: AccountType.values.firstWhere(
        (e) => e.name == json['accountType'],
        orElse: () => AccountType.checking,
      ),
    );
  }

  final String currency;
  final double initialBalance;
  final AccountType accountType;

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'initialBalance': initialBalance,
        'accountType': accountType.name,
      };
}
