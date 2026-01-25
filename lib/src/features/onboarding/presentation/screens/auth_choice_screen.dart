import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/common_widgets.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/features/onboarding/presentation/onboarding_controller.dart';

/// Écran 3 : Auth Choice
/// Choix entre Google Auth ou Local Only
class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({
    required this.onComplete, super.key,
  });

  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Icône
                  const IconContainer(
                    icon: Icons.security,
                    color: AppColors.primary,
                    size: IconContainerSize.extraLarge,
                    shape: IconContainerShape.circle,
                  ),
                  const SizedBox(height: 24),
                  // Titre
                  Text(
                    'How would you like\nto continue?',
                    style: AppTextStyles.h2(color: textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred method',
                    style: AppTextStyles.bodySmall(color: textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  const SizedBox(height: 24),
                  // Option 1: Google (Simplicité)
                  _AuthOptionCard(
                    icon: Icons.cloud_outlined,
                    iconColor: Colors.blue,
                    title: 'Simplicity',
                    subtitle: 'Sync across devices',
                    buttonLabel: 'Continue with Google',
                    buttonIcon: Icons.g_mobiledata,
                    buttonColor: AppColors.process,
                    isLoading: state.isLoading,
                    onPressed: () async {
                      final success = await controller.completeWithGoogle();
                      if (success && context.mounted) {
                        onComplete();
                      }
                    },
                    features: const [
                      'Automatic backup',
                      'Sync across all devices',
                      'Recover your data anytime',
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Séparateur
                  Row(
                    children: [
                      Expanded(child: Divider(color: dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: AppTextStyles.bodySmall(color: textSecondary),
                        ),
                      ),
                      Expanded(child: Divider(color: dividerColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Option 2: Local Only (Privé)
                  _AuthOptionCard(
                    icon: Icons.smartphone,
                    iconColor: AppColors.primary,
                    title: 'Privacy',
                    subtitle: 'Data stays on your device',
                    buttonLabel: 'Start Local Only',
                    buttonIcon: Icons.lock_outline,
                    buttonVariant: AppButtonVariant.secondary,
                    isLoading: state.isLoading,
                    onPressed: () async {
                      final success = await controller.completeLocalOnly();
                      if (success && context.mounted) {
                        onComplete();
                      }
                    },
                    features: const [
                      'Complete privacy',
                      'No account needed',
                      'Works offline',
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 24),
                  // Bouton retour
                  AppButton(
                    label: 'Back',
                    variant: AppButtonVariant.ghost,
                    icon: Icons.arrow_back,
                    onPressed: state.isLoading ? null : controller.previousStep,
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

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
          // Features
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
                    style: AppTextStyles.bodySmall(color: textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bouton
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
      // Bouton custom avec couleur spécifique
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
