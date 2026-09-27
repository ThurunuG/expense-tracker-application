import 'package:intl/intl.dart';

/// Utility class for formatting values used across the app.
class Formatters {
  // Prevent instantiation of this utility class.
  Formatters._();

  // Currency formatter with a dollar symbol.
  static final NumberFormat _currency = NumberFormat.currency(symbol: '\$');

  // Date formatters for common display styles.
  static final DateFormat _fullDate = DateFormat('MMM d, yyyy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _shortDate = DateFormat('MMM d');

  /// Formats a numeric value as currency.
  static String currency(double value) => _currency.format(value);

  /// Formats a date as a full date string such as "Jan 5, 2024".
  static String fullDate(DateTime date) => _fullDate.format(date);

  /// Formats a date as a month and year string such as "January 2024".
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// Formats a date as a short month-day string such as "Jan 5".
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// Checks whether two dates fall in the same calendar month.
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// Checks whether two dates fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
