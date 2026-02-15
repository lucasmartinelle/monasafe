import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/features/domain/onboarding/presentation/onboarding_controller.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/widgets/account_question_page.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/widgets/currency_question_page.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/widgets/questions_progress_indicator.dart';

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: QuestionsProgressIndicator(
            currentPage: _currentPage,
            totalPages: 3,
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CurrencyQuestionPage(
                selectedCurrency: state.currency,
                onNext: _goToNextPage,
              ),
              AccountQuestionPage(
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
              AccountQuestionPage(
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
