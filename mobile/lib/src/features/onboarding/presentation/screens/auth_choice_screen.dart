import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/features/onboarding/presentation/onboarding_controller.dart';

/// Écran 1 : Auth Choice (premier écran de l'onboarding)
/// Choix entre Google Auth ou Local Only
class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  const IconContainer(
                    icon: Icons.account_balance_wallet,
                    color: Colors.white,
                    backgroundColor: AppColors.primary,
                    size: IconContainerSize.extraLarge,
                    customSize: 80,
                    customIconSize: 40,
                    customBorderRadius: 20,
                  ),
                  const SizedBox(height: 32),
                  // Titre
                  Text(
                    'Bienvenue sur Monasafe.',
                    style: AppTextStyles.h2(color: context.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre argent, vos données.\nSimple, sécurisé et entièrement vôtre.',
                    style: AppTextStyles.bodySmall(color: context.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Option 1: Google
                  _AuthOptionCard(
                    icon: Icons.cloud_outlined,
                    iconColor: Colors.blue,
                    title: 'Simplicité',
                    subtitle: 'Synchronisation multi-appareils',
                    buttonLabel: 'Continuer avec Google',
                    buttonIcon: Icons.g_mobiledata,
                    buttonColor: AppColors.process,
                    isLoading: state.isLoading,
                    onPressed: () async {
                      await controller.completeWithGoogle();
                    },
                    features: const [
                      'Sauvegarde automatique',
                      'Synchronisation multi-appareils',
                      'Récupérez vos données à tout moment',
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Séparateur
                  Row(
                    children: [
                      Expanded(child: Divider(color: context.dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: AppTextStyles.bodySmall(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: context.dividerColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Option 2: Local
                  _AuthOptionCard(
                    icon: Icons.smartphone,
                    iconColor: AppColors.primary,
                    title: 'Confidentialité',
                    subtitle: 'Données sur votre appareil uniquement',
                    buttonLabel: 'Commencer en local',
                    buttonIcon: Icons.lock_outline,
                    buttonVariant: AppButtonVariant.secondary,
                    isLoading: state.isLoading,
                    onPressed: () async {
                      await controller.completeLocalOnly();
                    },
                    features: const [
                      'Confidentialité totale',
                      'Aucun compte requis',
                      'Fonctionne hors ligne',
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuthOptionCard extends StatelessWidget {
  const _AuthOptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    required this.features,
    this.buttonIcon,
    this.buttonColor,
    this.buttonVariant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData? buttonIcon;
  final Color? buttonColor;
  final AppButtonVariant buttonVariant;
  final bool isLoading;
  final VoidCallback onPressed;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconLabelTile(
            iconWidget: IconContainer(
              icon: icon,
              color: iconColor,
              customSize: 44,
              customBorderRadius: 12,
            ),
            label: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: AppTextStyles.bodySmall(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    if (buttonVariant == AppButtonVariant.primary && buttonColor != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(buttonIcon, size: 20),
        label: Text(buttonLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return AppButton(
      label: buttonLabel,
      variant: buttonVariant,
      icon: buttonIcon,
      isLoading: isLoading,
      fullWidth: true,
      onPressed: onPressed,
    );
  }
}
