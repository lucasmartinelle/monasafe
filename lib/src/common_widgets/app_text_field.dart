import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';

/// Champ de saisie texte simple et standardisé.
///
/// Version plus légère que AppTextInput, sans effet glass.
/// Utilisé pour les formulaires standards.
///
/// ```dart
/// AppTextField(
///   hint: 'Ajouter une note...',
///   prefixIcon: Icons.note_alt_outlined,
///   controller: noteController,
///   onChanged: (value) => setState(() => note = value),
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.suffixWidget,
    this.onSuffixTap,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onFocusChanged,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.borderRadius = 12,
    this.contentPadding,
    this.filled = true,
  });

  /// Contrôleur pour le champ de texte
  final TextEditingController? controller;

  /// Texte d'indication
  final String? hint;

  /// Label au-dessus du champ
  final String? label;

  /// Icône préfixe
  final IconData? prefixIcon;

  /// Widget préfixe personnalisé
  final Widget? prefixWidget;

  /// Icône suffixe
  final IconData? suffixIcon;

  /// Widget suffixe personnalisé
  final Widget? suffixWidget;

  /// Callback sur tap du suffixe
  final VoidCallback? onSuffixTap;

  /// Champ activé
  final bool enabled;

  /// Lecture seule
  final bool readOnly;

  /// Focus automatique
  final bool autofocus;

  /// Masquer le texte
  final bool obscureText;

  /// Type de clavier
  final TextInputType? keyboardType;

  /// Action clavier
  final TextInputAction? textInputAction;

  /// Formateurs
  final List<TextInputFormatter>? inputFormatters;

  /// Lignes max
  final int maxLines;

  /// Lignes min
  final int? minLines;

  /// Longueur max
  final int? maxLength;

  /// Callback changement
  final ValueChanged<String>? onChanged;

  /// Callback soumission
  final ValueChanged<String>? onSubmitted;

  /// Callback tap
  final VoidCallback? onTap;

  /// Callback changement focus
  final ValueChanged<bool>? onFocusChanged;

  /// Nœud de focus
  final FocusNode? focusNode;

  /// Alignement texte
  final TextAlign textAlign;

  /// Capitalisation
  final TextCapitalization textCapitalization;

  /// Rayon des bords
  final double borderRadius;

  /// Padding du contenu
  final EdgeInsetsGeometry? contentPadding;

  /// Fond rempli
  final bool filled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textHintDark : AppColors.textHintLight;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    var prefix = widget.prefixWidget;
    if (prefix == null && widget.prefixIcon != null) {
      prefix = Icon(widget.prefixIcon, color: hintColor, size: 20);
    }

    var suffix = widget.suffixWidget;
    if (suffix == null && widget.suffixIcon != null) {
      suffix = GestureDetector(
        onTap: widget.onSuffixTap,
        child: Icon(widget.suffixIcon, color: hintColor, size: 20),
      );
    }

    final textField = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textAlign: widget.textAlign,
      textCapitalization: widget.textCapitalization,
      style: AppTextStyles.bodyMedium(color: textColor),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.bodyMedium(color: hintColor),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: widget.filled,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
        ),
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        counterText: '',
      ),
    );

    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          textField,
        ],
      );
    }

    return textField;
  }
}

/// Champ de saisie pour montant avec symbole de devise.
///
/// ```dart
/// CurrencyTextField(
///   controller: amountController,
///   currency: 'EUR',
///   onChanged: (value) => setState(() => amount = value),
/// )
/// ```
class CurrencyTextField extends StatelessWidget {
  const CurrencyTextField({
    super.key,
    this.controller,
    this.currency = 'EUR',
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.textAlign = TextAlign.end,
  });

  /// Contrôleur
  final TextEditingController? controller;

  /// Code devise
  final String currency;

  /// Texte d'indication
  final String? hint;

  /// Callback changement
  final ValueChanged<String>? onChanged;

  /// Callback soumission
  final ValueChanged<String>? onSubmitted;

  /// Focus automatique
  final bool autofocus;

  /// Alignement du texte
  final TextAlign textAlign;

  String get _currencySymbol {
    return switch (currency) {
      'EUR' => '\u20AC',
      'USD' => r'$',
      'GBP' => '\u00A3',
      'JPY' => '\u00A5',
      'CHF' => 'CHF',
      _ => currency,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTextField(
      controller: controller,
      hint: hint ?? '0,00',
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: textAlign,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
      ],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      suffixWidget: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Text(
          _currencySymbol,
          style: AppTextStyles.h4(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
