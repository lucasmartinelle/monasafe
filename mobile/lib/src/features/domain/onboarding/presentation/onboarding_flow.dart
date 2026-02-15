import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/onboarding_controller.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/screens/auth_choice_screen.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/screens/completion_screen.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/screens/questions_flow.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget principal qui gère le flow d'onboarding
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({
    required this.onComplete,
    super.key,
  });

  /// Callback appelé quand l'onboarding est terminé
  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _isProcessingAuth = false;

  @override
  void initState() {
    super.initState();
    // Vérifier au démarrage si déjà authentifié (app relancée après OAuth)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAuthIfNeeded();
    });
    // Écouter les changements d'auth (retour OAuth pendant que l'app tourne)
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToAuthChanges() {
    final authService = ref.read(authServiceProvider);
    _authSubscription = authService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn &&
          authState.session?.user != null) {
        debugPrint('[OnboardingFlow] Auth signedIn detected');
        _handleAuthIfNeeded();
      }
    });
  }

  /// Vérifie si l'utilisateur est authentifié Google et gère la suite
  Future<void> _handleAuthIfNeeded() async {
    if (_isProcessingAuth || !mounted) return;

    final authService = ref.read(authServiceProvider);
    final state = ref.read(onboardingControllerProvider);

    // Seulement si on est sur l'écran auth (step 0) et que l'user est connecté Google
    if (state.currentStep != 0) return;
    if (!authService.isAuthenticated || authService.isAnonymous) return;

    _isProcessingAuth = true;

    try {
      final controller = ref.read(onboardingControllerProvider.notifier);
      final completed = await controller.completePendingGoogleOnboarding();

      if (completed && mounted) {
        // Utilisateur existant avec comptes → aller au dashboard
        widget.onComplete();
      }
      // Sinon, le controller a navigué vers step 1 (questions)
    } finally {
      _isProcessingAuth = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          child: _buildCurrentScreen(state.currentStep),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(int step) {
    return switch (step) {
      0 => const AuthChoiceScreen(key: ValueKey('auth')),
      1 => const QuestionsFlow(key: ValueKey('questions')),
      2 => CompletionScreen(
          key: const ValueKey('completion'),
          onComplete: widget.onComplete,
        ),
      _ => const AuthChoiceScreen(key: ValueKey('auth')),
    };
  }
}
