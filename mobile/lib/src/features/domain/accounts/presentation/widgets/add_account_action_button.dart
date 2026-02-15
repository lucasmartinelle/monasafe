import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/account_form_provider.dart';

/// Bouton d'action pour creer le compte.
class AddAccountActionButton extends ConsumerWidget {
  const AddAccountActionButton({
    required this.isDark,
    required this.bottomPadding,
    super.key,
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
