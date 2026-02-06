import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Service de chiffrement bas niveau (AES-GCM + PBKDF2).
///
/// Utilise le package `cryptography` pour des implémentations sécurisées de:
/// - PBKDF2-HMAC-SHA256 pour la dérivation de clé
/// - AES-256-GCM pour le chiffrement authentifié
class EncryptionService {
  static const int _saltLength = 32;
  static const int _keyLength = 32; // 256 bits
  static const int _pbkdf2Iterations = 100000;

  final _aesGcm = AesGcm.with256bits();

  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: _keyLength * 8,
  );

  /// Génère un salt aléatoire cryptographiquement sûr.
  Uint8List generateSalt() {
    final secretKey = SecretKeyData.random(length: _saltLength);
    return Uint8List.fromList(secretKey.bytes);
  }

  /// Génère une clé aléatoire (DEK - Data Encryption Key).
  Uint8List generateDEK() {
    final secretKey = SecretKeyData.random(length: _keyLength);
    return Uint8List.fromList(secretKey.bytes);
  }

  /// Dérive une clé (KEK) à partir du master password et du salt.
  Future<Uint8List> deriveKEK(String masterPassword, Uint8List salt) async {
    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(masterPassword)),
      nonce: salt,
    );
    final bytes = await secretKey.extractBytes();
    return Uint8List.fromList(bytes);
  }

  /// Chiffre des données avec AES-GCM.
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List key) async {
    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: SecretKey(key),
    );
    // Format: nonce (12) + ciphertext + mac (16)
    return Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
  }

  /// Déchiffre des données avec AES-GCM.
  Future<Uint8List> decrypt(Uint8List ciphertext, Uint8List key) async {
    const nonceLength = 12;
    const macLength = 16;

    final nonce = ciphertext.sublist(0, nonceLength);
    final mac = Mac(ciphertext.sublist(ciphertext.length - macLength));
    final encrypted = ciphertext.sublist(nonceLength, ciphertext.length - macLength);

    final secretBox = SecretBox(encrypted, nonce: nonce, mac: mac);
    final decrypted = await _aesGcm.decrypt(secretBox, secretKey: SecretKey(key));

    return Uint8List.fromList(decrypted);
  }

  /// Chiffre une chaîne et retourne du Base64.
  Future<String> encryptString(String plaintext, Uint8List key) async {
    final encrypted = await encrypt(Uint8List.fromList(utf8.encode(plaintext)), key);
    return base64Encode(encrypted);
  }

  /// Déchiffre une chaîne Base64.
  Future<String> decryptString(String ciphertext, Uint8List key) async {
    final decrypted = await decrypt(base64Decode(ciphertext), key);
    return utf8.decode(decrypted);
  }

  /// Chiffre la DEK avec la KEK.
  Future<String> encryptDEK(Uint8List dek, Uint8List kek) async {
    final encrypted = await encrypt(dek, kek);
    return base64Encode(encrypted);
  }

  /// Déchiffre la DEK avec la KEK.
  Future<Uint8List> decryptDEK(String encryptedDEK, Uint8List kek) async {
    return decrypt(base64Decode(encryptedDEK), kek);
  }

  /// Encode un salt en Base64.
  String encodeSalt(Uint8List salt) => base64Encode(salt);

  /// Décode un salt depuis Base64.
  Uint8List decodeSalt(String salt) => base64Decode(salt);
}
