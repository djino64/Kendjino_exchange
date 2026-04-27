// lib/core/utils/formatter.dart
import 'package:intl/intl.dart';

class Formatter {
  Formatter._();

  static String currency(double amount, String currency) {
    switch (currency) {
      case 'HTG':
        return 'HTG ${NumberFormat('#,##0.00', 'fr').format(amount)}';
      case 'USD':
        return '\$${NumberFormat('#,##0.00', 'en').format(amount)}';
      case 'BTC':
        return '${amount.toStringAsFixed(8)} BTC';
      case 'USDT':
        return 'USDT ${NumberFormat('#,##0.00', 'en').format(amount)}';
      default:
        return '${NumberFormat('#,##0.00').format(amount)} $currency';
    }
  }

  static String compactCurrency(double amount, String currency) {
    if (amount >= 1000000) {
      return '$currency ${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '$currency ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return currency == 'BTC'
        ? '${amount.toStringAsFixed(6)} BTC'
        : '$currency ${amount.toStringAsFixed(2)}';
  }

  static String phone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 8) {
      return '${clean.substring(0, 4)} ${clean.substring(4)}';
    }
    if (clean.length == 11 && clean.startsWith('509')) {
      return '+509 ${clean.substring(3, 7)} ${clean.substring(7)}';
    }
    return phone;
  }

  static String date(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return DateFormat('dd MMM yyyy', 'fr').format(dt);
  }

  static String dateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy • HH:mm', 'fr').format(dt);
  }

  static String shortDate(DateTime dt) {
    return DateFormat('dd/MM/yy').format(dt);
  }

  static String cardNumber(String number) {
    final clean = number.replaceAll(' ', '');
    final parts = <String>[];
    for (int i = 0; i < clean.length; i += 4) {
      parts.add(clean.substring(i, (i + 4).clamp(0, clean.length)));
    }
    return parts.join(' ');
  }

  static String maskedCard(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.length < 4) return number;
    return '**** **** **** ${clean.substring(clean.length - 4)}';
  }

  static String percent(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }
}