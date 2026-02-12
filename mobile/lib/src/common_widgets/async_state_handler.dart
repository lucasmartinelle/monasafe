import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';

/// Widget pour afficher un état vide avec icône et message.
///
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.receipt_long_outlined,
///   message: 'Aucune transaction',
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.message, super.key,
    this.icon,
    this.iconWidget,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.iconSize = 48,
    this.iconOpacity = 0.5,
  });

  /// Message principal
  final String message;

  /// Icône à afficher
  final IconData? icon;

  /// Widget d'icône personnalisé (prioritaire sur icon)
  final Widget? iconWidget;

  /// Message secondaire optionnel
  final String? subtitle;

  /// Bouton d'action optionnel
  final Widget? action;

  /// Padding autour du contenu
  final EdgeInsetsGeometry padding;

  /// Taille de l'icône
  final double iconSize;

  /// Opacité de l'icône
  final double iconOpacity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null || iconWidget != null) ...[
              iconWidget ??
                  Icon(
                    icon,
                    size: iconSize,
                    color: context.textSecondary.withValues(alpha: iconOpacity),
                  ),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              style: AppTextStyles.bodyMedium(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTextStyles.caption(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher un état de chargement.
///
/// ```dart
/// LoadingStateWidget()
/// // ou avec message
/// LoadingStateWidget(message: 'Chargement...')
/// ```
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    super.key,
    this.message,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.size = 24,
    this.strokeWidth = 2,
    this.color,
  });

  /// Message optionnel sous le spinner
  final String? message;

  /// Padding autour du contenu
  final EdgeInsetsGeometry padding;

  /// Taille du spinner
  final double size;

  /// Épaisseur du trait
  final double strokeWidth;

  /// Couleur du spinner
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                color: color ?? AppColors.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: AppTextStyles.caption(color: context.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher un état d'erreur.
///
/// ```dart
/// ErrorStateWidget(
///   message: 'Erreur de chargement',
///   onRetry: () => ref.invalidate(myProvider),
/// )
/// ```
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.message = 'Une erreur est survenue',
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryLabel = 'Réessayer',
    this.padding = const EdgeInsets.symmetric(vertical: 24),
  });

  /// Message d'erreur
  final String message;

  /// Icône d'erreur
  final IconData icon;

  /// Callback pour réessayer
  final VoidCallback? onRetry;

  /// Libellé du bouton réessayer
  final String retryLabel;

  /// Padding autour du contenu
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget pour gérer facilement les états async (loading, error, data, empty).
///
/// Fonctionne avec AsyncValue de Riverpod.
///
/// ```dart
/// AsyncStateHandler<List<Transaction>>(
///   value: transactionsAsync,
///   emptyCheck: (data) => data.isEmpty,
///   emptyWidget: EmptyStateWidget(
///     icon: Icons.receipt_long_outlined,
///     message: 'Aucune transaction',
///   ),
///   builder: (data) => ListView.builder(...),
/// )
/// ```
class AsyncStateHandler<T> extends StatelessWidget {
  const AsyncStateHandler({
    required this.value, required this.builder, super.key,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyWidget,
    this.emptyCheck,
  });

  /// Valeur async de Riverpod
  final AsyncValue<T> value;

  /// Builder pour afficher les données
  final Widget Function(T data) builder;

  /// Widget de chargement personnalisé
  final Widget? loadingWidget;

  /// Builder pour l'erreur personnalisé
  final Widget Function(Object error, StackTrace stack)? errorBuilder;

  /// Widget pour l'état vide
  final Widget? emptyWidget;

  /// Fonction pour vérifier si les données sont vides
  final bool Function(T data)? emptyCheck;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loadingWidget ?? const LoadingStateWidget(),
      error: (error, stack) =>
          errorBuilder?.call(error, stack) ??
          const ErrorStateWidget(message: 'Erreur de chargement'),
      data: (data) {
        if (emptyCheck != null && emptyCheck!(data) && emptyWidget != null) {
          return emptyWidget!;
        }
        return builder(data);
      },
    );
  }
}
