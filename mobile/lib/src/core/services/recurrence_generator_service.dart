import 'package:monasafe/src/core/services/recurrence_date_service.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/services/recurring_transaction_service.dart';
import 'package:monasafe/src/data/services/transaction_service.dart';

/// Service de generation automatique des transactions recurrentes.
///
/// Ce service est appele au demarrage de l'app pour generer
/// toutes les occurrences en attente.
class RecurrenceGeneratorService {
  RecurrenceGeneratorService(
    this._recurringService,
    this._transactionService,
    this._dateService,
  );

  final RecurringTransactionService _recurringService;
  final TransactionService _transactionService;
  final RecurrenceDateService _dateService;

  /// Genere toutes les transactions en attente.
  ///
  /// Retourne le nombre de transactions generees.
  Future<int> generatePendingTransactions() async {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    final recurrings = await _recurringService.getRecurringsToGenerate();
    var generatedCount = 0;

    for (final recurring in recurrings) {
      generatedCount += await _generateForRecurring(recurring, todayDateOnly);
    }

    return generatedCount;
  }

  /// Genere les transactions pour une recurrence donnee.
  Future<int> _generateForRecurring(
    RecurringTransactionWithDetails recurring,
    DateTime today,
  ) async {
    final rec = recurring.recurring;

    // Verifier que la categorie existe
    if (recurring.category == null) {
      // Categorie supprimee, desactiver la recurrence
      await _recurringService.deactivate(rec.id);
      return 0;
    }

    // Calculer la premiere date a generer
    var currentDate = _dateService.calculateFirstGenerationDate(
      rec.startDate,
      rec.lastGenerated,
      rec.originalDay,
    );

    var count = 0;

    // Generer tant que la date est <= aujourd'hui
    while (!currentDate.isAfter(today)) {
      // Verifier end_date
      if (rec.endDate != null && currentDate.isAfter(rec.endDate!)) {
        // Desactiver la recurrence si on a depasse la date de fin
        await _recurringService.deactivate(rec.id);
        break;
      }

      // Creer la transaction
      await _transactionService.createTransaction(
        accountId: rec.accountId,
        categoryId: rec.categoryId!,
        amount: rec.amount,
        note: rec.note,
        date: currentDate,
        recurringId: rec.id,
      );

      // Mettre a jour last_generated
      await _recurringService.updateLastGenerated(rec.id, currentDate);

      count++;

      // Calculer la prochaine date
      currentDate = _dateService.calculateNextMonthlyDate(
        currentDate,
        rec.originalDay,
      );
    }

    return count;
  }

  /// Genere la premiere occurrence d'une nouvelle recurrence.
  ///
  /// Appelee lors de la creation d'une recurrence.
  Future<Transaction> generateFirstOccurrence(
    RecurringTransaction recurring,
  ) async {
    final transaction = await _transactionService.createTransaction(
      accountId: recurring.accountId,
      categoryId: recurring.categoryId!,
      amount: recurring.amount,
      note: recurring.note,
      date: recurring.startDate,
      recurringId: recurring.id,
    );

    // Mettre a jour last_generated
    await _recurringService.updateLastGenerated(
      recurring.id,
      recurring.startDate,
    );

    return transaction;
  }
}
