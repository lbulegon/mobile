class Candidatura {
  final int id;
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
      id: json['alocacao_id'] ?? json['id'],
      estabelecimento: json['empresa'] ?? json['estabelecimento'],
      endereco: json['endereco'],
      dataVaga: _parseData(json['data']),
      horaInicio: _parseHora(json['inicio']),
      horaFim: _parseHora(json['fim']),
      valor: (json['valor_vaga'] ?? 0.0).toDouble(),
      status: json['status'],
      dataCandidatura: DateTime.now(), // Campo não disponível na resposta
    );
  }

  static DateTime _parseData(String data) {
    // Formato: "22/08/2025" ou "2025-08-22"
    if (data.contains('/')) {
      final parts = data.split('/');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }
    return DateTime.parse(data);
  }

  static DateTime _parseHora(String hora) {
    // Formato: "18:00" ou "18:00:00"
    final parts = hora.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
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

