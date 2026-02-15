import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/services/invalidation_service.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/stats/presentation/widgets/create_budget_amount_display.dart';
import 'package:monasafe/src/features/domain/stats/presentation/widgets/create_budget_category_item.dart';

/// Modal bottom sheet pour créer ou modifier un budget.
class CreateBudgetModal extends ConsumerStatefulWidget {
  const CreateBudgetModal({super.key});

  /// Affiche le modal de création de budget.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateBudgetModal(),
    );
  }

  @override
  ConsumerState<CreateBudgetModal> createState() => _CreateBudgetModalState();
}

class _CreateBudgetModalState extends ConsumerState<CreateBudgetModal> {
  String? _selectedCategoryId;
  int _amountCents = 0;
  bool _isSubmitting = false;

  String get _displayAmount {
    final euros = _amountCents ~/ 100;
    final cents = _amountCents % 100;
    return '$euros,${cents.toString().padLeft(2, '0')}';
  }

  double get _amount => _amountCents / 100;

  bool get _isValid => _selectedCategoryId != null && _amountCents > 0;

  void _appendDigit(String digit) {
    if (_amountCents.toString().length >= 8) return;
    setState(() {
      _amountCents = _amountCents * 10 + int.parse(digit);
    });
  }

  void _deleteDigit() {
    setState(() {
      _amountCents = _amountCents ~/ 10;
    });
  }

  void _clearAmount() {
    setState(() {
      _amountCents = 0;
    });
  }

  void _selectCategory(String categoryId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  Future<void> _submit() async {
    if (!_isValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final budgetService = ref.read(budgetServiceProvider);

      await budgetService.upsertBudget(
        categoryId: _selectedCategoryId!,
        budgetLimit: _amount,
      );

      InvalidationService.onBudgetChangedFromWidget(ref);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final categoriesAsync = ref.watch(expenseCategoriesStreamProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Créer un budget',
                    style: AppTextStyles.h3(color: textColor),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: secondaryColor),
                  ),
                ],
              ),
            ),

            // Category selection label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Catégorie',
                  style: AppTextStyles.labelMedium(color: secondaryColor),
                ),
              ),
            ),

            // Category grid
            categoriesAsync.when(
              data: _buildCategoryGrid,
              loading: () => const SizedBox(
                height: 100,
                child: LoadingStateWidget(padding: EdgeInsets.zero),
              ),
              error: (_, __) => const SizedBox(
                height: 100,
                child: ErrorStateWidget(
                  message: 'Erreur de chargement',
                  padding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Amount display
            CreateBudgetAmountDisplay(
              displayAmount: _displayAmount,
              amountCents: _amountCents,
            ),

            const SizedBox(height: 24),

            // Numeric keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: NumericKeypad(
                onDigit: _appendDigit,
                onDelete: _deleteDigit,
                onClear: _clearAmount,
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: AppButton(
                label: 'Créer le budget',
                fullWidth: true,
                isLoading: _isSubmitting,
                onPressed: _isValid ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: EmptyStateWidget(
          message: 'Aucune catégorie',
          padding: EdgeInsets.zero,
          iconSize: 32,
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == _selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CreateBudgetCategoryItem(
              category: category,
              isSelected: isSelected,
              onTap: () => _selectCategory(category.id),
            ),
          );
        },
      ),
    );
  }
}
