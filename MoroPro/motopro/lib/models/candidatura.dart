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
    // Suporte a múltiplas variações de chaves vindas da API
    final dynamic idRaw = json['id'] ?? json['vaga_id'] ?? json['alocacao_id'] ?? 0;
    final dynamic alocacaoIdRaw = json['alocacao_id'] ?? json['alocacao'] ?? json['id'] ?? 0;
    final String estabelecimento = (json['estabelecimento_nome'] ?? json['empresa'] ?? json['estabelecimento'] ?? 'Estabelecimento')
        .toString();
    final String endereco = (json['local'] ?? json['endereco'] ?? json['estabelecimento_endereco'] ?? 'Endereço não informado')
        .toString();

    // Datas e Horas: aceitar formatos novos e antigos
    final String dataStr = (json['data'] ?? json['data_da_vaga'] ?? '').toString();
    final String inicioStr = (json['inicio'] ?? json['hora_inicio_formatada'] ?? json['hora_inicio_padrao'] ?? '').toString();
    final String fimStr = (json['fim'] ?? json['hora_fim_formatada'] ?? json['hora_fim_padrao'] ?? '').toString();

    final DateTime dataVaga = _parseData(dataStr);
    final DateTime horaInicio = _parseHora(inicioStr, baseDate: dataVaga);
    final DateTime horaFim = _parseHora(fimStr, baseDate: dataVaga);

    final double valor = _toDouble(json['valor_vaga'] ?? json['valor'] ?? 0);
    final String status = (json['status'] ?? '').toString();

    return Candidatura(
      id: _toInt(idRaw),
      alocacaoId: _toInt(alocacaoIdRaw),
      estabelecimento: estabelecimento,
      endereco: endereco,
      dataVaga: dataVaga,
      horaInicio: horaInicio,
      horaFim: horaFim,
      valor: valor,
      status: status,
      dataCandidatura: DateTime.now(),
    );
  }

  static DateTime _parseData(String? data) {
    if (data == null || data.isEmpty) return DateTime.now();
    // Suportar formatos: "22/08/2025" ou "2025-08-22"
    if (data.contains('/')) {
      final parts = data.split('/');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }
    // Se vier com hora, manter só a data
    try {
      final dt = DateTime.parse(data);
      return DateTime(dt.year, dt.month, dt.day);
    } catch (_) {
      return DateTime.now();
    }
  }

  static DateTime _parseHora(String? hora, {DateTime? baseDate}) {
    // Formatos aceitos: "18:00", "18:00:00"
    if (hora == null || hora.isEmpty) {
      final now = baseDate ?? DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    final parts = hora.split(':');
    final bd = baseDate ?? DateTime.now();
    int hh = 0, mm = 0;
    try {
      hh = int.parse(parts[0]);
      mm = int.parse(parts[1]);
    } catch (_) {}
    return DateTime(bd.year, bd.month, bd.day, hh, mm);
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
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

