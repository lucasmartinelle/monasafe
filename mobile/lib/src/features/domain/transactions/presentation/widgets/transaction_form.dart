import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:monasafe/src/common_widgets/numeric_keypad.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_state.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/category_grid.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/recurrence_toggle.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/smart_note_field.dart';

/// Reusable transaction form content widget.
/// Used by both add and edit transaction screens.
class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({
    required this.title,
    required this.primaryButtonLabel,
    required this.onPrimaryAction,
    this.secondaryActions,
    this.onInit,
    super.key,
  });

  final String title;
  final String primaryButtonLabel;
  final Future<bool> Function() onPrimaryAction;

  /// Optional secondary action buttons (e.g., delete, re-emit)
  final List<TransactionFormAction>? secondaryActions;

  /// Called after the first frame to initialize the form
  final VoidCallback? onInit;

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

/// Represents a secondary action button
class TransactionFormAction {
  const TransactionFormAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isDestructive = false,
    this.showLoading = false,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
  final Color? color;
  final bool isDestructive;
  final bool showLoading;
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  bool _showKeypad = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.onInit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onInit!();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleKeypad() {
    setState(() {
      _showKeypad = !_showKeypad;
    });
    if (_showKeypad) {
      FocusScope.of(context).unfocus();
    }
  }

  void _hideKeypad() {
    if (_showKeypad) {
      setState(() {
        _showKeypad = false;
      });
    }
  }

  void _scrollToNoteField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && _scrollController.hasClients) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          if (maxScroll > 0) {
            _scrollController.animateTo(
              maxScroll,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        }
      });
    });
  }

  Future<void> _handlePrimaryAction() async {
    final success = await widget.onPrimaryAction();

    if (success && mounted) {
      await _showSuccessAnimation();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _showSuccessAnimation() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => const _SuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final state = ref.watch(transactionFormNotifierProvider);
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return PopScope(
      canPop: !_showKeypad && keyboardHeight == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_showKeypad) {
            _hideKeypad();
          } else {
            FocusScope.of(context).unfocus();
          }
        }
      },
      child: Container(
        height: mediaQuery.size.height * 0.92,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            _DragHandle(isDark: isDark),

            // Header
            _Header(title: widget.title, isDark: isDark),

            // Content
            Expanded(
            child: GestureDetector(
              onTap: _hideKeypad,
              behavior: HitTestBehavior.translucent,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Type tabs
                    const _FormTypeTabs(),

                    const SizedBox(height: 24),

                    // Amount display
                    _AmountSection(
                      showKeypad: _showKeypad,
                      onTap: _toggleKeypad,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // Account selector
                    const _FormAccountDropdown(),

                    const SizedBox(height: 16),

                    // Date selector
                    _FormDateSelector(onInteraction: _hideKeypad),

                    const SizedBox(height: 16),

                    // Category label
                    Text(
                      'Catégorie',
                      style: AppTextStyles.labelMedium(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Category grid
                    _FormCategoryGrid(onInteraction: _hideKeypad),

                    const SizedBox(height: 16),

                    // Smart note field
                    _FormSmartNoteField(
                      onFocusChanged: (hasFocus) {
                        if (hasFocus) {
                          _hideKeypad();
                          _scrollToNoteField();
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Recurrence toggle
                    _FormRecurrenceToggle(onInteraction: _hideKeypad),

                    const SizedBox(height: 16),

                    // Error message
                    if (state.error != null) _ErrorMessage(error: state.error!),

                    SizedBox(
                        height: keyboardHeight > 0 ? keyboardHeight + 150 : 16),
                  ],
                ),
              ),
            ),
          ),

          // Bottom section (keypad and buttons)
          if (keyboardHeight == 0) ...[
            // Numeric keypad
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _showKeypad
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: const _FormNumericKeypad(),
                    )
                  : const SizedBox.shrink(),
            ),

            // Action buttons
            _ActionButtons(
              state: state,
              primaryLabel: widget.primaryButtonLabel,
              onPrimaryAction: _handlePrimaryAction,
              secondaryActions: widget.secondaryActions,
              isDark: isDark,
              bottomPadding: mediaQuery.padding.bottom,
            ),
          ],
        ],
      ),
      ),
    );
  }
}

