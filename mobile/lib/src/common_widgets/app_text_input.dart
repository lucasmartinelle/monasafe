import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:monasafe/src/common_widgets/glass_effect.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/core/utils/focus_node_mixin.dart';

/// Champ de saisie texte avec style "Glass" (fond semi-transparent).
///
/// Supporte la gestion des erreurs, labels, préfixes/suffixes et icônes.
class AppTextInput extends StatefulWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> with FocusNodeMixin {
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

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium(color: context.textPrimary),
          ),
          const SizedBox(height: 8),
        ],
        GlassEffect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBorderColor(context),
                  width: hasFocus ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: focusNode,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
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
                style: AppTextStyles.bodyMedium(
                  color: widget.enabled ? context.textPrimary : context.textHint,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTextStyles.bodyMedium(color: context.textHint),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _getIconColor(context),
                          size: 20,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: widget.onSuffixIconTap,
                          child: Icon(
                            widget.suffixIcon,
                            color: _getIconColor(context),
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  counterText: '',
                ),
              ),
            ),
          ),
        if (_hasError || widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            _hasError ? widget.errorText! : widget.helperText!,
            style: AppTextStyles.caption(
              color: _hasError ? AppColors.error : context.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (!widget.enabled) {
      return context.surfaceColor.withValues(alpha: 0.3);
    }
    return context.surfaceColor.withValues(alpha: context.isDark ? 0.6 : 0.7);
  }

  Color _getBorderColor(BuildContext context) {
    if (_hasError) return AppColors.error;
    if (hasFocus) return AppColors.primary;
    if (!widget.enabled) {
      return context.dividerColor.withValues(alpha: 0.5);
    }
    return context.dividerColor;
  }

  Color _getIconColor(BuildContext context) {
    if (hasFocus) return AppColors.primary;
    return context.textSecondary;
  }
}
