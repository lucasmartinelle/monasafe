import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:monasafe/src/common_widgets/numeric_keypad.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transfer_form_provider.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transfer_form_state.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transaction_form_success_dialog.dart';

/// Formulaire de virement entre deux comptes de l'utilisateur.
class TransferForm extends ConsumerStatefulWidget {
  const TransferForm({this.onInit, super.key});

  final VoidCallback? onInit;

  @override
  ConsumerState<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<TransferForm> {
  bool _showKeypad = false;
  final _scrollController = ScrollController();
  final _noteController = TextEditingController();

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
    _noteController.dispose();
    super.dispose();
  }

  void _toggleKeypad() {
    setState(() => _showKeypad = !_showKeypad);
    if (_showKeypad) FocusScope.of(context).unfocus();
  }

  void _hideKeypad() {
    if (_showKeypad) setState(() => _showKeypad = false);
  }

  Future<void> _handleConfirm() async {
    final success =
        await ref.read(transferFormNotifierProvider.notifier).createTransfer();

    if (success && mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (context) => const TransactionFormSuccessDialog(),
      );
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final state = ref.watch(transferFormNotifierProvider);
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
            _Header(isDark: isDark),
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

                      // Montant
                      _AmountSection(
                        state: state,
                        showKeypad: _showKeypad,
                        onTap: _toggleKeypad,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 24),

                      // Sélection des comptes
                      _AccountsSection(state: state, isDark: isDark),

                      const SizedBox(height: 16),

                      // Sélecteur de date
                      _DateSelector(state: state, onInteraction: _hideKeypad),

                      const SizedBox(height: 16),

                      // Note optionnelle
                      _NoteField(
                        controller: _noteController,
                        isDark: isDark,
                        onFocus: () {
                          _hideKeypad();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Future.delayed(const Duration(milliseconds: 400),
                                () {
                              if (mounted && _scrollController.hasClients) {
                                final max = _scrollController
                                    .position.maxScrollExtent;
                                if (max > 0) {
                                  _scrollController.animateTo(
                                    max,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  );
                                }
                              }
                            });
                          });
                        },
                      ),

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
                        child: _TransferNumericKeypad(),
                      )
                    : const SizedBox.shrink(),
              ),
              _ActionButtons(
                state: state,
                onConfirm: _handleConfirm,
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

// ============================================================
// Sous-widgets
// ============================================================

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
  const _Header({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Virement entre comptes',
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

class _AmountSection extends StatelessWidget {
  const _AmountSection({
    required this.state,
    required this.showKeypad,
    required this.onTap,
    required this.isDark,
  });

  final TransferFormState state;
  final bool showKeypad;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Montant du virement',
              style: AppTextStyles.labelMedium(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  state.displayAmount,
                  style: AppTextStyles.h1(color: AppColors.primary),
                ),
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

class _AccountsSection extends ConsumerWidget {
  const _AccountsSection({required this.state, required this.isDark});

  final TransferFormState state;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.length < 2) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous devez avoir au moins deux comptes pour effectuer un virement.',
                    style: AppTextStyles.bodySmall(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          );
        }

        final fromAccount = accounts.firstWhere(
          (a) => a.id == state.fromAccountId,
          orElse: () => accounts.first,
        );

        final toAccount = accounts.firstWhere(
          (a) => a.id == state.toAccountId,
          orElse: () =>
              accounts.firstWhere((a) => a.id != fromAccount.id),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comptes',
              style: AppTextStyles.labelMedium(color: secondaryColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Compte source
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Depuis',
                        style: AppTextStyles.caption(color: secondaryColor),
                      ),
                      const SizedBox(height: 4),
                      _AccountDropdown(
                        accounts: accounts,
                        selectedId: fromAccount.id,
                        excludeId: toAccount.id,
                        isDark: isDark,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        onChanged: (id) => ref
                            .read(transferFormNotifierProvider.notifier)
                            .setFromAccount(id),
                      ),
                    ],
                  ),
                ),

                // Flèche centrale
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                // Compte destination
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vers',
                        style: AppTextStyles.caption(color: secondaryColor),
                      ),
                      const SizedBox(height: 4),
                      _AccountDropdown(
                        accounts: accounts,
                        selectedId: toAccount.id,
                        excludeId: fromAccount.id,
                        isDark: isDark,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        onChanged: (id) => ref
                            .read(transferFormNotifierProvider.notifier)
                            .setToAccount(id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AccountDropdown extends StatelessWidget {
  const _AccountDropdown({
    required this.accounts,
    required this.selectedId,
    required this.excludeId,
    required this.isDark,
    required this.backgroundColor,
    required this.textColor,
    required this.onChanged,
  });

  final List<Account> accounts;
  final String selectedId;
  final String excludeId;
  final bool isDark;
  final Color backgroundColor;
  final Color textColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final available = accounts.where((a) => a.id != excludeId).toList();
    final selected = available.firstWhere(
      (a) => a.id == selectedId,
      orElse: () => available.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected.id,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: AppTextStyles.labelMedium(color: textColor).copyWith(
            fontSize: 13,
          ),
          dropdownColor: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          items: available
              .map(
                (a) => DropdownMenuItem<String>(
                  value: a.id,
                  child: Text(
                    a.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (id) {
            if (id != null) onChanged(id);
          },
        ),
      ),
    );
  }
}

class _DateSelector extends ConsumerWidget {
  const _DateSelector({required this.state, this.onInteraction});

  final TransferFormState state;
  final VoidCallback? onInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return InkWell(
      onTap: () async {
        onInteraction?.call();
        FocusScope.of(context).unfocus();
        final picked = await showDatePicker(
          context: context,
          initialDate: state.effectiveDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null && context.mounted) {
          final now = DateTime.now();
          final dateWithTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            now.hour,
            now.minute,
            now.second,
          );
          ref
              .read(transferFormNotifierProvider.notifier)
              .setDate(dateWithTime);
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
                dateFormat.format(state.effectiveDate),
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

class _NoteField extends ConsumerWidget {
  const _NoteField({
    required this.controller,
    required this.isDark,
    this.onFocus,
  });

  final TextEditingController controller;
  final bool isDark;
  final VoidCallback? onFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textHintDark : AppColors.textHintLight;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) onFocus?.call();
      },
      child: TextField(
        controller: controller,
        onChanged: (v) =>
            ref.read(transferFormNotifierProvider.notifier).setNote(v),
        decoration: InputDecoration(
          hintText: 'Note (optionnel)',
          hintStyle: AppTextStyles.bodyMedium(color: hintColor),
          prefixIcon:
              const Icon(Icons.notes, size: 20, color: AppColors.primary),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        style: AppTextStyles.bodyMedium(color: textColor),
      ),
    );
  }
}

class _TransferNumericKeypad extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transferFormNotifierProvider.notifier);
    return NumericKeypad(
      onDigit: notifier.appendDigit,
      onDelete: notifier.deleteDigit,
      onClear: notifier.clearAmount,
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.state,
    required this.onConfirm,
    required this.isDark,
    required this.bottomPadding,
  });

  final TransferFormState state;
  final VoidCallback onConfirm;
  final bool isDark;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: state.isValid && !state.isSubmitting ? onConfirm : null,
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
                  'Confirmer le virement',
                  style: AppTextStyles.button(color: Colors.white),
                ),
        ),
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
