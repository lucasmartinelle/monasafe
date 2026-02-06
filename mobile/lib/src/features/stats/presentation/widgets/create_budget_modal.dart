import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/common_widgets.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/core/utils/icon_mapper.dart';
import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';
import 'package:simpleflow/src/features/stats/presentation/stats_providers.dart';
import 'package:simpleflow/src/features/transactions/transactions.dart';

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

  /// Display amount formatted with comma (e.g., "1,50")
  String get _displayAmount {
    final euros = _amountCents ~/ 100;
    final cents = _amountCents % 100;
    return '$euros,${cents.toString().padLeft(2, '0')}';
  }

  /// Amount in euros
  double get _amount => _amountCents / 100;

  /// Whether the form is valid
  bool get _isValid => _selectedCategoryId != null && _amountCents > 0;

  void _appendDigit(String digit) {
    // Limit to 999999,99 (8 digits)
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

      // Refresh budget list
      ref.invalidate(budgetProgressStreamProvider);

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
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Get expense categories (budgets are only for expenses)
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

            // Category selection
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
            _BudgetAmountDisplay(
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
            child: _CategoryItem(
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

/// Affichage du montant du budget.
class _BudgetAmountDisplay extends StatelessWidget {
  const _BudgetAmountDisplay({
    required this.displayAmount,
    required this.amountCents,
  });

  final String displayAmount;
  final int amountCents;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Limite mensuelle',
          style: AppTextStyles.labelMedium(color: secondaryColor),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: Row(
            key: ValueKey(displayAmount),
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayAmount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: amountCents == 0
                      ? textColor.withValues(alpha: 0.3)
                      : textColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '€',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: amountCents == 0
                        ? textColor.withValues(alpha: 0.3)
                        : textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Item de catégorie dans la grille.
class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final categoryColor = Color(category.color);

    return SizedBox(
      width: 76,
      child: SelectableOptionContainer(
        isSelected: isSelected,
        onTap: onTap,
        selectedColor: categoryColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        enableHapticFeedback: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon.fromHex(
              icon: IconMapper.getIcon(category.iconKey),
              colorHex: category.color,
              size: CategoryIconSize.small,
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? textColor : subtitleColor,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
