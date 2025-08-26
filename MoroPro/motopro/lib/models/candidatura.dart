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
      id: json['id'],
      estabelecimento: json['estabelecimento'],
      endereco: json['endereco'],
      dataVaga: DateTime.parse(json['data_vaga']),
      horaInicio: DateTime.parse(json['hora_inicio']),
      horaFim: DateTime.parse(json['hora_fim']),
      valor: json['valor'].toDouble(),
      status: json['status'],
      dataCandidatura: DateTime.parse(json['data_candidatura']),
    );
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

