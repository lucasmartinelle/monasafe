import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';

/// Custom numeric keypad for amount input (cents mode).
///
/// In cents mode, digits are appended from the right:
/// - Tap 1 → 0,01€
/// - Tap 5 → 0,15€
/// - Tap 0 → 1,50€
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    required this.onDigit,
    required this.onDelete,
    required this.onClear,
    super.key,
  });

  /// Callback when a digit is pressed.
  final ValueChanged<String> onDigit;

  /// Callback when delete is pressed.
  final VoidCallback onDelete;

  /// Callback when clear (long press delete) is pressed.
  final VoidCallback onClear;

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

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.digit,
    required this.onDigit,
  });

  final String digit;
  final ValueChanged<String> onDigit;

  @override
  Widget build(BuildContext context) {
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
                onDigit(digit);
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
class _DoubleZeroButton extends StatelessWidget {
  const _DoubleZeroButton({required this.onDigit});

  final ValueChanged<String> onDigit;

  @override
  Widget build(BuildContext context) {
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
                onDigit('0');
                onDigit('0');
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

class _BackspaceButton extends StatelessWidget {
  const _BackspaceButton({
    required this.onDelete,
    required this.onClear,
  });

  final VoidCallback onDelete;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
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
                onDelete();
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                onClear();
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
