import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/recurring/presentation/recurring_form_provider.dart';
import 'package:monasafe/src/features/recurring/presentation/recurring_providers.dart';
import 'package:monasafe/src/features/transactions/transactions.dart';

/// Resultat de l'action effectuee dans la modal.
enum RecurringDetailResult { updated, deleted, toggled }

/// Modal pour afficher les details d'une recurrence, la modifier ou la supprimer.
class RecurringDetailModal extends ConsumerStatefulWidget {
  const RecurringDetailModal({
    required this.recurring,
    super.key,
  });

  final RecurringTransactionWithDetails recurring;

  /// Affiche la modal de detail de la recurrence.
  static Future<RecurringDetailResult?> show(
    BuildContext context,
    RecurringTransactionWithDetails recurring,
  ) {
    return showModalBottomSheet<RecurringDetailResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecurringDetailModal(recurring: recurring),
    );
  }

  @override
  ConsumerState<RecurringDetailModal> createState() =>
      _RecurringDetailModalState();
}

class _RecurringDetailModalState extends ConsumerState<RecurringDetailModal> {
  bool _showKeypad = false;
  late final TextEditingController _noteController;
  final FocusNode _noteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.recurring.recurring.note ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recurringFormNotifierProvider.notifier)
          .loadFromRecurring(widget.recurring);
    });
  }

  void _toggleKeypad() {
    setState(() {
      _showKeypad = !_showKeypad;
    });
  }

  void _hideKeypad() {
    if (_showKeypad) {
      setState(() {
        _showKeypad = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final success =
        await ref.read(recurringFormNotifierProvider.notifier).update();
    if (success && mounted) {
      Navigator.of(context).pop(RecurringDetailResult.updated);
    }
  }

  Future<void> _handleToggle() async {
    final formState = ref.read(recurringFormNotifierProvider);
    final isCurrentlyActive = formState?.isActive ?? true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isCurrentlyActive ? 'Desactiver' : 'Reactiver'),
        content: Text(
          isCurrentlyActive
              ? 'Voulez-vous desactiver cette recurrence ? Les transactions existantes seront conservees.'
              : 'Voulez-vous reactiver cette recurrence ? Les prochaines occurrences seront generees automatiquement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(isCurrentlyActive ? 'Desactiver' : 'Reactiver'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success =
          await ref.read(recurringFormNotifierProvider.notifier).toggleActive();
      if (success && mounted) {
        Navigator.of(context).pop(RecurringDetailResult.toggled);
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la recurrence'),
        content: Text(
          'Voulez-vous vraiment supprimer cette recurrence pour "${widget.recurring.category?.name ?? 'cette categorie'}" ?\n\nLes transactions deja generees seront conservees.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success =
          await ref.read(recurringFormNotifierProvider.notifier).delete();
      if (success && mounted) {
        Navigator.of(context).pop(RecurringDetailResult.deleted);
      }
    }
  }

  Future<void> _selectEndDate() async {
    final formState = ref.read(recurringFormNotifierProvider);
    if (formState == null) return;

    final now = DateTime.now();
    final initialDate = formState.endDate ?? now.add(const Duration(days: 30));

    // Utiliser rootNavigator pour avoir le contexte MaterialApp complet
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      ref.read(recurringFormNotifierProvider.notifier).setEndDate(picked);
    }
  }

  void _clearEndDate() {
    ref.read(recurringFormNotifierProvider.notifier).setEndDate(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final formState = ref.watch(recurringFormNotifierProvider);
    final category = widget.recurring.category;
    final account = widget.recurring.account;
    final rec = widget.recurring.recurring;
    final mediaQuery = MediaQuery.of(context);

    // Prochaine date - utilise l'etat du formulaire pour isActive
    final nextDate = formState != null
        ? calculateNextRecurringDate(rec.copyWith(isActive: formState.isActive))
        : calculateNextRecurringDate(rec);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header avec categorie
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 16),
              child: Row(
                children: [
                  if (category != null)
                    CategoryIcon.fromHex(
                      icon: IconMapper.getIcon(category.iconKey),
                      colorHex: category.color,
                    )
                  else
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: secondaryColor,
                        size: 22,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.name ?? 'Categorie supprimee',
                          style: AppTextStyles.h4(color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              account.name,
                              style: AppTextStyles.bodySmall(color: secondaryColor),
                            ),
                            if (!(formState?.isActive ?? true)) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Inactive',
                                  style: AppTextStyles.caption(
                                    color: AppColors.warning,
                                  ).copyWith(fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: secondaryColor),
                  ),
                ],
              ),
            ),

            // Contenu scrollable
            Flexible(
              child: GestureDetector(
                onTap: _hideKeypad,
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section montant
                      Text(
                        'Montant mensuel',
                        style: AppTextStyles.labelMedium(color: secondaryColor),
                      ),
                      const SizedBox(height: 12),

                      _AmountSection(
                        displayAmount: formState?.displayAmount ?? '0,00',
                        amountCents: formState?.amountCents ?? 0,
                        showKeypad: _showKeypad,
                        onTap: _toggleKeypad,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

                      // Informations
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Date de debut
                            _InfoRow(
                              label: 'Debut',
                              value: DateFormat('d MMMM yyyy', 'fr_FR')
                                  .format(rec.startDate),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),

                            // Jour du mois
                            _InfoRow(
                              label: 'Jour du mois',
                              value: 'Le ${rec.originalDay}',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),

                            // Prochaine date
                            _InfoRow(
                              label: 'Prochaine occurrence',
                              value: nextDate != null
                                  ? DateFormat('d MMMM yyyy', 'fr_FR')
                                      .format(nextDate)
                                  : 'Aucune',
                              isDark: isDark,
                            ),

                            // Date de fin (editable)
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date de fin',
                                  style: AppTextStyles.bodySmall(
                                    color: secondaryColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _selectEndDate,
                                  child: Row(
                                    children: [
                                      Text(
                                        formState?.endDate != null
                                            ? DateFormat('d MMM yyyy', 'fr_FR')
                                                .format(formState!.endDate!)
                                            : 'Non definie',
                                        style: AppTextStyles.bodySmall(
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (formState?.endDate != null)
                                        GestureDetector(
                                          onTap: _clearEndDate,
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: secondaryColor,
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: secondaryColor,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Note (editable)
                      const SizedBox(height: 16),
                      Text(
                        'Note',
                        style: AppTextStyles.labelMedium(color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        onChanged: (value) {
                          ref
                              .read(recurringFormNotifierProvider.notifier)
                              .setNote(value);
                        },
                        style: AppTextStyles.bodyMedium(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Ajouter une note...',
                          hintStyle: AppTextStyles.bodyMedium(
                            color: isDark
                                ? AppColors.textHintDark
                                : AppColors.textHintLight,
                          ),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Clavier numerique
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _showKeypad
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: NumericKeypad(
                        onDigit: ref
                            .read(recurringFormNotifierProvider.notifier)
                            .appendDigit,
                        onDelete: ref
                            .read(recurringFormNotifierProvider.notifier)
                            .deleteDigit,
                        onClear: ref
                            .read(recurringFormNotifierProvider.notifier)
                            .clearAmount,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Boutons d'action
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                12 + mediaQuery.padding.bottom,
              ),
              child: Column(
                children: [
                  // Bouton Modifier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (formState?.isValid ?? false) &&
                              formState?.isBusy != true
                          ? _handleUpdate
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.dividerLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: formState?.isLoading ?? false
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Modifier',
                              style: AppTextStyles.button(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bouton Activer/Desactiver
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed:
                          formState?.isBusy != true ? _handleToggle : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: formState?.isActive ?? false
                            ? AppColors.warning
                            : AppColors.success,
                        side: BorderSide(
                          color: formState?.isBusy ?? false
                              ? (isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight)
                              : (formState?.isActive ?? false
                                  ? AppColors.warning
                                  : AppColors.success),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: formState?.isToggling ?? false
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: formState?.isActive ?? false
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  formState?.isActive ?? false
                                      ? Icons.pause_circle_outline
                                      : Icons.play_circle_outline,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  formState?.isActive ?? false
                                      ? 'Desactiver'
                                      : 'Reactiver',
                                  style: AppTextStyles.button(
                                    color: formState?.isActive ?? false
                                        ? AppColors.warning
                                        : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bouton Supprimer
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed:
                          formState?.isBusy != true ? _handleDelete : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: formState?.isBusy ?? false
                              ? (isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight)
                              : AppColors.error,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: formState?.isDeleting ?? false
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delete_outline, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Supprimer',
                                  style:
                                      AppTextStyles.button(color: AppColors.error),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section d'affichage du montant cliquable.
class _AmountSection extends StatelessWidget {
  const _AmountSection({
    required this.displayAmount,
    required this.amountCents,
    required this.showKeypad,
    required this.onTap,
    required this.isDark,
  });

  final String displayAmount;
  final int amountCents;
  final bool showKeypad;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor =
        isDark ? AppColors.textHintDark : AppColors.textHintLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: showKeypad
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: showKeypad
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  displayAmount,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: amountCents == 0
                        ? textColor.withValues(alpha: 0.3)
                        : textColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\u20AC',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: amountCents == 0
                        ? textColor.withValues(alpha: 0.3)
                        : textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              showKeypad ? 'Tapez pour fermer' : 'Tapez pour modifier',
              style: AppTextStyles.caption(color: hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne d'information dans les details.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(color: secondaryColor),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall(color: textColor),
        ),
      ],
    );
  }
}
