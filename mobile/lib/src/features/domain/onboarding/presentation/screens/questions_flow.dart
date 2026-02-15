import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/onboarding_controller.dart';

/// Flow de questions en PageView vertical
/// Q1: Devise, Q2: Compte courant, Q3: Compte épargne
class QuestionsFlow extends ConsumerStatefulWidget {
  const QuestionsFlow({super.key});

  @override
  ConsumerState<QuestionsFlow> createState() => _QuestionsFlowState();
}

class _QuestionsFlowState extends ConsumerState<QuestionsFlow> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage += 1);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final controller = ref.read(onboardingControllerProvider.notifier);
    await controller.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);

    return Column(
      children: [
        // Indicateur de progression
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _QuestionsProgressIndicator(
            currentPage: _currentPage,
            totalPages: 3,
          ),
        ),
        // Pages de questions
        Expanded(
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _CurrencyQuestionPage(
                selectedCurrency: state.currency,
                onNext: _goToNextPage,
              ),
              _AccountQuestionPage(
                title: 'Souhaitez-vous ajouter\nun compte courant ?',
                subtitle: 'Pour gérer vos dépenses quotidiennes',
                icon: Icons.account_balance_wallet,
                wantsAccount: state.wantsCheckingAccount,
                balanceCents: state.checkingBalanceCents,
                currency: state.currency,
                onWantsChanged: (wants) => ref
                    .read(onboardingControllerProvider.notifier)
                    .setWantsCheckingAccount(wants: wants),
                onBalanceChanged: (cents) => ref
                    .read(onboardingControllerProvider.notifier)
                    .setCheckingBalanceCents(cents),
                onNext: _goToNextPage,
              ),
              _AccountQuestionPage(
                title: 'Et un compte épargne ?',
                subtitle: 'Pour vos objectifs long terme',
                icon: Icons.savings,
                wantsAccount: state.wantsSavingsAccount,
                balanceCents: state.savingsBalanceCents,
                currency: state.currency,
                onWantsChanged: (wants) => ref
                    .read(onboardingControllerProvider.notifier)
                    .setWantsSavingsAccount(wants: wants),
                onBalanceChanged: (cents) => ref
                    .read(onboardingControllerProvider.notifier)
                    .setSavingsBalanceCents(cents),
                onNext: _goToNextPage,
                isLastPage: true,
                isLoading: state.isLoading,
                canSkip: state.wantsCheckingAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Indicateur de progression pour les questions
class _QuestionsProgressIndicator extends StatelessWidget {
  const _QuestionsProgressIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index <= currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(right: index < totalPages - 1 ? 8 : 0),
          height: 4,
          width: index == currentPage ? 32 : 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isActive ? AppColors.primary : context.dividerColor,
          ),
        );
      }),
    );
  }
}

/// Page 1 : Sélection de la devise
class _CurrencyQuestionPage extends ConsumerWidget {
  const _CurrencyQuestionPage({
    required this.selectedCurrency,
    required this.onNext,
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

    return _QuestionPageLayout(
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

/// Page 2 & 3 : Question de compte (courant ou épargne)
/// Utilise le NumericKeypad custom au lieu du clavier système
class _AccountQuestionPage extends StatefulWidget {
  const _AccountQuestionPage({
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
  State<_AccountQuestionPage> createState() => _AccountQuestionPageState();
}

class _AccountQuestionPageState extends State<_AccountQuestionPage> {
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
    // Limite à 999 999,99 (99999999 centimes)
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

    // Si "Oui" est sélectionné, on affiche le montant + keypad
    // sans le layout standard (qui utilise Spacer/scroll)
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

    // Sinon, layout standard avec Oui/Non
    return _QuestionPageLayout(
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
          // Message de validation si dernière page et aucun compte
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

/// Layout dédié pour la saisie du montant avec NumericKeypad
/// Occupe tout l'écran : montant en haut, keypad en bas
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
            // Header compact : icône + titre
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
                // Bouton retour pour changer d'avis
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
            // Affichage du montant
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
            // NumericKeypad
            NumericKeypad(
              onDigit: widget.onAppendDigit,
              onDelete: widget.onDelete,
              onClear: widget.onClear,
            ),
            const SizedBox(height: 16),
            // Bouton Suivant
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

/// Carte de choix Oui/Non avec bordure et relief
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

/// Layout commun pour les pages de questions (devise + choix oui/non)
class _QuestionPageLayout extends StatefulWidget {
  const _QuestionPageLayout({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    required this.buttonLabel,
    this.isLoading = false,
    this.showButton = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNext;
  final String buttonLabel;
  final bool isLoading;
  final bool showButton;

  @override
  State<_QuestionPageLayout> createState() => _QuestionPageLayoutState();
}

class _QuestionPageLayoutState extends State<_QuestionPageLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
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
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Icône
              IconContainer(
                icon: widget.icon,
                color: AppColors.primary,
                size: IconContainerSize.extraLarge,
                shape: IconContainerShape.circle,
              ),
              const SizedBox(height: 24),
              // Titre
              Text(
                widget.title,
                style: AppTextStyles.h2(
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: AppTextStyles.bodySmall(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Contenu de la question
              widget.child,
              const Spacer(),
              // Bouton Suivant
              AnimatedOpacity(
                opacity: widget.showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSlide(
                  offset: widget.showButton
                      ? Offset.zero
                      : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: AppButton(
                    label: widget.buttonLabel,
                    fullWidth: true,
                    icon:
                        widget.isLoading ? null : Icons.arrow_forward,
                    iconPosition: IconPosition.right,
                    isLoading: widget.isLoading,
                    onPressed:
                        widget.showButton ? widget.onNext : null,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