// ============ Private widgets ============

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _FormTypeTabs extends ConsumerWidget {
  const _FormTypeTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeTab(
              label: 'Dépense',
              icon: Icons.remove_circle_outline,
              isSelected: state.type == CategoryType.expense,
              onTap: () => ref
                  .read(transactionFormNotifierProvider.notifier)
                  .setType(CategoryType.expense),
            ),
          ),
          Expanded(
            child: _TypeTab(
              label: 'Revenu',
              icon: Icons.add_circle_outline,
              isSelected: state.type == CategoryType.income,
              onTap: () => ref
                  .read(transactionFormNotifierProvider.notifier)
                  .setType(CategoryType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountSection extends ConsumerWidget {
  const _AmountSection({
    required this.showKeypad,
    required this.onTap,
    required this.isDark,
  });

  final bool showKeypad;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);

    final color = state.type == CategoryType.expense
        ? AppColors.error
        : AppColors.success;

    final prefix = state.type == CategoryType.expense ? '-' : '+';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: showKeypad
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: showKeypad
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          children: [
            // Type indicator
            Text(
              state.type == CategoryType.expense ? 'Dépense' : 'Revenu',
              style: AppTextStyles.labelMedium(color: color),
            ),
            const SizedBox(height: 8),
            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(prefix, style: AppTextStyles.h1(color: color)),
                Text(state.displayAmount, style: AppTextStyles.h1(color: color)),
                const SizedBox(width: 8),
                Text(
                  '€',
                  style: AppTextStyles.h2(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              showKeypad ? 'Tapez pour fermer' : 'Tapez pour modifier',
              style: AppTextStyles.caption(
                color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormNumericKeypad extends ConsumerWidget {
  const _FormNumericKeypad();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionFormNotifierProvider.notifier);

    return NumericKeypad(
      onDigit: notifier.appendDigit,
      onDelete: notifier.deleteDigit,
      onClear: notifier.clearAmount,
    );
  }
}

class _FormAccountDropdown extends ConsumerWidget {
  const _FormAccountDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) return const SizedBox.shrink();

        final selectedAccount = accounts.firstWhere(
          (a) => a.id == state.selectedAccountId,
          orElse: () => accounts.first,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedAccount.id,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: AppTextStyles.labelMedium(color: textColor),
              dropdownColor: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              items: accounts.map((account) {
                return DropdownMenuItem<String>(
                  value: account.id,
                  child: Row(
                    children: [
                      Icon(
                        _getAccountIcon(account),
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(account.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(transactionFormNotifierProvider.notifier)
                      .setAccount(value);
                }
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  IconData _getAccountIcon(Account account) {
    return switch (account.type) {
      AccountType.checking => Icons.account_balance,
      AccountType.savings => Icons.savings,
      AccountType.cash => Icons.payments,
    };
  }
}

class _FormDateSelector extends ConsumerWidget {
  const _FormDateSelector({this.onInteraction});

  final VoidCallback? onInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(state.effectiveDate);

    return InkWell(
      onTap: () async {
        onInteraction?.call();
        FocusScope.of(context).unfocus();
        final picked = await showDatePicker(
          context: context,
          initialDate: state.effectiveDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          // Combiner la date choisie avec l'heure actuelle pour un tri précis
          final now = DateTime.now();
          final dateWithTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            now.hour,
            now.minute,
            now.second,
          );
          ref.read(transactionFormNotifierProvider.notifier).setDate(dateWithTime);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formattedDate,
                style: AppTextStyles.labelMedium(color: textColor),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCategoryGrid extends ConsumerWidget {
  const _FormCategoryGrid({this.onInteraction});

  final VoidCallback? onInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final categoriesAsync = state.type == CategoryType.expense
        ? ref.watch(expenseCategoriesStreamProvider)
        : ref.watch(incomeCategoriesStreamProvider);

    return categoriesAsync.when(
      data: (categories) {
        return CategoryGrid(
          categories: categories,
          selectedCategoryId: state.categoryId,
          onCategorySelected: (categoryId) {
            onInteraction?.call();
            FocusScope.of(context).unfocus();
            ref
                .read(transactionFormNotifierProvider.notifier)
                .setCategory(categoryId);
          },
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FormSmartNoteField extends ConsumerWidget {
  const _FormSmartNoteField({required this.onFocusChanged});

  final ValueChanged<bool> onFocusChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);

    return SmartNoteField(
      initialValue: state.note,
      transactionType: state.type,
      onChanged: (note) {
        ref.read(transactionFormNotifierProvider.notifier).setNote(note);
      },
      onFocusChanged: onFocusChanged,
    );
  }
}

class _FormRecurrenceToggle extends ConsumerWidget {
  const _FormRecurrenceToggle({this.onInteraction});

  final VoidCallback? onInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);

    return RecurrenceToggle(
      isRecurring: state.isRecurring,
      onChanged: (value) {
        onInteraction?.call();
        FocusScope.of(context).unfocus();
        ref.read(transactionFormNotifierProvider.notifier).setRecurring(isRecurring: value);
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.bodySmall(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.state,
    required this.primaryLabel,
    required this.onPrimaryAction,
    required this.isDark,
    required this.bottomPadding,
    this.secondaryActions,
  });

  final TransactionFormState state;
  final String primaryLabel;
  final VoidCallback onPrimaryAction;
  final List<TransactionFormAction>? secondaryActions;
  final bool isDark;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      child: Column(
        children: [
          // Primary action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isValid && !state.isBusy ? onPrimaryAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    isDark ? AppColors.surfaceDark : AppColors.dividerLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      primaryLabel,
                      style: AppTextStyles.button(color: Colors.white),
                    ),
            ),
          ),

          // Secondary actions
          if (secondaryActions != null && secondaryActions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: secondaryActions!.map((action) {
                final color = action.color ??
                    (action.isDestructive ? AppColors.error : AppColors.success);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: action != secondaryActions!.last ? 12 : 0,
                    ),
                    child: OutlinedButton(
                      onPressed: !state.isBusy ? action.onPressed : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(
                          color: state.isBusy
                              ? (isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight)
                              : color,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: action.showLoading && state.isDeleting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: color,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(action.icon, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  action.label,
                                  style: AppTextStyles.button(color: color),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
