/// Converte uma string no formato "2025-07-08" ou DateTime
/// para o formato ISO seguro "yyyy-MM-dd".
/// Retorna string vazia se inválida.
String formatarDataISO(dynamic rawDate) {
  if (rawDate is String && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate)) {
    return rawDate;
  }
  return '';
}


