import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/common_widgets.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';

/// Écran de gestion du compte.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _isLinkingInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Quand l'app revient au premier plan après OAuth linking
    if (state == AppLifecycleState.resumed && _isLinkingInProgress) {
      // Petit délai pour laisser Supabase traiter le callback
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _checkAndUpdateGoogleLinkStatus();
        }
      });
    }
  }

  Future<void> _checkAndUpdateGoogleLinkStatus() async {
    _isLinkingInProgress = false;

    // Invalider le provider pour forcer un refresh
    ref.invalidate(hasGoogleIdentityProvider);

    // Vérifier si le linking a réussi
    final authService = ref.read(authServiceProvider);
    final hasGoogle = await authService.fetchHasGoogleProvider();

    if (hasGoogle) {
      // Mettre à jour le flag isAnonymous
      final settingsRepo = ref.read(settingsRepositoryProvider);
      await settingsRepo.setIsAnonymous(false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte Google lié avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else if (mounted) {
      // Le linking a échoué - proposer de changer de compte
      await _showIdentityConflictDialog();
    }
  }

  Future<void> _linkWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      // Marquer qu'on est en train de lier pour gérer le retour OAuth
      _isLinkingInProgress = true;

      await authService.linkWithGoogle();
      // Note: Le flow OAuth ouvre un navigateur externe.
      // Le résultat sera géré dans didChangeAppLifecycleState quand l'app reprend.
    } catch (e) {
      _isLinkingInProgress = false;

      // Vérifier si c'est une erreur "identity already linked"
      final errorStr = e.toString();
      if (errorStr.contains('identity_already_exists') ||
          errorStr.contains('Identity is already linked')) {
        if (mounted) {
          await _showIdentityConflictDialog();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Affiche un dialogue quand la liaison Google a échoué.
  /// Propose de se connecter directement avec le compte Google existant.
  Future<void> _showIdentityConflictDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Liaison impossible',
          style: AppTextStyles.h4(color: textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La liaison avec ce compte Google a échoué.\n\n'
              'Cela peut arriver si ce compte Google est déjà associé à un autre compte SimpleFlow.',
              style: AppTextStyles.bodyMedium(color: textColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Vous pouvez vous connecter directement avec votre compte Google pour accéder à vos données synchronisées.',
              style: AppTextStyles.bodySmall(color: subtitleColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text('Garder le compte local', style: TextStyle(color: subtitleColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'switch'),
            child: const Text(
              'Utiliser le compte Google',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (choice == 'switch' && mounted) {
      await _switchToGoogleAccount();
    }
  }

  /// Déconnecte le compte local et se connecte avec Google.
  /// Les données locales resteront liées à l'ancien compte anonyme.
  Future<void> _switchToGoogleAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Confirmer le changement',
            style: AppTextStyles.h4(color: textColor),
          ),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Attention, vos données seront perdues.',
                  style: AppTextStyles.bodyMedium(color: AppColors.error).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '\n\nVous allez être connecté à votre compte Google existant avec ses propres données.',
                  style: AppTextStyles.bodyMedium(color: textColor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Annuler', style: TextStyle(color: textColor)),
            ),
            AppButton(
              label: 'Confirmer',
              onPressed: () => Navigator.pop(context, true),
              size: AppButtonSize.small,
            ),
          ],
        );
      },
    );

    if ((confirm ?? false) && mounted) {
      setState(() => _isLoading = true);

      try {
        final authService = ref.read(authServiceProvider);

        // Déconnecter le compte local
        await authService.signOut();

        // Se connecter avec Google
        await authService.signInWithGoogle();

        // Invalider les providers pour forcer le refresh
        ref.invalidate(onboardingCompletedStreamProvider);
        ref.invalidate(hasGoogleIdentityProvider);

        // Fermer les écrans pour revenir à la racine
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('Déconnexion', style: AppTextStyles.h4(color: textColor)),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?\n\n'
            'Vos données resteront synchronisées et vous pourrez vous reconnecter à tout moment.',
            style: AppTextStyles.bodyMedium(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Annuler', style: TextStyle(color: textColor)),
            ),
            AppButton(
              label: 'Déconnexion',
              onPressed: () => Navigator.pop(context, true),
              size: AppButtonSize.small,
            ),
          ],
        );
      },
    );

    if ((confirm ?? false) && mounted) {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      // Invalider les providers pour forcer la navigation vers onboarding
      ref.invalidate(onboardingCompletedStreamProvider);
      ref.invalidate(hasGoogleIdentityProvider);

      // Fermer tous les écrans et revenir à la racine
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final hasGoogleAsync = ref.watch(hasGoogleIdentityProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text('Compte', style: AppTextStyles.h3(color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: hasGoogleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildContent(
          context,
          hasGoogle: false,
          userEmail: user?.email,
          isDark: isDark,
          backgroundColor: backgroundColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          cardColor: cardColor,
        ),
        data: (hasGoogle) => _buildContent(
          context,
          hasGoogle: hasGoogle,
          userEmail: user?.email,
          isDark: isDark,
          backgroundColor: backgroundColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          cardColor: cardColor,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool hasGoogle,
    required String? userEmail,
    required bool isDark,
    required Color backgroundColor,
    required Color textColor,
    required Color subtitleColor,
    required Color cardColor,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasGoogle ? Icons.person : Icons.person_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasGoogle
                            ? (userEmail ?? 'Connecté avec Google')
                            : 'Compte local',
                        style: AppTextStyles.labelLarge(color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasGoogle
                            ? 'Synchronisé avec Google'
                            : 'Données liées à cet appareil uniquement',
                        style: AppTextStyles.bodySmall(color: subtitleColor),
                      ),
                    ],
                  ),
                ),
                if (hasGoogle)
                  const Icon(Icons.check_circle, color: AppColors.success, size: 24),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Connect with Google (only for local users without Google)
          if (!hasGoogle) ...[
            Text('Synchronisation', style: AppTextStyles.h4(color: textColor)),
            const SizedBox(height: 8),
            Text(
              'Connectez votre compte Google pour synchroniser vos données sur tous vos appareils.',
              style: AppTextStyles.bodySmall(color: subtitleColor),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'G',
                            style: AppTextStyles.h4(
                              color: const Color(0xFF4285F4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Se connecter avec Google',
                              style: AppTextStyles.labelLarge(color: textColor),
                            ),
                            Text(
                              'Sauvegarde automatique, multi-appareils',
                              style: AppTextStyles.bodySmall(color: subtitleColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Connecter Google',
                    onPressed: _isLoading ? null : _linkWithGoogle,
                    isLoading: _isLoading,
                    fullWidth: true,
                    icon: Icons.login,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Sans connexion Google, vos données seront perdues si vous désinstallez l'application ou changez d'appareil.",
                      style: AppTextStyles.bodySmall(color: subtitleColor),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (hasGoogle) ...[
            const SizedBox(height: 24),
            AppButton(
              label: 'Déconnexion',
              onPressed: _signOut,
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              icon: Icons.logout,
            ),
          ],
        ],
      ),
    );
  }
}
