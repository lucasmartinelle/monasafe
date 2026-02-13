import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// État de l'onboarding
class OnboardingState {
  const OnboardingState({
    this.currentStep = 0,
    this.currency = 'EUR',
    this.wantsCheckingAccount = false,
    this.checkingBalanceCents = 0,
    this.wantsSavingsAccount = false,
    this.savingsBalanceCents = 0,
    this.isLoading = false,
    this.error,
  });

  /// 0 = auth choice, 1 = questions flow, 2 = completion
  final int currentStep;
  final String currency;
  final bool wantsCheckingAccount;
  final int checkingBalanceCents;
  final bool wantsSavingsAccount;
  final int savingsBalanceCents;
  final bool isLoading;
  final String? error;

  double get checkingBalanceAmount => checkingBalanceCents / 100;
  double get savingsBalanceAmount => savingsBalanceCents / 100;

  /// Vérifie qu'au moins un compte sera créé
  bool get hasAtLeastOneAccount =>
      wantsCheckingAccount || wantsSavingsAccount;

  OnboardingState copyWith({
    int? currentStep,
    String? currency,
    bool? wantsCheckingAccount,
    int? checkingBalanceCents,
    bool? wantsSavingsAccount,
    int? savingsBalanceCents,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      currency: currency ?? this.currency,
      wantsCheckingAccount:
          wantsCheckingAccount ?? this.wantsCheckingAccount,
      checkingBalanceCents:
          checkingBalanceCents ?? this.checkingBalanceCents,
      wantsSavingsAccount:
          wantsSavingsAccount ?? this.wantsSavingsAccount,
      savingsBalanceCents:
          savingsBalanceCents ?? this.savingsBalanceCents,
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

  /// Va directement à un step donné
  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  /// Définit la devise
  void setCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  /// Active/désactive le compte courant
  void setWantsCheckingAccount(bool wants) {
    state = state.copyWith(
      wantsCheckingAccount: wants,
      checkingBalanceCents: wants ? state.checkingBalanceCents : 0,
    );
  }

  /// Définit le solde initial du compte courant (en centimes)
  void setCheckingBalanceCents(int cents) {
    state = state.copyWith(checkingBalanceCents: cents);
  }

  /// Active/désactive le compte épargne
  void setWantsSavingsAccount(bool wants) {
    state = state.copyWith(
      wantsSavingsAccount: wants,
      savingsBalanceCents: wants ? state.savingsBalanceCents : 0,
    );
  }

  /// Définit le solde initial du compte épargne (en centimes)
  void setSavingsBalanceCents(int cents) {
    state = state.copyWith(savingsBalanceCents: cents);
  }

  /// Lance l'authentification Google (OAuth)
  /// Après OAuth, l'app reviendra et OnboardingFlow détectera l'auth.
  Future<bool> completeWithGoogle() async {
    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);

      // Déconnecter l'utilisateur actuel (anonyme ou autre)
      if (authService.isAuthenticated) {
        await authService.signOut();
      }

      // Lancer OAuth (ouvre le navigateur)
      await authService.signInWithGoogle();

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Crée un compte anonyme et passe aux questions
  Future<bool> completeLocalOnly() async {
    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);

      // Crée un compte anonyme Supabase
      await authService.signInAnonymously();

      // Passe aux questions
      state = state.copyWith(isLoading: false, currentStep: 1);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Complète l'onboarding après le callback OAuth.
  /// Si l'utilisateur a déjà des comptes (reconnexion), on skip tout.
  Future<bool> completePendingGoogleOnboarding() async {
    state = state.copyWith(isLoading: true);

    try {
      final accountRepo = ref.read(accountRepositoryProvider);

      // Vérifier si l'utilisateur a déjà des comptes (reconnexion)
      final accountsResult = await accountRepo.getAllAccounts();
      final hasExistingAccounts = accountsResult.fold(
        (_) => false,
        (accounts) => accounts.isNotEmpty,
      );

      if (hasExistingAccounts) {
        // Utilisateur existant : skip la création, juste marquer complété
        final settingsRepo = ref.read(settingsRepositoryProvider);
        await settingsRepo.setOnboardingCompleted();
        state = state.copyWith(isLoading: false);
        return true; // onboarding terminé, aller au dashboard
      } else {
        // Nouvel utilisateur Google : passer aux questions
        state = state.copyWith(isLoading: false, currentStep: 1);
        return false; // pas encore terminé, montrer les questions
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Crée les comptes et marque l'onboarding comme complété
  Future<bool> completeOnboarding() async {
    if (!state.hasAtLeastOneAccount) {
      state = state.copyWith(error: 'Vous devez créer au moins un compte.');
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final accountRepo = ref.read(accountRepositoryProvider);
      final authService = ref.read(authServiceProvider);

      // Sauvegarde la devise
      await settingsRepo.setCurrency(state.currency);

      // Sauvegarde le mode anonyme
      await settingsRepo.setIsAnonymous(authService.isAnonymous);

      String? primaryAccountId;

      // Créer le compte courant si souhaité
      if (state.wantsCheckingAccount) {
        final result = await accountRepo.createAccount(
          name: 'Compte courant',
          type: AccountType.checking,
          initialBalance: state.checkingBalanceAmount,
          currency: state.currency,
          color: 0xFF1B5E5A,
        );

        await result.fold(
          (error) => throw Exception(error.message),
          (account) async {
            primaryAccountId = account.id;
          },
        );
      }

      // Créer le compte épargne si souhaité
      if (state.wantsSavingsAccount) {
        final result = await accountRepo.createAccount(
          name: 'Compte épargne',
          type: AccountType.savings,
          initialBalance: state.savingsBalanceAmount,
          currency: state.currency,
          color: 0xFF4CAF50,
        );

        await result.fold(
          (error) => throw Exception(error.message),
          (account) async {
            // Si pas de compte courant, le compte épargne est le principal
            primaryAccountId ??= account.id;
          },
        );
      }

      // Définit le compte principal
      if (primaryAccountId != null) {
        await settingsRepo.setPrimaryAccountId(primaryAccountId!);
      }

      // Marque l'onboarding comme complété
      await settingsRepo.setOnboardingCompleted();

      // Passe à l'écran de completion
      state = state.copyWith(isLoading: false, currentStep: 2);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
