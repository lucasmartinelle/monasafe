import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:monasafe/src/core/middleware/vault_middleware.dart';
import 'package:monasafe/src/core/services/encryption_service.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/data/services/transaction_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_providers.g.dart';

// ==================== CONSTANTS ====================

const String _kVaultEnabled = 'vault_enabled';
const String _kVaultSalt = 'vault_salt';
const String _kVaultDekEncrypted = 'vault_dek_encrypted';
const String _kVaultBiometryEnabled = 'vault_biometry_enabled';
const String _kSecureStorageDekKey = 'monasafe_vault_dek';

// ==================== STATE ====================

class VaultState {
  const VaultState({
    this.isEnabled = false,
    this.isLocked = true,
    this.isBiometryEnabled = false,
    this.isBiometryAvailable = false,
    this.isLoading = false,
    this.error,
  });

  final bool isEnabled;
  final bool isLocked;
  final bool isBiometryEnabled;
  final bool isBiometryAvailable;
  final bool isLoading;
  final String? error;

  bool get isUnlocked => isEnabled && !isLocked;

  VaultState copyWith({
    bool? isEnabled,
    bool? isLocked,
    bool? isBiometryEnabled,
    bool? isBiometryAvailable,
    bool? isLoading,
    String? error,
  }) {
    return VaultState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      isBiometryEnabled: isBiometryEnabled ?? this.isBiometryEnabled,
      isBiometryAvailable: isBiometryAvailable ?? this.isBiometryAvailable,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ==================== SERVICES ====================

@Riverpod(keepAlive: true)
EncryptionService encryptionService(Ref ref) {
  return EncryptionService();
}

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}

@Riverpod(keepAlive: true)
LocalAuthentication localAuth(Ref ref) {
  return LocalAuthentication();
}

// ==================== DEK IN MEMORY ====================

/// DEK (Data Encryption Key) en mémoire, disponible uniquement quand le vault est déverrouillé.
@Riverpod(keepAlive: true)
class DekInMemory extends _$DekInMemory {
  @override
  Uint8List? build() => null;

  void set(Uint8List dek) => state = dek;

  void clear() => state = null;
}

// ==================== VAULT NOTIFIER ====================

@Riverpod(keepAlive: true)
class VaultNotifier extends _$VaultNotifier {
  @override
  VaultState build() {
    _init();
    return const VaultState(isLoading: true);
  }

  Future<void> _init() async {
    final settingsService = ref.read(settingsServiceProvider);
    final localAuth = ref.read(localAuthProvider);

    final isEnabled = await settingsService.getBool(_kVaultEnabled);
    final isBiometryEnabled = await settingsService.getBool(_kVaultBiometryEnabled);
    final isBiometryAvailable = await localAuth.canCheckBiometrics;

    state = VaultState(
      isEnabled: isEnabled,
      isLocked: isEnabled, // Locked by default if enabled
      isBiometryEnabled: isBiometryEnabled,
      isBiometryAvailable: isBiometryAvailable,
    );

    // Try auto-unlock with biometry if enabled
    if (isEnabled && isBiometryEnabled) {
      await unlockWithBiometry();
    }
  }

  /// Active le vault avec un nouveau master password.
  /// Chiffre toutes les transactions existantes.
  Future<bool> activate(String masterPassword) async {
    if (masterPassword.length < 8) {
      state = state.copyWith(error: 'Le mot de passe doit contenir au moins 8 caractères');
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final encryptionService = ref.read(encryptionServiceProvider);
      final settingsService = ref.read(settingsServiceProvider);

      // Generate salt and DEK
      final salt = encryptionService.generateSalt();
      final dek = encryptionService.generateDEK();

      // Derive KEK from master password
      final kek = await encryptionService.deriveKEK(masterPassword, salt);

      // Encrypt DEK with KEK
      final encryptedDek = await encryptionService.encryptDEK(dek, kek);

      // Store salt and encrypted DEK in database
      await settingsService.setValue(_kVaultSalt, encryptionService.encodeSalt(salt));
      await settingsService.setValue(_kVaultDekEncrypted, encryptedDek);
      await settingsService.setBool(_kVaultEnabled, true);

      // Store DEK in memory
      ref.read(dekInMemoryProvider.notifier).set(dek);

      // Chiffrer toutes les transactions existantes
      // Créer le service directement pour éviter la dépendance circulaire
      final supabaseClient = ref.read(supabaseClientProvider);
      final transactionService = TransactionService(
        supabaseClient,
        vaultMiddleware: VaultMiddleware(encryptionService, dek),
      );
      await transactionService.encryptAllTransactions();

      // Forcer le rafraîchissement des données
      ref.read(transactionsRefreshTriggerProvider.notifier).refresh();

      state = state.copyWith(
        isEnabled: true,
        isLocked: false,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Erreur lors de l'activation: $e",
      );
      return false;
    }
  }

