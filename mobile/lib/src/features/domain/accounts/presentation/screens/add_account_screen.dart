import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/common_widgets/numeric_keypad.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/account_type.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/account_form_provider.dart';

/// Modal bottom sheet pour créer un nouveau compte.
class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  /// Affiche la modal de création de compte.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAccountScreen(),
    );
  }

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountFormNotifierProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          _DragHandle(isDark: isDark),

          // Header
          _Header(isDark: isDark),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // Account type selector
                  const _AccountTypeSelector(),

                  const SizedBox(height: 32),

                  // Amount section
                  _AmountSection(isDark: isDark),

                  const SizedBox(height: 24),

                  // Numeric keypad
                  const _FormNumericKeypad(),

                  const SizedBox(height: 16),

                  // Error message
                  const _ErrorMessage(),
                ],
              ),
            ),
          ),

          // Action button
          _ActionButton(
            isDark: isDark,
            bottomPadding: mediaQuery.padding.bottom,
          ),
        ],
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
              'Nouveau compte',
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

class _AccountTypeSelector extends ConsumerWidget {
  const _AccountTypeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(accountFormNotifierProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);

    final accounts = accountsAsync.valueOrNull ?? [];
    final existingTypes = accounts.map((a) => a.type).toSet();

    // Types disponibles à créer
    final availableTypes = [AccountType.checking, AccountType.savings]
        .where((t) => !existingTypes.contains(t))
        .toList();

    if (availableTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Tous les types de comptes ont déjà été créés.',
          style: AppTextStyles.bodySmall(color: AppColors.warning),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de compte',
          style: AppTextStyles.labelMedium(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: availableTypes.map((type) {
            final isSelected = state.selectedType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != availableTypes.last ? 12 : 0,
                ),
                child: _AccountTypeOption(
                  type: type,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => ref
                      .read(accountFormNotifierProvider.notifier)
                      .setType(type),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AccountTypeOption extends StatelessWidget {
  const _AccountTypeOption({
    required this.type,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final AccountType type;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final iconColor = isSelected ? Colors.white : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Column(
          children: [
            Icon(
              getAccountTypeIcon(type),
              size: 28,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              getAccountTypeLabel(type),
              style: AppTextStyles.labelMedium(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountSection extends ConsumerWidget {
  const _AmountSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountFormNotifierProvider);
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      children: [
        Text(
          'Solde initial',
          style: AppTextStyles.labelMedium(color: subtitleColor),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              state.displayAmount,
              style: AppTextStyles.h1(color: textColor),
            ),
            const SizedBox(width: 8),
            Text(
              '€',
              style: AppTextStyles.h2(color: subtitleColor),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormNumericKeypad extends ConsumerWidget {
  const _FormNumericKeypad();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(accountFormNotifierProvider.notifier);

    return NumericKeypad(
      onDigit: notifier.appendDigit,
      onDelete: notifier.deleteDigit,
      onClear: notifier.clearAmount,
    );
  }
}

class _ErrorMessage extends ConsumerWidget {
  const _ErrorMessage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(
      accountFormNotifierProvider.select((s) => s.error),
    );

    if (error == null) return const SizedBox.shrink();

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

class _ActionButton extends ConsumerWidget {
  const _ActionButton({
    required this.isDark,
    required this.bottomPadding,
  });

  final bool isDark;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountFormNotifierProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: state.isValid && !state.isSubmitting
              ? () async {
                  final success = await ref
                      .read(accountFormNotifierProvider.notifier)
                      .create();
                  if (success && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                }
              : null,
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
                  'Créer le compte',
                  style: AppTextStyles.button(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
