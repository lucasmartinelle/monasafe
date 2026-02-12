import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/core/utils/focus_node_mixin.dart';

/// Champ de saisie texte simple et standardisé.
///
/// Version plus légère que AppTextInput, sans effet glass.
/// Utilisé pour les formulaires standards.
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

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final VoidCallback? onSuffixTap;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFocusChanged;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool filled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> with FocusNodeMixin {
  @override
  void initState() {
    super.initState();
    initFocusNode(widget.focusNode);
  }

  @override
  void dispose() {
    disposeFocusNode(widget.focusNode);
    super.dispose();
  }

  @override
  void onFocusChange(bool hasFocus) {
    widget.onFocusChanged?.call(hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = context.textHint;
    final borderColor = context.dividerColor;

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
      focusNode: focusNode,
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
      style: AppTextStyles.bodyMedium(color: context.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.bodyMedium(color: hintColor),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: widget.filled,
        fillColor: context.surfaceColor,
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
            style: AppTextStyles.labelMedium(color: context.textSecondary),
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

  final TextEditingController? controller;
  final String currency;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
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
          style: AppTextStyles.h4(color: context.textSecondary),
        ),
      ),
    );
  }
}
