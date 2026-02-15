import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form_account_dropdown.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form_action_buttons.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form_amount_section.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form_date_selector.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form_fields.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form_success_dialog.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form_type_tabs.dart';

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
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (context) => const TransactionFormSuccessDialog(),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
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
            _DragHandle(isDark: isDark),

            _Header(title: widget.title, isDark: isDark),

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

                    const TransactionFormTypeTabs(),

                    const SizedBox(height: 24),

                    TransactionFormAmountSection(
                      showKeypad: _showKeypad,
                      onTap: _toggleKeypad,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    const TransactionFormAccountDropdown(),

                    const SizedBox(height: 16),

                    TransactionFormDateSelector(onInteraction: _hideKeypad),

                    const SizedBox(height: 16),

                    Text(
                      'Catégorie',
                      style: AppTextStyles.labelMedium(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TransactionFormCategoryGrid(onInteraction: _hideKeypad),

                    const SizedBox(height: 16),

                    TransactionFormSmartNoteField(
                      onFocusChanged: (hasFocus) {
                        if (hasFocus) {
                          _hideKeypad();
                          _scrollToNoteField();
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    TransactionFormRecurrenceToggle(onInteraction: _hideKeypad),

                    const SizedBox(height: 16),

                    if (state.error != null) _ErrorMessage(error: state.error!),

                    SizedBox(
                        height: keyboardHeight > 0 ? keyboardHeight + 150 : 16),
                  ],
                ),
              ),
            ),
          ),

          if (keyboardHeight == 0) ...[
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _showKeypad
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: const TransactionFormNumericKeypad(),
                    )
                  : const SizedBox.shrink(),
            ),

            TransactionFormActionButtons(
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
