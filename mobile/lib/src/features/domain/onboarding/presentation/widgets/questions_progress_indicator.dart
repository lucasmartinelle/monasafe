import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';

/// Indicateur de progression pour les questions d'onboarding.
class QuestionsProgressIndicator extends StatelessWidget {
  const QuestionsProgressIndicator({
    required this.currentPage,
    required this.totalPages,
    super.key,
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