  /// Déverrouille le vault avec le master password.
  Future<bool> unlock(String masterPassword) async {
    state = state.copyWith(isLoading: true);

    try {
      final encryptionService = ref.read(encryptionServiceProvider);
      final settingsService = ref.read(settingsServiceProvider);

      // Get salt and encrypted DEK from database
      final saltBase64 = await settingsService.getValue(_kVaultSalt);
      final encryptedDek = await settingsService.getValue(_kVaultDekEncrypted);

      if (saltBase64 == null || encryptedDek == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Configuration du vault invalide',
        );
        return false;
      }

      final salt = encryptionService.decodeSalt(saltBase64);

      // Derive KEK from master password
      final kek = await encryptionService.deriveKEK(masterPassword, salt);

      // Decrypt DEK
      final dek = await encryptionService.decryptDEK(encryptedDek, kek);

      // Store DEK in memory
      ref.read(dekInMemoryProvider.notifier).set(dek);

      // Auto-enregistrer la DEK dans le secure storage si la biométrie est activée
      // mais que la DEK n'est pas encore sur cet appareil (cas d'un nouvel appareil).
      final isBiometryEnabled = await settingsService.getBool(_kVaultBiometryEnabled);
      if (isBiometryEnabled) {
        final secureStorage = ref.read(secureStorageProvider);
        final existingDek = await secureStorage.read(key: _kSecureStorageDekKey);
        if (existingDek == null) {
          await secureStorage.write(
            key: _kSecureStorageDekKey,
            value: encryptionService.encodeSalt(dek),
          );
        }
      }

      state = state.copyWith(
        isLocked: false,
        isLoading: false,
        isBiometryEnabled: isBiometryEnabled,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Mot de passe incorrect',
      );
      return false;
    }
  }

