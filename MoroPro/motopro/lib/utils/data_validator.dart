import 'package:flutter/foundation.dart';

/// Utilitário para validação de dados
class DataValidator {
  /// Valida se uma data é válida e está em um range aceitável
  static bool isValidDate(DateTime date) {
    try {
      // Verificar se a data está em um range aceitável (1900-2100)
      if (date.year < 1900 || date.year > 2100) {
        return false;
      }
      
      // Verificar se a data não é inválida (como 30 de fevereiro)
      final reconstructed = DateTime(date.year, date.month, date.day);
      return reconstructed.year == date.year &&
             reconstructed.month == date.month &&
             reconstructed.day == date.day;
    } catch (e) {
      debugPrint('[DataValidator] Erro ao validar data: $e');
      return false;
    }
  }

  /// Valida se uma data está no futuro (a partir de hoje)
  static bool isFutureDate(DateTime date) {
    if (!isValidDate(date)) return false;
    
    final hoje = DateTime.now();
    final dataComparacao = DateTime(hoje.year, hoje.month, hoje.day);
    final dataVaga = DateTime(date.year, date.month, date.day);
    
    return dataVaga.isAtSameMomentAs(dataComparacao) || dataVaga.isAfter(dataComparacao);
  }

  /// Valida se uma vaga deve ser exibida considerando data e horário
  /// Inclui vagas que se estendem até a madrugada do dia seguinte
  static bool shouldShowVaga(DateTime dataVaga, DateTime horaInicio, DateTime horaFim) {
    if (!isValidDate(dataVaga)) return false;
    
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dataVagaOnly = DateTime(dataVaga.year, dataVaga.month, dataVaga.day);
    
    // debugPrint('[DataValidator] Analisando vaga: Data=${dataVagaOnly}, Hoje=${hoje}, Hora=${horaInicio.hour}:${horaInicio.minute}-${horaFim.hour}:${horaFim.minute}');
    
    // Se a vaga é de um dia futuro, sempre mostrar
    if (dataVagaOnly.isAfter(hoje)) {
      return true;
    }
    
    // Se a vaga é de hoje, verificar se ainda não terminou
    if (dataVagaOnly.isAtSameMomentAs(hoje)) {
      // debugPrint('[DataValidator] Vaga é de hoje');
      // Se a vaga termina na madrugada (hora fim < hora início), 
      // considerar que vai até o dia seguinte - SEMPRE mostrar
      if (horaFim.hour < horaInicio.hour) {
        // debugPrint('[DataValidator] Vaga vai até madrugada - SEMPRE mostrar');
        // Vaga vai até a madrugada do dia seguinte - sempre mostrar
        return true;
      } else {
        // debugPrint('[DataValidator] Vaga normal do mesmo dia - verificar se não terminou');
        // Vaga normal do mesmo dia - verificar se ainda não terminou
        final agoraTime = DateTime(agora.year, agora.month, agora.day, agora.hour, agora.minute);
        final fimTime = DateTime(dataVaga.year, dataVaga.month, dataVaga.day, horaFim.hour, horaFim.minute);
        final naoTerminou = agoraTime.isBefore(fimTime);
        // debugPrint('[DataValidator] Agora: $agoraTime, Fim: $fimTime, Não terminou: $naoTerminou');
        return naoTerminou;
      }
    }
    
    // Se a vaga é de ontem mas vai até a madrugada de hoje, mostrar
    final ontem = DateTime(hoje.year, hoje.month, hoje.day - 1);
    if (dataVagaOnly.isAtSameMomentAs(ontem)) {
      // Se a vaga de ontem termina na madrugada (hora fim < hora início)
      if (horaFim.hour < horaInicio.hour) {
        // Vaga de ontem que vai até a madrugada de hoje - mostrar
        return true;
      }
    }
    
    // Vaga do passado
    return false;
  }

  /// Valida se uma data está no passado
  static bool isPastDate(DateTime date) {
    if (!isValidDate(date)) return false;
    
    final hoje = DateTime.now();
    final dataComparacao = DateTime(hoje.year, hoje.month, hoje.day);
    final dataVaga = DateTime(date.year, date.month, date.day);
    
    return dataVaga.isBefore(dataComparacao);
  }

  /// Valida se uma hora é válida
  static bool isValidTime(int hour, int minute) {
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  /// Valida se um ID é válido (maior que 0)
  static bool isValidId(int id) {
    return id > 0;
  }

  /// Valida se uma string não está vazia
  static bool isValidString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Valida se um email tem formato válido
  static bool isValidEmail(String email) {
    if (!isValidString(email)) return false;
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Valida se um telefone tem formato válido (Brasil)
  static bool isValidPhone(String phone) {
    if (!isValidString(phone)) return false;
    
    // Remove caracteres não numéricos
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se tem 10 ou 11 dígitos (com DDD)
    return cleanPhone.length == 10 || cleanPhone.length == 11;
  }

  /// Valida se uma senha atende aos requisitos de segurança
  static bool isValidPassword(String password) {
    if (!isValidString(password) || password.length < 8) return false;
    
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUpperCase && hasLowerCase && hasNumbers && hasSpecialChars;
  }

  /// Cria uma data segura a partir de componentes
  static DateTime? createSafeDate(int year, int month, int day) {
    try {
      final date = DateTime(year, month, day);
      return isValidDate(date) ? date : null;
    } catch (e) {
      debugPrint('[DataValidator] Erro ao criar data: $e');
      return null;
    }
  }

  /// Cria uma data/hora segura a partir de componentes
  static DateTime? createSafeDateTime(int year, int month, int day, int hour, int minute) {
    try {
      if (!isValidTime(hour, minute)) return null;
      
      final dateTime = DateTime(year, month, day, hour, minute);
      return isValidDate(dateTime) ? dateTime : null;
    } catch (e) {
      debugPrint('[DataValidator] Erro ao criar data/hora: $e');
      return null;
    }
  }
}
