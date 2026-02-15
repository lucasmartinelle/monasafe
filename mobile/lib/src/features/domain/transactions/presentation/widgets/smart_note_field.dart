import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/icon_label_tile.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';

/// Smart note field with autocomplete suggestions from transaction history.
///
/// Can be used in two modes:
/// 1. Connected to transactionFormNotifierProvider (default)
/// 2. Standalone with explicit initialValue, transactionType, and onChanged
class SmartNoteField extends ConsumerStatefulWidget {
  const SmartNoteField({
    super.key,
    this.onFocusChanged,
    this.initialValue,
    this.transactionType,
    this.onChanged,
  });

  /// Callback when focus state changes.
  final ValueChanged<bool>? onFocusChanged;

  /// Initial value for the text field. If null, defaults to empty.
  final String? initialValue;

  /// Transaction type for suggestions filtering. If null, reads from provider.
  final CategoryType? transactionType;

  /// Callback when text changes. If null, uses provider.
  final ValueChanged<String>? onChanged;

  @override
  ConsumerState<SmartNoteField> createState() => _SmartNoteFieldState();
}

class _SmartNoteFieldState extends ConsumerState<SmartNoteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _controller.text = widget.initialValue!;
      _lastQuery = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: _SuggestionsOverlay(
              query: _lastQuery,
              onSelect: _onSuggestionSelected,
              transactionType: widget.transactionType,
            ),
          ),
        ),
      ),
    );
  }

  void _onTextChanged(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    } else {
      ref.read(transactionFormNotifierProvider.notifier).setNote(value);
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _lastQuery != value) {
        _lastQuery = value;
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  void _onSuggestionSelected(TransactionWithDetails suggestion) {
    // Always apply full suggestion (category, amount, note) to provider
    ref.read(transactionFormNotifierProvider.notifier).applySuggestion(suggestion);

    // Also notify via callback if provided
    if (widget.onChanged != null) {
      widget.onChanged?.call(suggestion.transaction.note ?? '');
    }

    // Update the text field
    _controller.text = suggestion.transaction.note ?? '';
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );

    _removeOverlay();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textHintDark : AppColors.textHintLight;

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        style: AppTextStyles.bodyMedium(color: textColor),
        decoration: InputDecoration(
          hintText: 'Ajouter une note...',
          hintStyle: AppTextStyles.bodyMedium(color: hintColor),
          prefixIcon: Icon(
            Icons.note_alt_outlined,
            color: hintColor,
            size: 20,
          ),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SuggestionsOverlay extends ConsumerWidget {
  const _SuggestionsOverlay({
    required this.query,
    required this.onSelect,
    this.transactionType,
  });

  final String query;
  final ValueChanged<TransactionWithDetails> onSelect;
  final CategoryType? transactionType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = transactionType ??
        ref.watch(transactionFormNotifierProvider.select((s) => s.type));
    final suggestionsAsync = ref.watch(noteSuggestionsProvider(query, type!));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _SuggestionTile(
                  suggestion: suggestion,
                  onTap: () => onSelect(suggestion),
                );
              },
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.onTap,
  });

  final TransactionWithDetails suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final category = suggestion.category;
    final note = suggestion.transaction.note ?? '';
    final amount = suggestion.transaction.amount;
    final categoryColor = Color(category.color);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: IconLabelTile(
          iconWidget: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              IconMapper.getIcon(category.iconKey),
              size: 18,
              color: categoryColor,
            ),
          ),
          label: note,
          subtitle: category.name,
          trailing: Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.labelSmall(color: subtitleColor),
          ),
        ),
      ),
    );
  }
}
