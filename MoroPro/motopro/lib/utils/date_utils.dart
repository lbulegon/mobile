import 'package:intl/intl.dart';

/// Converte uma string no formato "2025-07-08" ou DateTime
/// para o formato ISO seguro "yyyy-MM-dd".
/// Retorna string vazia se inválida.
String formatarDataISO(dynamic rawDate) {
  try {
    if (rawDate is String) {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return DateFormat('yyyy-MM-dd').format(parsed);
      }
    } else if (rawDate is DateTime) {
      return DateFormat('yyyy-MM-dd').format(rawDate);
    }
  } catch (_) {}
  return '';
}
