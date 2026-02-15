import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_providers.g.dart';

/// Provider pour recuperer toutes les transactions recurrentes avec details.
@riverpod
Future<List<RecurringTransactionWithDetails>> recurringWithDetails(Ref ref) {
  ref.watch(recurringRefreshTriggerProvider);
  final service = ref.watch(recurringTransactionServiceProvider);
  return service.getAllWithDetails();
}

/// Provider pour recuperer uniquement les recurrences actives avec details.
@riverpod
Future<List<RecurringTransactionWithDetails>> activeRecurringWithDetails(
  Ref ref,
) {
  ref.watch(recurringRefreshTriggerProvider);
  final service = ref.watch(recurringTransactionServiceProvider);
  return service.getActiveWithDetails();
}

/// Provider pour compter le nombre de recurrences actives.
@riverpod
Future<int> activeRecurringCount(Ref ref) async {
  final recurrings = await ref.watch(activeRecurringWithDetailsProvider.future);
  return recurrings.length;
}

/// Calcule la prochaine date de generation d'une recurrence.
///
/// Cette fonction est pure et ne depend pas d'un provider pour eviter
/// les problemes de cache avec les objets RecurringTransaction.
DateTime? calculateNextRecurringDate(RecurringTransaction recurring) {
  if (!recurring.isActive) return null;

  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);

  // Si jamais generee, la prochaine date est la date de debut
  if (recurring.lastGenerated == null) {
    // Si la date de debut est dans le futur, c'est la prochaine date
    if (recurring.startDate.isAfter(todayDateOnly) ||
        recurring.startDate.isAtSameMomentAs(todayDateOnly)) {
      return recurring.startDate;
    }
    // Sinon, calculer depuis la date de debut
    return _calculateNextMonthlyDate(recurring.startDate, recurring.originalDay);
  }

  // Calculer la prochaine date depuis la derniere generee
  final nextDate = _calculateNextMonthlyDate(
    recurring.lastGenerated!,
    recurring.originalDay,
  );

  // Verifier la date de fin
  if (recurring.endDate != null && nextDate.isAfter(recurring.endDate!)) {
    return null;
  }

  return nextDate;
}

/// Calcule la prochaine date mensuelle (copie de RecurrenceDateService).
DateTime _calculateNextMonthlyDate(DateTime current, int originalDay) {
  var nextMonth = current.month + 1;
  var nextYear = current.year;
  if (nextMonth > 12) {
    nextMonth = 1;
    nextYear++;
  }

  final daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
  final day = originalDay > daysInMonth ? daysInMonth : originalDay;

  return DateTime(nextYear, nextMonth, day);
}
