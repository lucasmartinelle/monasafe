import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/settings/presentation/widgets/settings_section_tile.dart';
import 'package:url_launcher/url_launcher.dart';

/// Écran À propos de l'application.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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

    final termsUrl = dotenv.env['TERMS_URL'];
    final privacyUrl = dotenv.env['PRIVACY_URL'];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'À propos',
          style: AppTextStyles.h3(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo et nom
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Monasafe',
              style: AppTextStyles.h2(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodySmall(color: subtitleColor),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Gérez vos finances personnelles simplement et efficacement.',
                style: AppTextStyles.bodyMedium(color: subtitleColor),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Crédits
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Crédits',
                      style: AppTextStyles.labelLarge(color: textColor),
                    ),
                  ),
                  SettingsSectionTile(
                    icon: Icons.code,
                    title: 'Développé par',
                    subtitle: 'Lucas MARTINELLE',
                    onTap: () => _launchUrl('https://luriel-dev.com/'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Liens légaux
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Informations légales',
                      style: AppTextStyles.labelLarge(color: textColor),
                    ),
                  ),
                  if (termsUrl != null && termsUrl.isNotEmpty)
                    SettingsSectionTile(
                      icon: Icons.description_outlined,
                      title: "Conditions générales d'utilisation",
                      onTap: () => _launchUrl(termsUrl),
                    ),
                  if (termsUrl != null && privacyUrl != null)
                    Divider(
                      height: 1,
                      indent: 70,
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  if (privacyUrl != null && privacyUrl.isNotEmpty)
                    SettingsSectionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Politique de confidentialité',
                      onTap: () => _launchUrl(privacyUrl),
                    ),
                  Divider(
                    height: 1,
                    indent: 70,
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  ),
                  SettingsSectionTile(
                    icon: Icons.email_outlined,
                    title: 'Nous contacter',
                    subtitle: 'lucasmar.martinelle@gmail.com',
                    onTap: () => _launchEmail('lucasmar.martinelle@gmail.com'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
