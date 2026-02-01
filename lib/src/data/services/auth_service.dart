import 'package:supabase_flutter/supabase_flutter.dart';

/// Service d'authentification Supabase
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  /// Retourne l'utilisateur actuellement connecté
  User? get currentUser => _client.auth.currentUser;

  /// Retourne l'ID de l'utilisateur actuellement connecté
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Vérifie si un utilisateur est connecté
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Vérifie si l'utilisateur est anonyme
  bool get isAnonymous => _client.auth.currentUser?.isAnonymous ?? false;

  /// Stream des changements d'état d'authentification
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Crée un compte anonyme
  ///
  /// Retourne l'utilisateur créé ou throws une exception en cas d'erreur
  Future<User> signInAnonymously() async {
    final response = await _client.auth.signInAnonymously();
    if (response.user == null) {
      throw Exception('Échec de la création du compte anonyme');
    }
    return response.user!;
  }

  /// Connecte avec Google OAuth
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.simpleflow://login-callback/',
    );
  }

  /// Upgrade un compte anonyme vers un compte email/password
  Future<User> upgradeAnonymousAccount({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
      ),
    );
    if (response.user == null) {
      throw Exception('Échec de la mise à niveau du compte');
    }
    return response.user!;
  }

  /// Déconnecte l'utilisateur
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Lie un compte Google à un compte anonyme existant.
  ///
  /// Note: Supabase gère le linking via OAuth. Après le retour de Google,
  /// le compte anonyme sera converti en compte Google.
  Future<void> linkWithGoogle() async {
    if (!isAnonymous) {
      throw Exception('Seuls les comptes anonymes peuvent être liés');
    }

    await _client.auth.linkIdentity(
      OAuthProvider.google,
      redirectTo: 'io.supabase.simpleflow://login-callback/',
    );
  }

  /// Récupère le user complet depuis l'API et vérifie s'il a un provider Google.
  /// Cette méthode fait un appel réseau et retourne les données à jour.
  Future<bool> fetchHasGoogleProvider() async {
    try {
      final response = await _client.auth.getUser();
      final user = response.user;

      if (user == null) return false;

      return user.identities?.any(
            (identity) => identity.provider == 'google',
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }
}
