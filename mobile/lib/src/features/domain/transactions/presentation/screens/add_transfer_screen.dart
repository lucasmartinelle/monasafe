import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/features/domain/transactions/presentation/transfer_form_provider.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/widgets/transfer_form.dart';

/// Modal bottom sheet pour créer un virement entre comptes.
class AddTransferScreen extends ConsumerWidget {
  const AddTransferScreen({super.key});

  /// Affiche le modal de virement.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransferScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TransferForm(
      onInit: () => ref.read(transferFormNotifierProvider.notifier).reset(),
    );
  }
}
