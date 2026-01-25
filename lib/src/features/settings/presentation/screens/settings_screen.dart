import 'package:flutter/material.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';

/// Placeholder screen for settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Réglages',
                style: AppTextStyles.h2(color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon',
                style: AppTextStyles.bodyMedium(color: subtitleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
