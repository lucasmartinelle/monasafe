import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';

/// Champ de saisie texte avec style "Glass" (fond semi-transparent).
///
/// Supporte la gestion des erreurs, labels, préfixes/suffixes et icônes.
///
/// ```dart
/// AppTextInput(
///   label: 'Email',
///   hint: 'exemple@mail.com',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   errorText: emailError,
/// )
/// ```
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

  /// Contrôleur pour le champ de texte
  final TextEditingController? controller;

  /// Label affiché au-dessus du champ
  final String? label;

  /// Texte d'indication affiché quand le champ est vide
  final String? hint;

  /// Message d'erreur affiché sous le champ
  final String? errorText;

  /// Texte d'aide affiché sous le champ (si pas d'erreur)
  final String? helperText;

  /// Icône affichée à gauche
  final IconData? prefixIcon;

  /// Icône affichée à droite
  final IconData? suffixIcon;

  /// Callback appelé lors du tap sur l'icône suffix
  final VoidCallback? onSuffixIconTap;

  /// Masque le texte (pour les mots de passe)
  final bool obscureText;

  /// Active/désactive le champ
  final bool enabled;

  /// Lecture seule
  final bool readOnly;

  /// Focus automatique au montage
  final bool autofocus;

  /// Type de clavier
  final TextInputType? keyboardType;

  /// Action du bouton de validation du clavier
  final TextInputAction? textInputAction;

  /// Formateurs de saisie
  final List<TextInputFormatter>? inputFormatters;

  /// Nombre maximum de lignes
  final int maxLines;

  /// Nombre minimum de lignes
  final int? minLines;

  /// Longueur maximale
  final int? maxLength;

  /// Callback appelé lors de changements
  final ValueChanged<String>? onChanged;

  /// Callback appelé lors de la soumission
  final ValueChanged<String>? onSubmitted;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  /// Nœud de focus
  final FocusNode? focusNode;

  /// Alignement du texte
  final TextAlign textAlign;

  /// Capitalisation du texte
  final TextCapitalization textCapitalization;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBorderColor(isDark),
                  width: _isFocused ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
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
                  color: widget.enabled
                      ? (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
                      : (isDark
                          ? AppColors.textHintDark
                          : AppColors.textHintLight),
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTextStyles.bodyMedium(
                    color: isDark
                        ? AppColors.textHintDark
                        : AppColors.textHintLight,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _getIconColor(isDark),
                          size: 20,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: widget.onSuffixIconTap,
                          child: Icon(
                            widget.suffixIcon,
                            color: _getIconColor(isDark),
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
        ),
        if (_hasError || widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            _hasError ? widget.errorText! : widget.helperText!,
            style: AppTextStyles.caption(
              color: _hasError
                  ? AppColors.error
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ],
      ],
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (!widget.enabled) {
      return isDark
          ? AppColors.surfaceDark.withValues(alpha: 0.3)
          : AppColors.surfaceLight.withValues(alpha: 0.3);
    }
    return isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.6)
        : AppColors.surfaceLight.withValues(alpha: 0.7);
  }

  Color _getBorderColor(bool isDark) {
    if (_hasError) {
      return AppColors.error;
    }
    if (_isFocused) {
      return AppColors.primary;
    }
    if (!widget.enabled) {
      return isDark
          ? AppColors.dividerDark.withValues(alpha: 0.5)
          : AppColors.dividerLight.withValues(alpha: 0.5);
    }
    return isDark ? AppColors.dividerDark : AppColors.dividerLight;
  }

  Color _getIconColor(bool isDark) {
    if (_isFocused) {
      return AppColors.primary;
    }
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  }
}
