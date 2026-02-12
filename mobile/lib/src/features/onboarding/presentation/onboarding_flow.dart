import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/features/onboarding/presentation/onboarding_controller.dart';
import 'package:monasafe/src/features/onboarding/presentation/screens/auth_choice_screen.dart';
import 'package:monasafe/src/features/onboarding/presentation/screens/setup_account_screen.dart';
import 'package:monasafe/src/features/onboarding/presentation/screens/welcome_screen.dart';

/// Widget principal qui gère le flow d'onboarding
class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({
    required this.onComplete, super.key,
  });

  /// Callback appelé quand l'onboarding est terminé
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _ProgressIndicator(currentStep: state.currentStep),
            ),
            // Contenu
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(int step) {
    return switch (step) {
      0 => const WelcomeScreen(key: ValueKey('welcome')),
      1 => const SetupAccountScreen(key: ValueKey('setup')),
      2 => AuthChoiceScreen(key: const ValueKey('auth'), onComplete: onComplete),
      _ => const WelcomeScreen(key: ValueKey('welcome')),
    };
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return Row(
      children: List.generate(3, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isCompleted || isCurrent ? AppColors.primary : dividerColor,
            ),
          ),
        );
      }),
    );
  }
}
