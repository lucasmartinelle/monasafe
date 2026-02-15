import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/widgets/question_page_layout.dart';

/// Page de question de compte (courant ou épargne).
/// Utilise le NumericKeypad custom au lieu du clavier système.
class AccountQuestionPage extends StatefulWidget {
  const AccountQuestionPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.wantsAccount,
    required this.balanceCents,
    required this.currency,
    required this.onWantsChanged,
    required this.onBalanceChanged,
    required this.onNext,
    this.isLastPage = false,
    this.isLoading = false,
    this.canSkip = true,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool wantsAccount;
  final int balanceCents;
  final String currency;
  final ValueChanged<bool> onWantsChanged;
  final ValueChanged<int> onBalanceChanged;
  final VoidCallback onNext;
  final bool isLastPage;
  final bool isLoading;
  final bool canSkip;

  @override
  State<AccountQuestionPage> createState() => _AccountQuestionPageState();
}

class _AccountQuestionPageState extends State<AccountQuestionPage> {
  bool _hasAnswered = false;
  int _cents = 0;

  @override
  void initState() {
    super.initState();
    _cents = widget.balanceCents;
    _hasAnswered = widget.wantsAccount;
  }

  String get _currencySymbol =>
      CurrencyFormatter.getSymbol(widget.currency);

  String get _formattedAmount {
    final euros = _cents ~/ 100;
    final centsPart = (_cents % 100).toString().padLeft(2, '0');
    return '$euros,$centsPart';
  }

  void _selectOption(bool wants) {
    widget.onWantsChanged(wants);
    if (!wants) {
      _cents = 0;
      widget.onBalanceChanged(0);
    }
    setState(() => _hasAnswered = true);
  }

  void _appendDigit(String digit) {
    if (_cents >= 10000000) return;
    setState(() {
      _cents = _cents * 10 + int.parse(digit);
    });
    widget.onBalanceChanged(_cents);
  }

  void _deleteDigit() {
    setState(() {
      _cents = _cents ~/ 10;
    });
    widget.onBalanceChanged(_cents);
  }

  void _clearAmount() {
    setState(() {
      _cents = 0;
    });
    widget.onBalanceChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    if (_hasAnswered && widget.wantsAccount) {
      return _AccountAmountLayout(
        icon: widget.icon,
        title: widget.title,
        currencySymbol: _currencySymbol,
        formattedAmount: _formattedAmount,
        onAppendDigit: _appendDigit,
        onDelete: _deleteDigit,
        onClear: _clearAmount,
        onBack: () => _selectOption(false),
        onNext: widget.onNext,
        buttonLabel: widget.isLastPage ? 'Terminer' : 'Suivant',
        isLoading: widget.isLoading,
      );
    }

    return QuestionPageLayout(
      icon: widget.icon,
      title: widget.title,
      subtitle: widget.subtitle,
      onNext: widget.onNext,
      buttonLabel: widget.isLastPage ? 'Terminer' : 'Suivant',
      isLoading: widget.isLoading,
      showButton: _hasAnswered && !widget.wantsAccount,
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _ChoiceCard(
                    icon: Icons.check_circle_outline,
                    label: 'Oui',
                    isSelected: _hasAnswered && widget.wantsAccount,
                    selectedColor: AppColors.primary,
                    isDark: isDark,
                    onTap: () => _selectOption(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChoiceCard(
                    icon: Icons.cancel_outlined,
                    label: 'Non merci',
                    isSelected: _hasAnswered && !widget.wantsAccount,
                    selectedColor: context.textSecondary,
                    isDark: isDark,
                    onTap: () => _selectOption(false),
                  ),
                ),
              ],
            ),
          ),
          if (widget.isLastPage &&
              !widget.canSkip &&
              _hasAnswered &&
              !widget.wantsAccount)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Vous devez créer au moins un compte pour continuer.',
                style: AppTextStyles.bodySmall(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountAmountLayout extends StatefulWidget {
  const _AccountAmountLayout({
    required this.icon,
    required this.title,
    required this.currencySymbol,
    required this.formattedAmount,
    required this.onAppendDigit,
    required this.onDelete,
    required this.onClear,
    required this.onBack,
    required this.onNext,
    required this.buttonLabel,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String currencySymbol;
  final String formattedAmount;
  final ValueChanged<String> onAppendDigit;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String buttonLabel;
  final bool isLoading;

  @override
  State<_AccountAmountLayout> createState() => _AccountAmountLayoutState();
}

class _AccountAmountLayoutState extends State<_AccountAmountLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                IconContainer(
                  icon: widget.icon,
                  color: AppColors.primary,
                  shape: IconContainerShape.circle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Solde initial',
                    style: AppTextStyles.h4(color: context.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onBack,
                  child: Text(
                    'Annuler',
                    style: AppTextStyles.bodySmall(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0)
                        .animate(animation),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey(widget.formattedAmount),
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.formattedAmount,
                    style: AppTextStyles.h1(
                      color: context.textPrimary,
                    ).copyWith(fontSize: 48),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.currencySymbol,
                    style: AppTextStyles.h2(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            NumericKeypad(
              onDigit: widget.onAppendDigit,
              onDelete: widget.onDelete,
              onClear: widget.onClear,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: widget.buttonLabel,
              fullWidth: true,
              icon: widget.isLoading ? null : Icons.arrow_forward,
              iconPosition: IconPosition.right,
              isLoading: widget.isLoading,
              onPressed: widget.onNext,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.12)
              : isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : context.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium(
                color: isSelected ? selectedColor : context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
