import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/account_form_provider.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/widgets/add_account_action_button.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/widgets/add_account_amount_section.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/widgets/add_account_error_message.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/widgets/add_account_type_selector.dart';

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
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
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
                Expanded(
                  child: Text(
                    'Nouveau compte',
                    style: AppTextStyles.h3(color: textColor),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const AddAccountTypeSelector(),
                  const SizedBox(height: 32),
                  AddAccountAmountSection(isDark: isDark),
                  const SizedBox(height: 16),
                  const AddAccountErrorMessage(),
                ],
              ),
            ),
          ),

          // Action button
          AddAccountActionButton(
            isDark: isDark,
            bottomPadding: mediaQuery.padding.bottom,
          ),
        ],
      ),
    );
  }
}
