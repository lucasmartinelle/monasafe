import 'package:monasafe/src/data/models/models.dart';

/// État du formulaire de création de compte.
class AccountFormState {
  const AccountFormState({
    this.selectedType,
    this.amountInCents = 0,
    this.isSubmitting = false,
    this.error,
  });

  /// Type de compte sélectionné (null = pas encore choisi).
  final AccountType? selectedType;

  /// Montant initial en centimes.
  final int amountInCents;

  /// Indique si le formulaire est en cours de soumission.
  final bool isSubmitting;

  /// Message d'erreur éventuel.
  final String? error;

  /// Montant en euros.
  double get amount => amountInCents / 100;

  /// Montant formaté pour l'affichage.
  String get displayAmount {
    final euros = amountInCents ~/ 100;
    final cents = amountInCents % 100;
    return '$euros,${cents.toString().padLeft(2, '0')}';
  }

  /// Le formulaire est valide si un type est sélectionné.
  bool get isValid => selectedType != null;

  /// Crée une copie avec des valeurs modifiées.
  AccountFormState copyWith({
    AccountType? selectedType,
    int? amountInCents,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool clearType = false,
  }) {
    return AccountFormState(
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      amountInCents: amountInCents ?? this.amountInCents,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
