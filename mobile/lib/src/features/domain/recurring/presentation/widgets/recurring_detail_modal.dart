import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/recurring_form_provider.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/widgets/recurring_detail_action_buttons.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/widgets/recurring_detail_amount_section.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/widgets/recurring_detail_header.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/widgets/recurring_detail_info_section.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/widgets/recurring_detail_note_field.dart';

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
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final formState = ref.watch(recurringFormNotifierProvider);
    final mediaQuery = MediaQuery.of(context);

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

            // Header
            RecurringDetailHeader(
              category: widget.recurring.category,
              accountName: widget.recurring.account.name,
              isActive: formState?.isActive ?? true,
              onClose: () => Navigator.of(context).pop(),
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
                        style: AppTextStyles.labelMedium(
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      RecurringDetailAmountSection(
                        displayAmount:
                            formState?.displayAmount ?? '0,00',
                        amountCents: formState?.amountCents ?? 0,
                        showKeypad: _showKeypad,
                        onTap: _toggleKeypad,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),

                      // Informations
                      RecurringDetailInfoSection(
                        recurring: widget.recurring,
                        formEndDate: formState?.endDate,
                        formIsActive: formState?.isActive ?? true,
                        onSelectEndDate: _selectEndDate,
                        onClearEndDate: _clearEndDate,
                      ),

                      // Note
                      const SizedBox(height: 16),
                      RecurringDetailNoteField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        onChanged: (value) {
                          ref
                              .read(recurringFormNotifierProvider.notifier)
                              .setNote(value);
                        },
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
            RecurringDetailActionButtons(
              isValid: formState?.isValid ?? false,
              isBusy: formState?.isBusy ?? false,
              isLoading: formState?.isLoading ?? false,
              isToggling: formState?.isToggling ?? false,
              isDeleting: formState?.isDeleting ?? false,
              isActive: formState?.isActive ?? false,
              onUpdate: _handleUpdate,
              onToggle: _handleToggle,
              onDelete: _handleDelete,
            ),
          ],
        ),
      ),
    );
  }
}
