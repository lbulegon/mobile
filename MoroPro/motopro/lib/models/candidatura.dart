import 'package:motopro/utils/data_validator.dart';

class Candidatura {
  final int id;
  final int alocacaoId;
  final String estabelecimento;
  final String endereco;
  final DateTime dataVaga;
  final DateTime horaInicio;
  final DateTime horaFim;
  final double valor;
  final String status;
  final DateTime dataCandidatura;

  Candidatura({
    required this.id,
    required this.alocacaoId,
    required this.estabelecimento,
    required this.endereco,
    required this.dataVaga,
    required this.horaInicio,
    required this.horaFim,
    required this.valor,
    required this.status,
    required this.dataCandidatura,
  });

  factory Candidatura.fromJson(Map<String, dynamic> json) {
    return Candidatura(
      id: _parseId(json['vaga_id'] ?? json['id']),
      alocacaoId: _parseId(json['alocacao_id'] ?? json['id']),
      estabelecimento: _parseString(json['empresa'] ?? json['estabelecimento']),
      endereco: _parseString(json['endereco']),
      dataVaga: _parseData(json['data']),
      horaInicio: _parseHora(json['inicio']),
      horaFim: _parseHora(json['fim']),
      valor: _parseValor(json['valor_vaga']),
      status: _parseString(json['status']),
      dataCandidatura: DateTime.now(), // Campo não disponível na resposta
    );
  }

  static int _parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static double _parseValor(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseData(dynamic data) {
    if (data == null) return DateTime.now();
    
    try {
      final dataStr = data.toString().trim();
      
      // Formato: "22/08/2025" ou "2025-08-22"
      if (dataStr.contains('/')) {
        final parts = dataStr.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final month = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          final date = DataValidator.createSafeDate(year, month, day);
          return date ?? DateTime.now();
        }
      }
      
      // Tentar parsear como ISO
      final parsed = DateTime.tryParse(dataStr);
      if (parsed != null && DataValidator.isValidDate(parsed)) {
        return parsed;
      }
      
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static DateTime _parseHora(dynamic hora) {
    if (hora == null) return DateTime.now();
    
    try {
      final horaStr = hora.toString().trim();
      final parts = horaStr.split(':');
      
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        
        if (DataValidator.isValidTime(hour, minute)) {
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, hour, minute);
        }
      }
      
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estabelecimento': estabelecimento,
      'endereco': endereco,
      'data_vaga': dataVaga.toIso8601String(),
      'hora_inicio': horaInicio.toIso8601String(),
      'hora_fim': horaFim.toIso8601String(),
      'valor': valor,
      'status': status,
      'data_candidatura': dataCandidatura.toIso8601String(),
    };
  }
}

