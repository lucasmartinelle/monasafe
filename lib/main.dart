import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:simpleflow/src/core/theme/theme.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';
import 'package:simpleflow/src/features/app_shell/app_shell.dart';
import 'package:simpleflow/src/features/onboarding/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
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
class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return onboardingCompleted.when(
      data: (completed) {
        if (completed) {
          return const AppShell();
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
