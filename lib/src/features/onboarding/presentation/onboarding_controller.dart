import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';

part 'onboarding_controller.g.dart';

/// État de l'onboarding
class OnboardingState {
  const OnboardingState({
    this.currentStep = 0,
    this.currency = 'EUR',
    this.initialBalance = 0,
    this.accountType = AccountType.checking,
    this.isLoading = false,
    this.error,
  });

  final int currentStep;
  final String currency;
  final double initialBalance;
  final AccountType accountType;
  final bool isLoading;
  final String? error;

  OnboardingState copyWith({
    int? currentStep,
    String? currency,
    double? initialBalance,
    AccountType? accountType,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      accountType: accountType ?? this.accountType,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Contrôleur pour le flow d'onboarding
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  /// Passe à l'étape suivante
  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Revient à l'étape précédente
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Définit la devise
  void setCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  /// Définit le solde initial
  void setInitialBalance(double balance) {
    state = state.copyWith(initialBalance: balance);
  }

  /// Définit le type de compte
  void setAccountType(AccountType type) {
    state = state.copyWith(accountType: type);
  }

  /// Complète l'onboarding avec Google Auth
  Future<bool> completeWithGoogle() async {
    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);

      // Connexion avec Google
      await authService.signInWithGoogle();

      // Attendre que l'authentification soit complète
      // Note: La redirection OAuth gère le reste du flow
      // L'utilisateur sera redirigé et le state sera mis à jour

      await _createAccountAndComplete(isAnonymous: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Complète l'onboarding en mode local only (avec compte Supabase anonyme)
  Future<bool> completeLocalOnly() async {
    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);

      // Crée un compte anonyme Supabase
      await authService.signInAnonymously();

      await _createAccountAndComplete(isAnonymous: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Crée le compte et marque l'onboarding comme complété
  Future<void> _createAccountAndComplete({required bool isAnonymous}) async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final accountRepo = ref.read(accountRepositoryProvider);

    // Sauvegarde la devise
    await settingsRepo.setCurrency(state.currency);

    // Sauvegarde le mode anonyme
    await settingsRepo.setIsAnonymous(isAnonymous);

    // Crée le compte principal
    final accountName = state.accountType == AccountType.checking
        ? 'Compte courant'
        : 'Compte épargne';

    final result = await accountRepo.createAccount(
      name: accountName,
      type: state.accountType,
      initialBalance: state.initialBalance,
      currency: state.currency,
      color: 0xFF1B5E5A, // Primary color
    );

    await result.fold(
      (error) => throw Exception(error.message),
      (account) async {
        // Définit ce compte comme compte principal
        await settingsRepo.setPrimaryAccountId(account.id);
      },
    );

    // Marque l'onboarding comme complété
    await settingsRepo.setOnboardingCompleted();

    state = state.copyWith(isLoading: false);
  }
}
