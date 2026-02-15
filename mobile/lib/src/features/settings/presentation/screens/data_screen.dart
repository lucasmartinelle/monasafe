import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/services/invalidation_service.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/settings/presentation/widgets/settings_section_tile.dart';

/// Écran de gestion des données utilisateur.
class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  bool _isDeleting = false;

  /// Rafraîchit tous les providers après une suppression de données.
  void _refreshProviders() {
    InvalidationService.onAllDataDeletedFromWidget(ref);
  }

  Future<void> _deleteAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteAllDataDialog(),
    );

    if ((confirm ?? false) && mounted) {
      setState(() => _isDeleting = true);

      try {
        final service = ref.read(dataManagementServiceProvider);
        await service.deleteAllUserData();

        _refreshProviders();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Toutes vos données ont été supprimées'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  Future<void> _deleteTransactions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteConfirmDialog(
        title: 'Supprimer les transactions',
        message:
            'Cette action supprimera toutes vos transactions. Cette action est irréversible.',
      ),
    );

    if ((confirm ?? false) && mounted) {
      setState(() => _isDeleting = true);

      try {
        final service = ref.read(dataManagementServiceProvider);
        await service.deleteAllTransactions();

        _refreshProviders();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transactions supprimées'),
              backgroundColor: AppColors.success,
            ),
          );
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
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  Future<void> _deleteRecurringTransactions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteConfirmDialog(
        title: 'Supprimer les récurrences',
        message:
            'Cette action supprimera toutes vos transactions récurrentes. Les transactions déjà générées seront conservées.',
      ),
    );

    if ((confirm ?? false) && mounted) {
      setState(() => _isDeleting = true);

      try {
        final service = ref.read(dataManagementServiceProvider);
        await service.deleteAllRecurringTransactions();

        _refreshProviders();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Récurrences supprimées'),
              backgroundColor: AppColors.success,
            ),
          );
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
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  Future<void> _deleteBudgets() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteConfirmDialog(
        title: 'Supprimer les budgets',
        message: 'Cette action supprimera tous vos budgets configurés.',
      ),
    );

    if ((confirm ?? false) && mounted) {
      setState(() => _isDeleting = true);

      try {
        final service = ref.read(dataManagementServiceProvider);
        await service.deleteAllBudgets();

        _refreshProviders();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budgets supprimés'),
              backgroundColor: AppColors.success,
            ),
          );
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
          setState(() => _isDeleting = false);
        }
      }
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Données',
          style: AppTextStyles.h3(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section suppression sélective
                  Text('Suppression sélective',
                      style: AppTextStyles.h4(color: textColor)),
                  const SizedBox(height: 8),
                  Text(
                    'Supprimez certaines catégories de données',
                    style: AppTextStyles.bodySmall(color: subtitleColor),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SettingsSectionTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'Supprimer les transactions',
                          subtitle: 'Efface toutes vos transactions',
                          onTap: _deleteTransactions,
                        ),
                        Divider(
                          height: 1,
                          indent: 70,
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                        SettingsSectionTile(
                          icon: Icons.repeat,
                          title: 'Supprimer les récurrences',
                          subtitle: 'Efface les transactions récurrentes',
                          onTap: _deleteRecurringTransactions,
                        ),
                        Divider(
                          height: 1,
                          indent: 70,
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                        SettingsSectionTile(
                          icon: Icons.pie_chart_outline,
                          title: 'Supprimer les budgets',
                          subtitle: 'Efface vos budgets configurés',
                          onTap: _deleteBudgets,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section zone de danger
                  Text('Zone de danger',
                      style: AppTextStyles.h4(color: AppColors.error)),
                  const SizedBox(height: 8),
                  Text(
                    'Actions irréversibles',
                    style: AppTextStyles.bodySmall(color: subtitleColor),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: SettingsSectionTile(
                      icon: Icons.delete_forever,
                      iconColor: AppColors.error,
                      title: 'Supprimer toutes mes données',
                      subtitle:
                          'Efface transactions, comptes, catégories et budgets',
                      onTap: _deleteAllData,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Dialog de confirmation générique.
class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(title, style: AppTextStyles.h4(color: textColor)),
      content:
          Text(message, style: AppTextStyles.bodyMedium(color: subtitleColor)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Annuler', style: TextStyle(color: textColor)),
        ),
        AppButton(
          label: 'Supprimer',
          onPressed: () => Navigator.pop(context, true),
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}

/// Dialog pour supprimer toutes les données.
class _DeleteAllDataDialog extends StatefulWidget {
  const _DeleteAllDataDialog();

  @override
  State<_DeleteAllDataDialog> createState() => _DeleteAllDataDialogState();
}

class _DeleteAllDataDialogState extends State<_DeleteAllDataDialog> {
  final _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _canDelete = _controller.text == 'SUPPRIMER';
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Supprimer toutes les données',
                style: AppTextStyles.h4(color: textColor)),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette action est irréversible. Toutes vos données seront définitivement supprimées :',
              style: AppTextStyles.bodyMedium(color: subtitleColor),
            ),
            const SizedBox(height: 12),
            Text('• Transactions',
                style: AppTextStyles.bodySmall(color: textColor)),
            Text('• Comptes', style: AppTextStyles.bodySmall(color: textColor)),
            Text('• Catégories personnalisées',
                style: AppTextStyles.bodySmall(color: textColor)),
            Text('• Budgets', style: AppTextStyles.bodySmall(color: textColor)),
            Text('• Récurrences',
                style: AppTextStyles.bodySmall(color: textColor)),
            const SizedBox(height: 16),
            Text(
              'Tapez SUPPRIMER pour confirmer :',
              style: AppTextStyles.bodySmall(color: subtitleColor),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _controller,
              hint: 'SUPPRIMER',
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
          label: 'Supprimer tout',
          onPressed: _canDelete ? () => Navigator.pop(context, true) : null,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
