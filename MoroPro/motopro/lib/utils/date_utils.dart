import 'package:flutter/foundation.dart';

/// Converte uma string no formato "2025-07-08" ou DateTime
/// para o formato ISO seguro "yyyy-MM-dd".
/// Retorna string vazia se inválida.
String formatarDataISO(dynamic rawDate) {
  debugPrint('🔍 DEBUG - formatarDataISO input: $rawDate (tipo: ${rawDate.runtimeType})');
  
  if (rawDate is String) {
    // Se já está no formato correto
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate)) {
      debugPrint('🔍 DEBUG - Data já no formato correto: $rawDate');
      return rawDate;
    }
    
    // Tenta fazer parse da data
    try {
      final parsedDate = DateTime.parse(rawDate);
      final formatted = '${parsedDate.year.toString().padLeft(4, '0')}-'
          '${parsedDate.month.toString().padLeft(2, '0')}-'
          '${parsedDate.day.toString().padLeft(2, '0')}';
      debugPrint('🔍 DEBUG - Data convertida: $rawDate -> $formatted');
      return formatted;
    } catch (e) {
      debugPrint('🔍 DEBUG - Erro ao converter data: $rawDate - $e');
      return '';
    }
  }
  
  debugPrint('🔍 DEBUG - Tipo não suportado: ${rawDate.runtimeType}');
  return '';
}


