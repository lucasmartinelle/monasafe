import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/numeric_keypad.dart';
import 'package:monasafe/src/core/services/invalidation_service.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/account_type.dart';
import 'package:monasafe/src/core/utils/constants.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';

/// Modal bottom sheet pour modifier le solde initial d'un compte.
class EditInitialBalanceScreen extends ConsumerStatefulWidget {
  const EditInitialBalanceScreen({required this.account, super.key});

  final Account account;

  /// Affiche la modal de modification du solde initial.
  static Future<bool?> show(BuildContext context, Account account) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditInitialBalanceScreen(account: account),
    );
  }

  @override
  ConsumerState<EditInitialBalanceScreen> createState() =>
      _EditInitialBalanceScreenState();
}

class _EditInitialBalanceScreenState
    extends ConsumerState<EditInitialBalanceScreen> {
  late int _amountInCents;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountInCents = (widget.account.balance * 100).round();
  }

  void _appendDigit(String digit) {
    final newAmount = _amountInCents * 10 + int.parse(digit);
    if (newAmount > kMaxAmountCents) return;
    setState(() {
      _amountInCents = newAmount;
      _error = null;
    });
  }

  void _deleteDigit() {
    setState(() {
      _amountInCents = _amountInCents ~/ 10;
      _error = null;
    });
  }

  void _clearAmount() {
    setState(() {
      _amountInCents = 0;
      _error = null;
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await ref.read(accountRepositoryProvider).updateAccount(
      id: widget.account.id,
      balance: _amountInCents / 100,
    );

    result.fold(
      (error) => setState(() {
        _isSubmitting = false;
        _error = error.message;
      }),
      (_) {
        InvalidationService.onAccountUpdatedFromWidget(ref);
        if (mounted) Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mediaQuery = MediaQuery.of(context);

    final calculatedBalanceAsync = ref.watch(
      accountCalculatedBalanceStreamProvider(widget.account.id),
    );

    // Preview: net = calculatedBalance - account.balance (initial actuel)
    //          preview = newInitial + net
    final newInitial = _amountInCents / 100;
    final previewBalance = calculatedBalanceAsync.when(
      data: (calculated) {
        final net = calculated - widget.account.balance;
        return newInitial + net;
      },
      loading: () => null,
      error: (_, __) => null,
    );

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(widget.account.color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    getAccountTypeIcon(widget.account.type),
                    size: 18,
                    color: Color(widget.account.color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.account.name,
                    style: AppTextStyles.h3(color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Solde initial',
                    style: AppTextStyles.caption(color: subtitleColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),

                // Amount display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    CurrencyFormatter.format(newInitial),
                    style: AppTextStyles.h1(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Preview card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Solde calculé avec transactions',
                          style: AppTextStyles.caption(color: subtitleColor),
                        ),
                        if (previewBalance != null)
                          Text(
                            CurrencyFormatter.format(previewBalance),
                            style: AppTextStyles.labelMedium(
                              color: previewBalance >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          )
                        else
                          SizedBox(
                            width: 60,
                            height: 14,
                            child: Container(
                              decoration: BoxDecoration(
                                color: subtitleColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Numeric keypad
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: NumericKeypad(
                    onDigit: _appendDigit,
                    onDelete: _deleteDigit,
                    onClear: _clearAmount,
                  ),
                ),

                // Error message
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _error!,
                      style: AppTextStyles.caption(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const Spacer(),

                // Save button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    mediaQuery.padding.bottom + 16,
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Enregistrer',
                            style: AppTextStyles.labelLarge(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
