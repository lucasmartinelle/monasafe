import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/features/transactions/presentation/transaction_form_provider.dart';

/// Custom numeric keypad for amount input (cents mode).
///
/// Can be used in two modes:
/// 1. Connected to transactionFormNotifierProvider (default)
/// 2. Standalone with explicit onDigit, onDelete, and onClear callbacks
///
/// In cents mode, digits are appended from the right:
/// - Tap 1 → 0,01€
/// - Tap 5 → 0,15€
/// - Tap 0 → 1,50€
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    this.onDigit,
    this.onDelete,
    this.onClear,
  });

  /// Callback when a digit is pressed. If null, uses provider.
  final ValueChanged<String>? onDigit;

  /// Callback when delete is pressed. If null, uses provider.
  final VoidCallback? onDelete;

  /// Callback when clear (long press delete) is pressed. If null, uses provider.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _KeypadButton(digit: '1', onDigit: onDigit),
            _KeypadButton(digit: '2', onDigit: onDigit),
            _KeypadButton(digit: '3', onDigit: onDigit),
          ],
        ),
        Row(
          children: [
            _KeypadButton(digit: '4', onDigit: onDigit),
            _KeypadButton(digit: '5', onDigit: onDigit),
            _KeypadButton(digit: '6', onDigit: onDigit),
          ],
        ),
        Row(
          children: [
            _KeypadButton(digit: '7', onDigit: onDigit),
            _KeypadButton(digit: '8', onDigit: onDigit),
            _KeypadButton(digit: '9', onDigit: onDigit),
          ],
        ),
        Row(
          children: [
            _DoubleZeroButton(onDigit: onDigit),
            _KeypadButton(digit: '0', onDigit: onDigit),
            _BackspaceButton(onDelete: onDelete, onClear: onClear),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends ConsumerWidget {
  const _KeypadButton({
    required this.digit,
    this.onDigit,
  });

  final String digit;
  final ValueChanged<String>? onDigit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.8,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (onDigit != null) {
                  onDigit!(digit);
                } else {
                  ref
                      .read(transactionFormNotifierProvider.notifier)
                      .appendDigit(digit);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    digit,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Button that adds "00" (useful for entering whole euro amounts quickly).
class _DoubleZeroButton extends ConsumerWidget {
  const _DoubleZeroButton({this.onDigit});

  final ValueChanged<String>? onDigit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.8,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                // Add two zeros
                if (onDigit != null) {
                  onDigit!('0');
                  onDigit!('0');
                } else {
                  final notifier = ref.read(transactionFormNotifierProvider.notifier);
                  notifier.appendDigit('0');
                  notifier.appendDigit('0');
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '00',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends ConsumerWidget {
  const _BackspaceButton({
    this.onDelete,
    this.onClear,
  });

  final VoidCallback? onDelete;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.8,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (onDelete != null) {
                  onDelete!();
                } else {
                  ref.read(transactionFormNotifierProvider.notifier).deleteDigit();
                }
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                if (onClear != null) {
                  onClear!();
                } else {
                  ref.read(transactionFormNotifierProvider.notifier).clearAmount();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.backspace_outlined,
                    size: 26,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
