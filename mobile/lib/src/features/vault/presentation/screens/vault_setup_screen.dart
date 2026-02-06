import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/common_widgets.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/features/vault/presentation/vault_providers.dart';

/// Écran d'activation du Vault.
class VaultSetupScreen extends ConsumerStatefulWidget {
  const VaultSetupScreen({super.key});

  @override
  ConsumerState<VaultSetupScreen> createState() => _VaultSetupScreenState();
}

class _VaultSetupScreenState extends ConsumerState<VaultSetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 8) {
      _showError('Le mot de passe doit contenir au moins 8 caractères');
      return;
    }

    if (password != confirm) {
      _showError('Les mots de passe ne correspondent pas');
      return;
    }

    final success = await ref.read(vaultNotifierProvider.notifier).activate(password);
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
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
        title: Text('Activer le Vault', style: AppTextStyles.h3(color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Text("Qu'est-ce que le Vault ?", style: AppTextStyles.h4(color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Le Vault chiffre vos données sensibles (montants et notes) avec un chiffrement de bout en bout (E2EE). '
                    'Seul vous pouvez déchiffrer vos données grâce à votre mot de passe maître.',
                    style: AppTextStyles.bodyMedium(color: subtitleColor),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.lock_outline, 'Chiffrement AES-256', subtitleColor),
                  _buildFeatureItem(Icons.fingerprint, 'Déverrouillage biométrique', subtitleColor),
                  _buildFeatureItem(Icons.sync_disabled, 'Données illisibles sans mot de passe', subtitleColor),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Si vous perdez votre mot de passe maître, vos données chiffrées seront '
                      "définitivement irrécupérables. Aucune récupération n'est possible.",
                      style: AppTextStyles.bodySmall(color: subtitleColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Password fields
            Text('Mot de passe maître', style: AppTextStyles.labelLarge(color: textColor)),
            const SizedBox(height: 8),
            AppTextField(
              controller: _passwordController,
              hint: 'Minimum 8 caractères',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
              onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
            ),

            const SizedBox(height: 16),

            Text('Confirmer le mot de passe', style: AppTextStyles.labelLarge(color: textColor)),
            const SizedBox(height: 8),
            AppTextField(
              controller: _confirmController,
              hint: 'Répétez le mot de passe',
              obscureText: _obscureConfirm,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureConfirm ? Icons.visibility_off : Icons.visibility,
              onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),

            if (vaultState.error != null) ...[
              const SizedBox(height: 16),
              Text(vaultState.error!, style: AppTextStyles.bodySmall(color: AppColors.error)),
            ],

            const SizedBox(height: 32),

            AppButton(
              label: 'Activer le Vault',
              onPressed: vaultState.isLoading ? null : _activate,
              isLoading: vaultState.isLoading,
              fullWidth: true,
              icon: Icons.shield,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodySmall(color: textColor)),
        ],
      ),
    );
  }
}
