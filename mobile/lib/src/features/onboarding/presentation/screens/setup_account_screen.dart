import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/onboarding/presentation/onboarding_controller.dart';

/// Écran 2 : Setup Account
/// Input pour le solde initial + Toggle Checking/Savings
class SetupAccountScreen extends ConsumerStatefulWidget {
  const SetupAccountScreen({super.key});

  @override
  ConsumerState<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends ConsumerState<SetupAccountScreen> {
  final _balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialise avec la valeur actuelle si elle existe
    final state = ref.read(onboardingControllerProvider);
    if (state.initialBalance > 0) {
      _balanceController.text = state.initialBalance.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  String get _currencySymbol {
    final currency = ref.read(onboardingControllerProvider).currency;
    return switch (currency) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      'CHF' => 'Fr',
      _ => '€',
    };
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 32),
                  // Icône
                  const IconContainer(
                    icon: Icons.account_balance,
                    color: AppColors.primary,
                    size: IconContainerSize.extraLarge,
                    shape: IconContainerShape.circle,
                  ),
                  const SizedBox(height: 24),
                  // Titre
                  Text(
                    'Quel est votre solde\nactuel ?',
                    style: AppTextStyles.h2(color: context.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sélectionnez votre premier compte et saisissez son solde. Pas d’inquiétude : vous pourrez ajouter un second compte par la suite !',
                    style: AppTextStyles.bodySmall(color: context.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  const SizedBox(height: 24),
                  // Input du solde
                  GlassCard(
                    child: Column(
                      children: [
                        // Champ de saisie du montant
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _currencySymbol,
                              style: AppTextStyles.h2(color: context.textHint),
                            ),
                            const SizedBox(width: 8),
                            IntrinsicWidth(
                              child: TextField(
                                controller: _balanceController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h1(color: context.textPrimary),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: AppTextStyles.h1(color: context.textHint),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  final balance = double.tryParse(value) ?? 0;
                                  controller.setInitialBalance(balance);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(color: context.dividerColor),
                        const SizedBox(height: 16),
                        // Toggle Checking / Savings
                        Row(
                          children: [
                            Expanded(
                              child: _AccountTypeOption(
                                icon: Icons.account_balance_wallet,
                                label: 'Courant',
                                subtitle: 'Dépenses quotidiennes',
                                isSelected: state.accountType == AccountType.checking,
                                onTap: () =>
                                    controller.setAccountType(AccountType.checking),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AccountTypeOption(
                                icon: Icons.savings,
                                label: 'Épargne',
                                subtitle: 'Objectifs long terme',
                                isSelected: state.accountType == AccountType.savings,
                                onTap: () =>
                                    controller.setAccountType(AccountType.savings),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 24),
                  // Boutons navigation
                  Row(
                    children: [
                      AppButton(
                        label: 'Retour',
                        variant: AppButtonVariant.ghost,
                        icon: Icons.arrow_back,
                        onPressed: controller.previousStep,
                      ),
                      const Spacer(),
                      AppButton(
                        label: 'Continuer',
                        icon: Icons.arrow_forward,
                        iconPosition: IconPosition.right,
                        onPressed: controller.nextStep,
                      ),
                    ],
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

class _AccountTypeOption extends StatelessWidget {
  const _AccountTypeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SelectableOptionContainer(
      isSelected: isSelected,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : context.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelMedium(
              color: isSelected ? AppColors.primary : context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
