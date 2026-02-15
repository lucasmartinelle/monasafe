import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monasafe/src/core/config/supabase_config.dart';
import 'package:monasafe/src/core/theme/theme.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/aggregators/app_shell/app_shell.dart';
import 'package:monasafe/src/features/domain/onboarding/presentation/onboarding_flow.dart';
import 'package:monasafe/src/features/domain/vault/presentation/screens/lock_screen.dart';
import 'package:monasafe/src/common_widgets/app_error_screen.dart';
import 'package:monasafe/src/features/domain/vault/presentation/vault_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Garder le splash natif affiché pendant l'initialisation
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Charger les variables d'environnement en premier
  await dotenv.load();

  // Timer pour garantir 2 secondes minimum de splash
  final splashTimer = Future<void>.delayed(const Duration(seconds: 2));

  await Future.wait([
    initializeDateFormatting('fr_FR'),
    Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    ),
  ]);

  // Attendre que les 2 secondes soient écoulées
  await splashTimer;

  // Retirer le splash natif
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: MonasafeApp(),
    ),
  );
}

class MonasafeApp extends StatelessWidget {
  const MonasafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monasafe',
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
    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  Future<void> _handleAppResumed() async {
    debugPrint('[OAuth] App resumed');
    final client = Supabase.instance.client;
    if (client.auth.currentSession != null) {
      try {
        await client.auth.refreshSession();
        debugPrint('[Auth] Session refreshed successfully');
      } catch (e) {
        debugPrint('[Auth] Session refresh failed: $e');
      }
    }
    ref.invalidate(onboardingCompletedStreamProvider);
  }

  /// Écoute les changements d'authentification pour détecter
  /// le retour du callback OAuth.
  void _listenToAuthChanges() {
    final authService = ref.read(authServiceProvider);
    _authSubscription = authService.authStateChanges.listen((authState) async {
      debugPrint('[OAuth] Auth state changed: ${authState.event}');

      if ((authState.event == AuthChangeEvent.signedIn ||
              authState.event == AuthChangeEvent.tokenRefreshed) &&
          authState.session?.user != null) {
        debugPrint('[OAuth] User signed in, refreshing state...');
        // Invalider pour que l'OnboardingFlow re-vérifie l'état
        ref.invalidate(onboardingCompletedStreamProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final onboardingCompleted = ref.watch(onboardingCompletedStreamProvider);

    return onboardingCompleted.when(
      data: (completed) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: completed
              ? const _VaultAwareShell(key: ValueKey('home'))
              : OnboardingFlow(
                  key: const ValueKey('onboarding'),
                  onComplete: () {
                    ref.invalidate(onboardingCompletedStreamProvider);
                  },
                ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => AppErrorScreen(
        error: error,
        onRetry: () async {
          try {
            await Supabase.instance.client.auth.refreshSession();
          } catch (_) {}
          ref.invalidate(onboardingCompletedStreamProvider);
        },
      ),
    );
  }
}

/// Shell qui gère le Vault et le lifecycle de l'application.
class _VaultAwareShell extends ConsumerStatefulWidget {
  const _VaultAwareShell({super.key});

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
