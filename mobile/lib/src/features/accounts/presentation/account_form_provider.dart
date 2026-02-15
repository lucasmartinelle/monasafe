import 'package:monasafe/src/core/services/invalidation_service.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/accounts/presentation/account_form_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_form_provider.g.dart';

/// Provider pour le formulaire de création de compte.
@riverpod
class AccountFormNotifier extends _$AccountFormNotifier {
  @override
  AccountFormState build() {
    return const AccountFormState();
  }

  /// Réinitialise le formulaire et pré-sélectionne le type disponible.
  Future<void> reset() async {
    state = const AccountFormState();

    // Récupère les comptes existants pour déterminer le type disponible
    final accountsAsync = ref.read(accountsStreamProvider);
    final accounts = accountsAsync.valueOrNull ?? [];

    final existingTypes = accounts.map((a) => a.type).toSet();

    // Pré-sélectionne le premier type non créé (checking > savings)
    if (!existingTypes.contains(AccountType.checking)) {
      state = state.copyWith(selectedType: AccountType.checking);
    } else if (!existingTypes.contains(AccountType.savings)) {
      state = state.copyWith(selectedType: AccountType.savings);
    }
  }

  /// Définit le type de compte.
  void setType(AccountType type) {
    state = state.copyWith(selectedType: type, clearError: true);
  }

  /// Ajoute un chiffre au montant.
  void appendDigit(String digit) {
    // Limite à 10 chiffres (99 999 999,99 €)
    if (state.amountInCents.toString().length >= 10) return;

    final newAmount = state.amountInCents * 10 + int.parse(digit);
    state = state.copyWith(amountInCents: newAmount, clearError: true);
  }

  /// Supprime le dernier chiffre.
  void deleteDigit() {
    final newAmount = state.amountInCents ~/ 10;
    state = state.copyWith(amountInCents: newAmount, clearError: true);
  }

  /// Efface le montant.
  void clearAmount() {
    state = state.copyWith(amountInCents: 0, clearError: true);
  }

  /// Crée le compte.
  Future<bool> create() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Veuillez sélectionner un type de compte');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repository = ref.read(accountRepositoryProvider);
      final type = state.selectedType!;

      final result = await repository.createAccount(
        name: getAccountTypeName(type),
        type: type,
        initialBalance: state.amount,
        currency: 'EUR',
        color: getAccountTypeColor(type),
      );

      return result.fold(
        (error) {
          state = state.copyWith(isSubmitting: false, error: error.message);
          return false;
        },
        (account) {
          state = state.copyWith(isSubmitting: false);
          InvalidationService.onAccountCreated(ref);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Erreur lors de la création du compte',
      );
      return false;
    }
  }
}

/// Retourne le nom du compte selon son type.
String getAccountTypeName(AccountType type) {
  return switch (type) {
    AccountType.checking => 'Compte courant',
    AccountType.savings => 'Compte épargne',
    AccountType.cash => 'Espèces',
  };
}

/// Retourne une couleur pour le type de compte.
int getAccountTypeColor(AccountType type) {
  return switch (type) {
    AccountType.checking => 0xFF6366F1, // Indigo
    AccountType.savings => 0xFF10B981, // Green
    AccountType.cash => 0xFFF59E0B, // Amber
  };
}
