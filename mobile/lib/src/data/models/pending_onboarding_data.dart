/// Données d'onboarding en attente de complétion après OAuth
class PendingOnboardingData {
  const PendingOnboardingData({
    required this.currency,
    this.wantsCheckingAccount = true,
    this.checkingBalanceCents = 0,
    this.wantsSavingsAccount = false,
    this.savingsBalanceCents = 0,
  });

  factory PendingOnboardingData.fromJson(Map<String, dynamic> json) {
    return PendingOnboardingData(
      currency: json['currency'] as String,
      wantsCheckingAccount: json['wantsCheckingAccount'] as bool? ?? true,
      checkingBalanceCents: json['checkingBalanceCents'] as int? ?? 0,
      wantsSavingsAccount: json['wantsSavingsAccount'] as bool? ?? false,
      savingsBalanceCents: json['savingsBalanceCents'] as int? ?? 0,
    );
  }

  final String currency;
  final bool wantsCheckingAccount;
  final int checkingBalanceCents;
  final bool wantsSavingsAccount;
  final int savingsBalanceCents;

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'wantsCheckingAccount': wantsCheckingAccount,
        'checkingBalanceCents': checkingBalanceCents,
        'wantsSavingsAccount': wantsSavingsAccount,
        'savingsBalanceCents': savingsBalanceCents,
      };
}
