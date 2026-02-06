import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/common_widgets.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/core/theme/theme_helper.dart';
import 'package:simpleflow/src/features/onboarding/presentation/onboarding_controller.dart';

/// Écran 1 : Welcome
/// Titre + Sélecteur de devise
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Logo / Illustration
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
            'Bienvenue sur SimpleFlow.',
            style: AppTextStyles.h2(color: context.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Votre argent, vos données. Simple, sécurisé et entièrement vôtre.',
            style: AppTextStyles.bodyMedium(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // Sélecteur de devise
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisissez votre devise',
                  style: AppTextStyles.labelMedium(color: context.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _CurrencyOption(
                      currency: 'USD',
                      symbol: r'$',
                      isSelected: state.currency == 'USD',
                      onTap: () => controller.setCurrency('USD'),
                    ),
                    const SizedBox(width: 12),
                    _CurrencyOption(
                      currency: 'EUR',
                      symbol: '€',
                      isSelected: state.currency == 'EUR',
                      onTap: () => controller.setCurrency('EUR'),
                    ),
                    const SizedBox(width: 12),
                    _CurrencyOption(
                      currency: 'GBP',
                      symbol: '£',
                      isSelected: state.currency == 'GBP',
                      onTap: () => controller.setCurrency('GBP'),
                    ),
                    const SizedBox(width: 12),
                    _CurrencyOption(
                      currency: 'CHF',
                      symbol: 'Fr',
                      isSelected: state.currency == 'CHF',
                      onTap: () => controller.setCurrency('CHF'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Bouton Continue
          AppButton(
            label: 'Continuer',
            fullWidth: true,
            icon: Icons.arrow_forward,
            iconPosition: IconPosition.right,
            onPressed: controller.nextStep,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  const _CurrencyOption({
    required this.currency,
    required this.symbol,
    required this.isSelected,
    required this.onTap,
  });

  final String currency;
  final String symbol;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SelectableOptionContainer(
        isSelected: isSelected,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              symbol,
              style: AppTextStyles.h3(
                color: isSelected ? AppColors.primary : context.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currency,
              style: AppTextStyles.caption(
                color: isSelected ? AppColors.primary : context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
