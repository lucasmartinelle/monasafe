import 'package:flutter/material.dart';

/// Mixin pour gérer les FocusNode de manière standardisée.
///
/// Gère automatiquement:
/// - L'initialisation du FocusNode (externe ou interne)
/// - L'ajout/suppression du listener
/// - Le disposal propre
///
/// ```dart
/// class _MyFieldState extends State<MyField> with FocusNodeMixin {
///   @override
///   void initState() {
///     super.initState();
///     initFocusNode(widget.focusNode);
///   }
///
///   @override
///   void dispose() {
///     disposeFocusNode(widget.focusNode);
///     super.dispose();
///   }
///
///   @override
///   void onFocusChange(bool hasFocus) {
///     widget.onFocusChanged?.call(hasFocus);
///   }
/// }
/// ```
mixin FocusNodeMixin<T extends StatefulWidget> on State<T> {
  late FocusNode _managedFocusNode;
  bool _hasFocus = false;

  /// Le FocusNode géré par ce mixin.
  FocusNode get focusNode => _managedFocusNode;

  /// Indique si le champ a le focus.
  bool get hasFocus => _hasFocus;

  /// Initialise le FocusNode.
  /// Si [externalFocusNode] est fourni, l'utilise. Sinon, crée un nouveau FocusNode.
  void initFocusNode(FocusNode? externalFocusNode) {
    _managedFocusNode = externalFocusNode ?? FocusNode();
    _managedFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    final newHasFocus = _managedFocusNode.hasFocus;
    if (_hasFocus != newHasFocus) {
      setState(() {
        _hasFocus = newHasFocus;
      });
      onFocusChange(newHasFocus);
    }
  }

  /// Appelé quand le focus change. À surcharger si besoin.
  void onFocusChange(bool hasFocus) {}

  /// Dispose le FocusNode.
  /// Passer le même [externalFocusNode] que celui fourni à [initFocusNode].
  void disposeFocusNode(FocusNode? externalFocusNode) {
    _managedFocusNode.removeListener(_handleFocusChange);
    if (externalFocusNode == null) {
      _managedFocusNode.dispose();
    }
  }
}
