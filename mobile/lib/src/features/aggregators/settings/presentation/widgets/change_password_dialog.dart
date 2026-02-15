import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/vault/presentation/vault_providers.dart';

/// Dialog pour changer le mot de passe du Vault.
class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (newPass.length < 8) {
      setState(() =>
          _error = 'Le nouveau mot de passe doit contenir au moins 8 caractères');
      return;
    }

    if (newPass != confirm) {
      setState(() => _error = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref
        .read(vaultNotifierProvider.notifier)
        .changeMasterPassword(current, newPass);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isLoading = false;
          _error = ref.read(vaultNotifierProvider).error ?? 'Erreur inconnue';
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

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(
        'Changer le mot de passe',
        style: AppTextStyles.h4(color: textColor),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _currentController,
              label: 'Mot de passe actuel',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _newController,
              label: 'Nouveau mot de passe',
              hint: 'Minimum 8 caractères',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmController,
              label: 'Confirmer',
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
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Annuler', style: TextStyle(color: textColor)),
        ),
        AppButton(
          label: 'Confirmer',
          onPressed: _isLoading ? null : _changePassword,
          isLoading: _isLoading,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
