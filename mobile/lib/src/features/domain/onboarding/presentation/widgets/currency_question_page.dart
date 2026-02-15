import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/onboarding_controller.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/widgets/question_page_layout.dart';

/// Page de sélection de la devise.
class CurrencyQuestionPage extends ConsumerWidget {
  const CurrencyQuestionPage({
    required this.selectedCurrency,
    required this.onNext,
    super.key,
  });

  final String selectedCurrency;
  final VoidCallback onNext;

  static const _currencies = [
    ('USD', r'$'),
    ('EUR', '€'),
    ('GBP', '£'),
    ('CHF', 'Fr'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final isDark = context.isDark;

    return QuestionPageLayout(
      icon: Icons.currency_exchange,
      title: 'Quelle est votre devise ?',
      subtitle: 'Vous pourrez la modifier plus tard dans les paramètres',
      onNext: onNext,
      buttonLabel: 'Suivant',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: _currencies.map((entry) {
            final (code, symbol) = entry;
            final isSelected = selectedCurrency == code;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: code != 'CHF' ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.setCurrency(code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          symbol,
                          style: AppTextStyles.h3(
                            color: isSelected
                                ? AppColors.primary
                                : context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          code,
                          style: AppTextStyles.caption(
                            color: isSelected
                                ? AppColors.primary
                                : context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
