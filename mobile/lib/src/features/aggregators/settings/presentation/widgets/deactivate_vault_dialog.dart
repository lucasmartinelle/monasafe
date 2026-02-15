import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/vault/presentation/vault_providers.dart';

/// Dialog pour desactiver le Vault.
class DeactivateVaultDialog extends ConsumerStatefulWidget {
  const DeactivateVaultDialog({super.key});

  @override
  ConsumerState<DeactivateVaultDialog> createState() =>
      _DeactivateVaultDialogState();
}

class _DeactivateVaultDialogState
    extends ConsumerState<DeactivateVaultDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deactivate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref
        .read(vaultNotifierProvider.notifier)
        .deactivate(_passwordController.text);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        final vaultError = ref.read(vaultNotifierProvider).error;
        setState(() {
          _isLoading = false;
          _error = vaultError ?? 'Erreur inconnue';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(
        'Désactiver le Vault',
        style: AppTextStyles.h4(color: textColor),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cette action supprimera le chiffrement de vos données. '
            'Entrez votre mot de passe pour confirmer.',
            style: AppTextStyles.bodyMedium(color: subtitleColor),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passwordController,
            label: 'Mot de passe maître',
            obscureText: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: AppTextStyles.bodySmall(color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Annuler', style: TextStyle(color: textColor)),
        ),
        AppButton(
          label: 'Désactiver',
          onPressed: _isLoading ? null : _deactivate,
          isLoading: _isLoading,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