  /// Déverrouille le vault avec la biométrie.
  Future<bool> unlockWithBiometry() async {
    if (!state.isBiometryEnabled) return false;

    state = state.copyWith(isLoading: true);

    try {
      final localAuth = ref.read(localAuthProvider);
      final secureStorage = ref.read(secureStorageProvider);

      // Vérifier que la DEK existe dans le secure storage AVANT le prompt biométrique.
      // Sur un nouvel appareil, la DEK n'est pas encore enregistrée localement
      // même si la biométrie est activée dans les settings (synchronisés via Supabase).
      final dekBase64 = await secureStorage.read(key: _kSecureStorageDekKey);
      if (dekBase64 == null) {
        // DEK absente sur cet appareil — désactiver la biométrie dans le state
        // (pas en DB) pour masquer le bouton sur le lock screen.
        // Elle sera réactivée automatiquement après un déverrouillage par mot de passe.
        state = state.copyWith(
          isLoading: false,
          isBiometryEnabled: false,
        );
        return false;
      }

      final authenticated = await localAuth.authenticate(
        localizedReason: 'Déverrouiller Monasafe',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final encryptionService = ref.read(encryptionServiceProvider);
      final dek = encryptionService.decodeSalt(dekBase64); // Same encoding

      // Store DEK in memory
      ref.read(dekInMemoryProvider.notifier).set(dek);

      state = state.copyWith(isLocked: false, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur biométrique: $e',
      );
      return false;
    }
  }

  /// Active la biométrie (stocke la DEK dans le Keychain/Keystore).
  Future<bool> enableBiometry() async {
    final dek = ref.read(dekInMemoryProvider);
    if (dek == null) {
      state = state.copyWith(error: 'Vault doit être déverrouillé');
      return false;
    }

    try {
      final localAuth = ref.read(localAuthProvider);
      final secureStorage = ref.read(secureStorageProvider);
      final settingsService = ref.read(settingsServiceProvider);
      final encryptionService = ref.read(encryptionServiceProvider);

      // Authenticate first
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Activer la biométrie pour Monasafe',
        options: const AuthenticationOptions(stickyAuth: true),
      );

      if (!authenticated) return false;

      // Store DEK in secure storage
      await secureStorage.write(
        key: _kSecureStorageDekKey,
        value: encryptionService.encodeSalt(dek),
      );

      await settingsService.setBool(_kVaultBiometryEnabled, true);

      state = state.copyWith(isBiometryEnabled: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erreur: $e');
      return false;
    }
  }

  /// Désactive la biométrie.
  Future<void> disableBiometry() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final settingsService = ref.read(settingsServiceProvider);

      await secureStorage.delete(key: _kSecureStorageDekKey);
      await settingsService.setBool(_kVaultBiometryEnabled, false);

      state = state.copyWith(isBiometryEnabled: false);
    } catch (e) {
      state = state.copyWith(error: 'Erreur: $e');
    }
  }

  /// Change le master password.
  Future<bool> changeMasterPassword(String currentPassword, String newPassword) async {
    if (newPassword.length < 8) {
      state = state.copyWith(error: 'Le nouveau mot de passe doit contenir au moins 8 caractères');
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final encryptionService = ref.read(encryptionServiceProvider);
      final settingsService = ref.read(settingsServiceProvider);

      // Verify current password
      final saltBase64 = await settingsService.getValue(_kVaultSalt);
      final encryptedDek = await settingsService.getValue(_kVaultDekEncrypted);

      if (saltBase64 == null || encryptedDek == null) {
        state = state.copyWith(isLoading: false, error: 'Configuration invalide');
        return false;
      }

      final oldSalt = encryptionService.decodeSalt(saltBase64);
      final oldKek = await encryptionService.deriveKEK(currentPassword, oldSalt);

      // Decrypt DEK with old KEK
      Uint8List dek;
      try {
        dek = await encryptionService.decryptDEK(encryptedDek, oldKek);
      } catch (_) {
        state = state.copyWith(isLoading: false, error: 'Mot de passe actuel incorrect');
        return false;
      }

      // Generate new salt and KEK
      final newSalt = encryptionService.generateSalt();
      final newKek = await encryptionService.deriveKEK(newPassword, newSalt);

      // Re-encrypt DEK with new KEK
      final newEncryptedDek = await encryptionService.encryptDEK(dek, newKek);

      // Update storage
      await settingsService.setValue(_kVaultSalt, encryptionService.encodeSalt(newSalt));
      await settingsService.setValue(_kVaultDekEncrypted, newEncryptedDek);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur: $e');
      return false;
    }
  }

  /// Verrouille le vault (efface la DEK de la mémoire).
  void lock() {
    ref.read(dekInMemoryProvider.notifier).clear();
    state = state.copyWith(isLocked: true);
  }

  /// Désactive complètement le vault.
  /// Déchiffre toutes les transactions avant de supprimer les clés.
  Future<bool> deactivate(String masterPassword) async {
    state = state.copyWith(isLoading: true);

    try {
      final encryptionService = ref.read(encryptionServiceProvider);
      final settingsService = ref.read(settingsServiceProvider);

      // Récupérer le salt et le DEK chiffré
      final saltBase64 = await settingsService.getValue(_kVaultSalt);
      final encryptedDek = await settingsService.getValue(_kVaultDekEncrypted);

      if (saltBase64 == null || encryptedDek == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Configuration invalide',
        );
        return false;
      }

      // Dériver la KEK et déchiffrer la DEK
      final salt = encryptionService.decodeSalt(saltBase64);
      final kek = await encryptionService.deriveKEK(masterPassword, salt);

      Uint8List dek;
      try {
        dek = await encryptionService.decryptDEK(encryptedDek, kek);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: 'Mot de passe incorrect');
        return false;
      }

      // Créer le service directement pour éviter la dépendance circulaire
      final supabaseClient = ref.read(supabaseClientProvider);
      final transactionService = TransactionService(
        supabaseClient,
        vaultMiddleware: VaultMiddleware(encryptionService, dek),
      );
      await transactionService.decryptAllTransactions();

      final secureStorage = ref.read(secureStorageProvider);

      // Clear all vault settings
      await settingsService.deleteValue(_kVaultEnabled);
      await settingsService.deleteValue(_kVaultSalt);
      await settingsService.deleteValue(_kVaultDekEncrypted);
      await settingsService.deleteValue(_kVaultBiometryEnabled);
      await secureStorage.delete(key: _kSecureStorageDekKey);

      // Clear DEK from memory
      ref.read(dekInMemoryProvider.notifier).clear();

      // Forcer le rafraîchissement des données
      ref.read(transactionsRefreshTriggerProvider.notifier).refresh();

      state = const VaultState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith();
  }
}

// ==================== HELPER PROVIDERS ====================

/// Provider pour savoir si le vault est déverrouillé et prêt pour le chiffrement.
@riverpod
bool isVaultReady(Ref ref) {
  final vaultState = ref.watch(vaultNotifierProvider);
  final dek = ref.watch(dekInMemoryProvider);
  return vaultState.isEnabled && !vaultState.isLocked && dek != null;
}

/// Provider pour obtenir la DEK si disponible.
@riverpod
Uint8List? currentDek(Ref ref) {
  final isReady = ref.watch(isVaultReadyProvider);
  if (!isReady) return null;
  return ref.watch(dekInMemoryProvider);
}
