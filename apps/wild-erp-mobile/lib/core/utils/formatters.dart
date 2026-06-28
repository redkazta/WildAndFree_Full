import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final NumberFormat _currencyFormatter =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final NumberFormat _numberFormatter = NumberFormat('#,##0');
  static final NumberFormat _compactFormatter = NumberFormat.compact();

  static String formatDate(DateTime date) => _dateFormatter.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormatter.format(date);

  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  static String formatCurrency(double amount) => _currencyFormatter.format(amount);

  static String formatNumber(num value) => _numberFormatter.format(value);

  static String formatCompact(num value) => _compactFormatter.format(value);

  static String formatToken(int tokens) {
    if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(1)}M';
    } else if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(1)}K';
    }
    return tokens.toString();
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    if (diff.inDays < 30) return 'hace ${(diff.inDays / 7).floor()}sem';
    return formatDate(date);
  }

  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
