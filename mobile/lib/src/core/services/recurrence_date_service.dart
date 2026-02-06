/// Service pour le calcul des dates de recurrence mensuelle.
///
/// Gere les cas particuliers :
/// - Mois avec moins de jours (31 Jan -> 28 Fev)
/// - Annees bissextiles (29 Fev)
class RecurrenceDateService {
  /// Calcule la prochaine date mensuelle.
  ///
  /// [current] : Date actuelle de la recurrence
  /// [originalDay] : Jour d'origine (1-31) de la premiere occurrence
  ///
  /// Regles :
  /// - Ajoute 1 mois calendaire
  /// - Si originalDay > jours du mois cible -> dernier jour du mois
  ///
  /// Exemples :
  /// - 31 Jan -> 28 Fev (ou 29 si bissextile)
  /// - 31 Mar -> 30 Avr
  /// - 15 Jan -> 15 Fev
  /// - 29 Fev 2024 -> 29 Mar 2024
  DateTime calculateNextMonthlyDate(DateTime current, int originalDay) {
    // 1. Calculer le mois suivant
    var nextMonth = current.month + 1;
    var nextYear = current.year;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }

    // 2. Determiner le nombre de jours du mois cible
    final daysInMonth = getDaysInMonth(nextYear, nextMonth);

    // 3. Ajuster le jour si necessaire
    final day = originalDay > daysInMonth ? daysInMonth : originalDay;

    return DateTime(nextYear, nextMonth, day);
  }

  /// Calcule toutes les dates entre [startDate] et [endDate] (inclus).
  ///
  /// Utile pour generer plusieurs occurrences d'un coup.
  List<DateTime> calculateDatesBetween(
    DateTime startDate,
    DateTime endDate,
    int originalDay,
  ) {
    final dates = <DateTime>[];
    var current = startDate;

    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = calculateNextMonthlyDate(current, originalDay);
    }

    return dates;
  }

  /// Retourne le nombre de jours dans un mois donne.
  int getDaysInMonth(int year, int month) {
    // Utilise le fait que DateTime(year, month + 1, 0) donne le dernier jour du mois
    return DateTime(year, month + 1, 0).day;
  }

  /// Verifie si une annee est bissextile.
  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Calcule la premiere date de generation.
  ///
  /// Si [lastGenerated] est null, retourne [startDate].
  /// Sinon, retourne la date suivante apres [lastGenerated].
  DateTime calculateFirstGenerationDate(
    DateTime startDate,
    DateTime? lastGenerated,
    int originalDay,
  ) {
    if (lastGenerated == null) {
      return startDate;
    }
    return calculateNextMonthlyDate(lastGenerated, originalDay);
  }
}
