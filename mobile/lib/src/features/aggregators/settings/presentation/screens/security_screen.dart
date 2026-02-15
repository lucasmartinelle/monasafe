import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/aggregators/settings/presentation/widgets/change_password_dialog.dart';
import 'package:monasafe/src/features/aggregators/settings/presentation/widgets/deactivate_vault_dialog.dart';
import 'package:monasafe/src/features/aggregators/settings/presentation/widgets/settings_section_tile.dart';
import 'package:monasafe/src/features/domain/vault/presentation/screens/vault_setup_screen.dart';
import 'package:monasafe/src/features/domain/vault/presentation/vault_providers.dart';

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
      builder: (context) => const ChangePasswordDialog(),
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
      builder: (context) => const DeactivateVaultDialog(),
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
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
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
                  Text('Vault', style: AppTextStyles.h4(color: textColor)),
                  const SizedBox(height: 8),
                  Text(
                    'Chiffrez vos données sensibles avec un mot de passe maître',
                    style: AppTextStyles.bodySmall(color: subtitleColor),
                  ),
                  const SizedBox(height: 16),

                  if (!vaultState.isEnabled) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SettingsSectionTile(
                        icon: Icons.shield_outlined,
                        title: 'Activer le Vault',
                        subtitle:
                            'Protégez vos données avec un chiffrement E2EE',
                        onTap: _activateVault,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vault actif',
                                  style: AppTextStyles.labelLarge(
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'Vos données sont chiffrées',
                                  style: AppTextStyles.bodySmall(
                                    color: subtitleColor,
                                  ),
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
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight,
                            ),

                          SettingsSectionTile(
                            icon: Icons.key,
                            title: 'Changer le mot de passe',
                            subtitle: 'Modifier votre mot de passe maître',
                            onTap: _changePassword,
                          ),

                          Divider(
                            height: 1,
                            indent: 70,
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight,
                          ),

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
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title:
          Text(title, style: AppTextStyles.labelLarge(color: textColor)),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall(color: subtitleColor),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}
