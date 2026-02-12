import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/settings/presentation/widgets/settings_section_tile.dart';
import 'package:monasafe/src/features/vault/presentation/screens/vault_setup_screen.dart';
import 'package:monasafe/src/features/vault/presentation/vault_providers.dart';

/// Écran Sécurité avec gestion du Vault.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  Future<void> _activateVault() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const VaultSetupScreen()),
    );

    if ((result ?? false) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vault activé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _toggleBiometry(bool enable) async {
    final vaultState = ref.read(vaultNotifierProvider);

    // Vérifier que le vault est déverrouillé
    if (vaultState.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déverrouillez le vault pour modifier ce paramètre'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    bool success;
    if (enable) {
      success = await ref.read(vaultNotifierProvider.notifier).enableBiometry();
    } else {
      await ref.read(vaultNotifierProvider.notifier).disableBiometry();
      success = true;
    }

    // Afficher erreur si échec
    if (!success && mounted) {
      final error = ref.read(vaultNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? "Erreur lors de l'activation"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );

    if ((result ?? false) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe modifié avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deactivateVault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeactivateVaultDialog(),
    );

    if ((confirm ?? false) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vault désactivé'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final vaultState = ref.watch(vaultNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text('Sécurité', style: AppTextStyles.h3(color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: vaultState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vault section
                  Text('Vault', style: AppTextStyles.h4(color: textColor)),
                  const SizedBox(height: 8),
                  Text(
                    'Chiffrez vos données sensibles avec un mot de passe maître',
                    style: AppTextStyles.bodySmall(color: subtitleColor),
                  ),
                  const SizedBox(height: 16),

                  if (!vaultState.isEnabled) ...[
                    // Vault not enabled
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SettingsSectionTile(
                        icon: Icons.shield_outlined,
                        title: 'Activer le Vault',
                        subtitle: 'Protégez vos données avec un chiffrement E2EE',
                        onTap: _activateVault,
                      ),
                    ),
                  ] else ...[
                    // Vault enabled
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vault actif', style: AppTextStyles.labelLarge(color: textColor)),
                                Text(
                                  'Vos données sont chiffrées',
                                  style: AppTextStyles.bodySmall(color: subtitleColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Biometry toggle
                          if (vaultState.isBiometryAvailable)
                            _buildSwitchTile(
                              icon: Icons.fingerprint,
                              title: 'Déverrouillage biométrique',
                              subtitle: 'Face ID / Touch ID / Empreinte',
                              value: vaultState.isBiometryEnabled,
                              onChanged: _toggleBiometry,
                              isDark: isDark,
                            ),

                          if (vaultState.isBiometryAvailable)
                            Divider(
                              height: 1,
                              indent: 70,
                              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                            ),

                          // Change password
                          SettingsSectionTile(
                            icon: Icons.key,
                            title: 'Changer le mot de passe',
                            subtitle: 'Modifier votre mot de passe maître',
                            onTap: _changePassword,
                          ),

                          Divider(
                            height: 1,
                            indent: 70,
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          ),

                          // Deactivate vault
                          SettingsSectionTile(
                            icon: Icons.shield_outlined,
                            iconColor: AppColors.error,
                            title: 'Désactiver le Vault',
                            subtitle: 'Supprimer le chiffrement',
                            onTap: _deactivateVault,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: AppTextStyles.labelLarge(color: textColor)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall(color: subtitleColor)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

/// Dialog pour changer le mot de passe.
class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
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
      setState(() => _error = 'Le nouveau mot de passe doit contenir au moins 8 caractères');
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

    final success = await ref.read(vaultNotifierProvider.notifier).changeMasterPassword(current, newPass);

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
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('Changer le mot de passe', style: AppTextStyles.h4(color: textColor)),
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
              Text(_error!, style: AppTextStyles.bodySmall(color: AppColors.error)),
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

/// Dialog pour désactiver le Vault.
class _DeactivateVaultDialog extends ConsumerStatefulWidget {
  const _DeactivateVaultDialog();

  @override
  ConsumerState<_DeactivateVaultDialog> createState() => _DeactivateVaultDialogState();
}

class _DeactivateVaultDialogState extends ConsumerState<_DeactivateVaultDialog> {
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

    final success = await ref.read(vaultNotifierProvider.notifier).deactivate(_passwordController.text);

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
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('Désactiver le Vault', style: AppTextStyles.h4(color: textColor)),
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
            Text(_error!, style: AppTextStyles.bodySmall(color: AppColors.error)),
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
