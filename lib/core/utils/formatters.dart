import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  // ── Currency ──
  static String currency(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat('#,##,###.##', 'en_IN');
    return '$symbol${formatter.format(amount)}';
  }

  static String currencyCompact(double amount, {String symbol = '₹'}) {
    if (amount.abs() >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount, symbol: symbol);
  }

  // ── Date ──
  static String dateShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  static String dateFull(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  static String dateWithDay(DateTime date) {
    return DateFormat('EEE, d MMM').format(date);
  }

  static String dateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}–${DateFormat('d MMM yyyy').format(end)}';
    } else if (start.year == end.year) {
      return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
    }
    return '${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
  }

  // ── Time ──
  static String time(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String timeFromTimeOfDay(int hour, int minute) {
    final dt = DateTime(2024, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(dt);
  }

  // ── Relative Time ──
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return dateShort(dateTime);
  }

  // ── Trip Duration ──
  static String tripDuration(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    final nights = days - 1;
    if (nights == 0) return '$days day';
    return '$days days, $nights nights';
  }

  // ── Initials ──
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
