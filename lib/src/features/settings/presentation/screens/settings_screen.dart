import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';
import 'package:simpleflow/src/features/settings/presentation/screens/about_screen.dart';
import 'package:simpleflow/src/features/settings/presentation/screens/account_screen.dart';
import 'package:simpleflow/src/features/settings/presentation/screens/categories_screen.dart';
import 'package:simpleflow/src/features/settings/presentation/screens/data_screen.dart';
import 'package:simpleflow/src/features/settings/presentation/screens/security_screen.dart';
import 'package:simpleflow/src/features/settings/presentation/widgets/settings_section_tile.dart';

/// Écran principal des paramètres.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final hasGoogleAsync = ref.watch(hasGoogleIdentityProvider);
    final hasGoogle = hasGoogleAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Réglages',
                style: AppTextStyles.h2(color: textColor),
              ),
              const SizedBox(height: 24),

              // Section Compte
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SettingsSectionTile(
                  icon: hasGoogle ? Icons.person : Icons.person_outline,
                  title: 'Compte',
                  subtitle: hasGoogle ? 'Connecté avec Google' : 'Compte local',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AccountScreen(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sections principales
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SettingsSectionTile(
                      icon: Icons.category_outlined,
                      title: 'Catégories',
                      subtitle: 'Gérer vos catégories de transactions',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const CategoriesScreen(),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 70,
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                    SettingsSectionTile(
                      icon: Icons.lock_outline,
                      title: 'Sécurité',
                      subtitle: 'Vault et chiffrement E2EE',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SecurityScreen(),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 70,
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                    SettingsSectionTile(
                      icon: Icons.storage_outlined,
                      title: 'Données',
                      subtitle: 'Bientôt disponible',
                      enabled: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const DataScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section À propos
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SettingsSectionTile(
                  icon: Icons.info_outline,
                  title: 'À propos',
                  subtitle: "Informations sur l'application",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
