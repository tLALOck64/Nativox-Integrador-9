import 'package:intl/intl.dart';

class AppFormatters {
  // Date formatters
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy', 'es');

  static String formatDate(DateTime date) {
    return dateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return timeFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return dateTimeFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return monthYearFormat.format(date);
  }

  // Number formatters
  static final NumberFormat numberFormat = NumberFormat('#,##0', 'es');
  static final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );
  static final NumberFormat percentFormat = NumberFormat.percentPattern('es');

  static String formatNumber(num number) {
    return numberFormat.format(number);
  }

  static String formatCurrency(num amount) {
    return currencyFormat.format(amount);
  }

  static String formatPercent(double percent) {
    return percentFormat.format(percent);
  }

  // File size formatter
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Duration formatter
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
