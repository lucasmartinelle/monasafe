import 'package:intl/intl.dart';

/// Utility class for formatting currency amounts.
///
/// Supports EUR, USD, GBP, and other currencies using locale-aware formatting.
abstract final class CurrencyFormatter {
  /// Cache for NumberFormat instances to avoid repeated creation
  static final Map<String, NumberFormat> _formatters = {};

  /// Formats an amount with the specified currency.
  ///
  /// [amount] - The amount to format
  /// [currency] - The currency code (EUR, USD, GBP, etc.)
  /// [showSign] - Whether to show + for positive amounts
  /// [compact] - Whether to use compact notation for large amounts
  ///
  /// Examples:
  /// ```dart
  /// format(1234.56, 'EUR') // "1 234,56 €"
  /// format(-50.00, 'USD', showSign: true) // "-$50.00"
  /// format(1500000, 'EUR', compact: true) // "1,5 M€"
  /// ```
  static String format(
    double amount, {
    String currency = 'EUR',
    bool showSign = false,
    bool compact = false,
  }) {
    final formatter = _getFormatter(currency, compact: compact);
    final formatted = formatter.format(amount.abs());

    String result;
    if (amount < 0) {
      result = '-$formatted';
    } else if (showSign && amount > 0) {
      result = '+$formatted';
    } else {
      result = formatted;
    }

    return result;
  }

  /// Formats an amount with sign coloring hint.
  ///
  /// Returns a record with the formatted string and whether it's negative.
  static ({String formatted, bool isNegative}) formatWithSign(
    double amount, {
    String currency = 'EUR',
    bool compact = false,
  }) {
    return (
      formatted: format(amount, currency: currency, showSign: true, compact: compact),
      isNegative: amount < 0,
    );
  }

  /// Formats a transaction amount based on category type.
  ///
  /// Income transactions are positive, expense transactions are negative.
  static String formatTransaction(
    double amount, {
    required bool isExpense,
    String currency = 'EUR',
  }) {
    final displayAmount = isExpense ? -amount.abs() : amount.abs();
    return format(displayAmount, currency: currency, showSign: true);
  }

  /// Gets the currency symbol for a currency code.
  static String getSymbol(String currency) {
    return switch (currency.toUpperCase()) {
      'EUR' => '€',
      'USD' => r'$',
      'GBP' => '£',
      'JPY' => '¥',
      'CHF' => 'CHF',
      'CAD' => r'CA$',
      'AUD' => r'A$',
      'CNY' => '¥',
      'INR' => '₹',
      'BRL' => r'R$',
      'MXN' => r'MX$',
      _ => currency,
    };
  }

  /// Gets the locale for a currency code.
  static String _getLocale(String currency) {
    return switch (currency.toUpperCase()) {
      'EUR' => 'fr_FR',
      'USD' => 'en_US',
      'GBP' => 'en_GB',
      'JPY' => 'ja_JP',
      'CHF' => 'de_CH',
      'CAD' => 'en_CA',
      'AUD' => 'en_AU',
      'CNY' => 'zh_CN',
      'INR' => 'en_IN',
      'BRL' => 'pt_BR',
      'MXN' => 'es_MX',
      _ => 'fr_FR',
    };
  }

  static NumberFormat _getFormatter(String currency, {bool compact = false}) {
    final key = '${currency}_$compact';

    if (!_formatters.containsKey(key)) {
      final locale = _getLocale(currency);
      _formatters[key] = compact
          ? NumberFormat.compactCurrency(locale: locale, symbol: getSymbol(currency))
          : NumberFormat.currency(locale: locale, symbol: getSymbol(currency));
    }

    return _formatters[key]!;
  }

  /// Parses a formatted currency string back to a double.
  ///
  /// Returns null if parsing fails.
  static double? parse(String formattedAmount, {String currency = 'EUR'}) {
    try {
      final formatter = _getFormatter(currency);
      return formatter.parse(formattedAmount).toDouble();
    } catch (_) {
      // Try basic parsing by removing currency symbols and spaces
      final cleaned = formattedAmount
          .replaceAll(getSymbol(currency), '')
          .replaceAll(' ', '')
          .replaceAll(',', '.')
          .trim();
      return double.tryParse(cleaned);
    }
  }
}
