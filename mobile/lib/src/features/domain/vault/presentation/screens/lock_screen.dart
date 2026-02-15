import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/vault/presentation/vault_providers.dart';

/// Écran de verrouillage du Vault.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key, this.onUnlocked});

  final VoidCallback? onUnlocked;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Try biometry unlock on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometryUnlock();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometryUnlock() async {
    final vaultState = ref.read(vaultNotifierProvider);
    if (vaultState.isBiometryEnabled) {
      final success = await ref.read(vaultNotifierProvider.notifier).unlockWithBiometry();
      if (success) {
        widget.onUnlocked?.call();
      }
    }
  }

  Future<void> _unlockWithPassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) return;

    final success = await ref.read(vaultNotifierProvider.notifier).unlock(password);
    if (success) {
      widget.onUnlocked?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final vaultState = ref.watch(vaultNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Lock icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              Text('Monasafe verrouillé', style: AppTextStyles.h2(color: textColor)),
              const SizedBox(height: 8),
              Text(
                'Entrez votre mot de passe maître pour déverrouiller',
                style: AppTextStyles.bodyMedium(color: subtitleColor),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Password field
              AppTextField(
                controller: _passwordController,
                hint: 'Mot de passe maître',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                onSubmitted: (_) => _unlockWithPassword(),
                textInputAction: TextInputAction.done,
              ),

              if (vaultState.error != null) ...[
                const SizedBox(height: 12),
                Text(vaultState.error!, style: AppTextStyles.bodySmall(color: AppColors.error)),
              ],

              const SizedBox(height: 24),

              AppButton(
                label: 'Déverrouiller',
                onPressed: vaultState.isLoading ? null : _unlockWithPassword,
                isLoading: vaultState.isLoading,
                fullWidth: true,
                icon: Icons.lock_open,
              ),

              if (vaultState.isBiometryEnabled) ...[
                const SizedBox(height: 16),
                AppButton(
                  label: 'Utiliser la biométrie',
                  onPressed: vaultState.isLoading ? null : _tryBiometryUnlock,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  icon: Icons.fingerprint,
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
