import 'dart:typed_data';

import 'package:simpleflow/src/core/services/encryption_service.dart';

/// Middleware de chiffrement pour les transactions.
///
/// Chiffre les champs sensibles (amount, note) avant insertion
/// et les déchiffre après récupération.
class VaultMiddleware {
  VaultMiddleware(this._encryptionService, this._dek);

  final EncryptionService _encryptionService;
  final Uint8List _dek;

  /// Chiffre un montant et retourne le Base64.
  Future<String> encryptAmount(double amount) {
    return _encryptionService.encryptString(amount.toString(), _dek);
  }

  /// Déchiffre un montant Base64 et retourne le double.
  Future<double> decryptAmount(String encrypted) async {
    final amountStr = await _encryptionService.decryptString(encrypted, _dek);
    return double.parse(amountStr);
  }

  /// Chiffre une note et retourne le Base64 (ou null si note null/vide).
  Future<String?> encryptNote(String? note) async {
    if (note == null || note.isEmpty) return null;
    return _encryptionService.encryptString(note, _dek);
  }

  /// Déchiffre une note Base64 et retourne le texte (ou null si null/vide).
  Future<String?> decryptNote(String? encrypted) async {
    if (encrypted == null || encrypted.isEmpty) return null;
    return _encryptionService.decryptString(encrypted, _dek);
  }

  /// Chiffre les données sensibles d'une transaction.
  Future<({String encryptedAmount, String? encryptedNote})> encryptTransactionData(
    double amount,
    String? note,
  ) async {
    return (
      encryptedAmount: await encryptAmount(amount),
      encryptedNote: await encryptNote(note),
    );
  }

  /// Déchiffre les données sensibles d'une transaction.
  Future<({double amount, String? note})> decryptTransactionData(
    String encryptedAmount,
    String? encryptedNote,
  ) async {
    return (
      amount: await decryptAmount(encryptedAmount),
      note: await decryptNote(encryptedNote),
    );
  }
}
