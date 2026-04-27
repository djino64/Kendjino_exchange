// lib/core/utils/validators.dart
class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Numéro requis';
    final clean = value.replaceAll(RegExp(r'\s|-'), '');
    // Haiti numbers: +509 followed by 8 digits
    if (!RegExp(r'^\+?509\d{8}$').hasMatch(clean) &&
        !RegExp(r'^\d{8}$').hasMatch(clean)) {
      return 'Numéro haïtien invalide (ex: +50941300944)';
    }
    return null;
  }

  static String? amount(String? value, {double min = 10, double max = 50000}) {
    if (value == null || value.isEmpty) return 'Montant requis';
    final n = double.tryParse(value.replaceAll(',', '.'));
    if (n == null) return 'Montant invalide';
    if (n < min) return 'Minimum: $min HTG';
    if (n > max) return 'Maximum: $max HTG';
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'PIN requis';
    if (value.length != 4) return 'PIN doit avoir 4 chiffres';
    if (!RegExp(r'^\d{4}$').hasMatch(value)) return 'PIN: chiffres seulement';
    return null;
  }

  static String? required(String? value, [String field = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) return '$field est requis';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'Code requis';
    if (value.length != 6) return '6 chiffres requis';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Chiffres seulement';
    return null;
  }
}