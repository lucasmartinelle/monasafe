import 'dart:io';

import 'package:flutter/material.dart';
import 'package:monasafe/src/common_widgets/app_button.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';

/// Écran d'erreur plein écran avec détection réseau et bouton réessayer.
class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final Object error;
  final VoidCallback onRetry;

  bool get _isNetworkError {
    if (error is SocketException) return true;
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('connection refused') ||
        message.contains('network is unreachable');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final icon = _isNetworkError
        ? Icons.wifi_off_rounded
        : Icons.error_outline_rounded;
    final title = _isNetworkError
        ? 'Connexion perdue'
        : 'Une erreur est survenue';
    final subtitle = _isNetworkError
        ? 'Vérifiez votre connexion internet puis réessayez.'
        : "Un problème inattendu s'est produit. Veuillez réessayer.";

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: context.textHint,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTextStyles.h3(color: context.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Réessayer',
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
