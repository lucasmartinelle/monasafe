import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simpleflow/src/core/config/supabase_config.dart';
import 'package:simpleflow/src/core/services/seed_service.dart';
import 'package:simpleflow/src/core/theme/theme.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';
import 'package:simpleflow/src/data/services/services.dart';
import 'package:simpleflow/src/features/app_shell/app_shell.dart';
import 'package:simpleflow/src/features/onboarding/onboarding.dart';
import 'package:simpleflow/src/features/vault/vault.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Garder le splash natif affiché pendant l'initialisation
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Charger les variables d'environnement en premier
  await dotenv.load();

  // Timer pour garantir 2 secondes minimum de splash
  final splashTimer = Future.delayed(const Duration(seconds: 2));

  await Future.wait([
    initializeDateFormatting('fr_FR'),
    Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    ),
  ]);

  // Injecter les données par défaut si nécessaire (utilise la secret key)
  await SeedService().runAllSeeds();

  // Attendre que les 2 secondes soient écoulées
  await splashTimer;

  // Retirer le splash natif
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: SimpleFlowApp(),
    ),
  );
}

class SimpleFlowApp extends StatelessWidget {
  const SimpleFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const _AppRoot(),
    );
  }
}

/// Widget racine qui gère la navigation entre onboarding et home
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSubscription;
  bool _isCompletingPendingOnboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Quand l'app revient au premier plan (après OAuth), vérifier les données pending
    if (state == AppLifecycleState.resumed) {
      debugPrint('[OAuth] App resumed, checking pending onboarding...');
      _checkAndCompletePendingOnboarding();
    }
  }

  /// Écoute les changements d'authentification pour détecter
  /// le retour du callback OAuth et compléter l'onboarding.
  void _listenToAuthChanges() {
    final authService = ref.read(authServiceProvider);
    _authSubscription = authService.authStateChanges.listen((authState) async {
      debugPrint('[OAuth] Auth state changed: ${authState.event}');

      // Ignorer si on est déjà en train de compléter l'onboarding
      if (_isCompletingPendingOnboarding) return;

      // Vérifier si c'est un événement de connexion avec un user
      if ((authState.event == AuthChangeEvent.signedIn ||
              authState.event == AuthChangeEvent.tokenRefreshed) &&
          authState.session?.user != null) {
        debugPrint('[OAuth] User signed in, checking pending onboarding...');
        await _checkAndCompletePendingOnboarding();
      }
    });

    // Vérifier aussi au démarrage (cas où l'app a été tuée pendant OAuth)
    // Avec un petit délai pour laisser Supabase restaurer la session
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        debugPrint('[OAuth] Initial check for pending onboarding...');
        _checkAndCompletePendingOnboarding();
      }
    });
  }

  /// Vérifie s'il y a des données d'onboarding pending et les complète.
  Future<void> _checkAndCompletePendingOnboarding() async {
    final authService = ref.read(authServiceProvider);
    final pendingService = ref.read(pendingOnboardingServiceProvider);

    debugPrint('[OAuth] Checking: isAuthenticated=${authService.isAuthenticated}, '
        'isAnonymous=${authService.isAnonymous}, '
        'userId=${authService.currentUserId}');

    // Vérifier qu'on a un user authentifié
    if (!authService.isAuthenticated) {
      debugPrint('[OAuth] Not authenticated, skipping');
      return;
    }

    // Vérifier que l'utilisateur N'EST PAS anonyme
    // (les données pending sont pour un compte Google, pas anonyme)
    if (authService.isAnonymous) {
      debugPrint('[OAuth] User is anonymous, skipping');
      return;
    }

    // Vérifier qu'il y a des données pending
    final pendingData = await pendingService.getPendingData();
    if (pendingData == null) {
      debugPrint('[OAuth] No pending data, skipping');
      return;
    }

    debugPrint('[OAuth] Found pending data, completing onboarding...');

    // Compléter l'onboarding
    setState(() => _isCompletingPendingOnboarding = true);

    try {
      final controller = ref.read(onboardingControllerProvider.notifier);
      await controller.completePendingOnboarding(pendingData);

      debugPrint('[OAuth] Onboarding completed successfully!');

      // Forcer le refresh pour naviguer vers home
      ref.invalidate(onboardingCompletedStreamProvider);
    } catch (e) {
      debugPrint('[OAuth] Error completing onboarding: $e');
    } finally {
      if (mounted) {
        setState(() => _isCompletingPendingOnboarding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final onboardingCompleted = ref.watch(onboardingCompletedStreamProvider);

    // Afficher un loader pendant la complétion de l'onboarding pending
    if (_isCompletingPendingOnboarding) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Configuration de votre compte...'),
            ],
          ),
        ),
      );
    }

    return onboardingCompleted.when(
      data: (completed) {
        if (completed) {
          return const _VaultAwareShell();
        }
        return OnboardingFlow(
          onComplete: () {
            // Force le refresh du provider pour naviguer vers home
            ref.invalidate(onboardingCompletedStreamProvider);
          },
        );
      },
      loading: () => Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text('Erreur: $error', style: TextStyle(color: textColor)),
        ),
      ),
    );
  }
}

/// Shell qui gère le Vault et le lifecycle de l'application.
class _VaultAwareShell extends ConsumerStatefulWidget {
  const _VaultAwareShell();

  @override
  ConsumerState<_VaultAwareShell> createState() => _VaultAwareShellState();
}

class _VaultAwareShellState extends ConsumerState<_VaultAwareShell>
    with WidgetsBindingObserver {
  bool _recurringGenerated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Lock vault when app goes to background
      final vaultState = ref.read(vaultNotifierProvider);
      if (vaultState.isEnabled && !vaultState.isLocked) {
        ref.read(vaultNotifierProvider.notifier).lock();
      }
    }

    // Regenerer les recurrences quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed) {
      _generateRecurringTransactions();
    }
  }

  /// Genere les transactions recurrentes en attente
  void _generateRecurringTransactions() {
    // Appeler le provider de generation (fire and forget)
    ref.read(generateRecurringTransactionsProvider.future).then((count) {
      if (count > 0) {
        debugPrint('[Recurring] Generated $count recurring transactions');
      }
    }).catchError((Object e) {
      debugPrint('[Recurring] Error generating transactions: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultNotifierProvider);

    // Show lock screen if vault is enabled and locked
    if (vaultState.isEnabled && vaultState.isLocked) {
      return LockScreen(
        onUnlocked: () {
          // Force rebuild to show AppShell
          setState(() {});
          // Generer les recurrences apres deverrouillage
          _generateRecurringTransactions();
        },
      );
    }

    // Generer les recurrences au premier affichage (vault non active ou deja deverrouille)
    if (!_recurringGenerated) {
      _recurringGenerated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateRecurringTransactions();
      });
    }

    return const AppShell();
  }
}
