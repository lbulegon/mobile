class Operacao {
  final int id;
  final int candidaturaId;
  final String estabelecimento;
  final String endereco;
  final DateTime dataVaga;
  final DateTime horaInicio;
  final DateTime horaFim;
  final double valor;
  final String status;
  final DateTime? horaInicioAtividade;
  final DateTime? horaFimAtividade;
  final List<Pedido> pedidos;
  final List<Relatorio> relatorios;

  Operacao({
    required this.id,
    required this.candidaturaId,
    required this.estabelecimento,
    required this.endereco,
    required this.dataVaga,
    required this.horaInicio,
    required this.horaFim,
    required this.valor,
    required this.status,
    this.horaInicioAtividade,
    this.horaFimAtividade,
    required this.pedidos,
    required this.relatorios,
  });

  factory Operacao.fromJson(Map<String, dynamic> json) {
    return Operacao(
      id: json['id'],
      candidaturaId: json['candidatura_id'],
      estabelecimento: json['estabelecimento'],
      endereco: json['endereco'],
      dataVaga: DateTime.parse(json['data_vaga']),
      horaInicio: DateTime.parse(json['hora_inicio']),
      horaFim: DateTime.parse(json['hora_fim']),
      valor: json['valor'].toDouble(),
      status: json['status'],
      horaInicioAtividade: json['hora_inicio_atividade'] != null 
          ? DateTime.parse(json['hora_inicio_atividade']) 
          : null,
      horaFimAtividade: json['hora_fim_atividade'] != null 
          ? DateTime.parse(json['hora_fim_atividade']) 
          : null,
      pedidos: (json['pedidos'] as List?)
          ?.map((p) => Pedido.fromJson(p))
          .toList() ?? [],
      relatorios: (json['relatorios'] as List?)
          ?.map((r) => Relatorio.fromJson(r))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidatura_id': candidaturaId,
      'estabelecimento': estabelecimento,
      'endereco': endereco,
      'data_vaga': dataVaga.toIso8601String(),
      'hora_inicio': horaInicio.toIso8601String(),
      'hora_fim': horaFim.toIso8601String(),
      'valor': valor,
      'status': status,
      'hora_inicio_atividade': horaInicioAtividade?.toIso8601String(),
      'hora_fim_atividade': horaFimAtividade?.toIso8601String(),
      'pedidos': pedidos.map((p) => p.toJson()).toList(),
      'relatorios': relatorios.map((r) => r.toJson()).toList(),
    };
  }
}

class Pedido {
  final int id;
  final String cliente;
  final String enderecoEntrega;
  final String descricao;
  final double valor;
  final String status;
  final DateTime? horaColeta;
  final DateTime? horaEntrega;

  Pedido({
    required this.id,
    required this.cliente,
    required this.enderecoEntrega,
    required this.descricao,
    required this.valor,
    required this.status,
    this.horaColeta,
    this.horaEntrega,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      cliente: json['cliente'],
      enderecoEntrega: json['endereco_entrega'],
      descricao: json['descricao'],
      valor: json['valor'].toDouble(),
      status: json['status'],
      horaColeta: json['hora_coleta'] != null 
          ? DateTime.parse(json['hora_coleta']) 
          : null,
      horaEntrega: json['hora_entrega'] != null 
          ? DateTime.parse(json['hora_entrega']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'endereco_entrega': enderecoEntrega,
      'descricao': descricao,
      'valor': valor,
      'status': status,
      'hora_coleta': horaColeta?.toIso8601String(),
      'hora_entrega': horaEntrega?.toIso8601String(),
    };
  }
}

class Relatorio {
  final int id;
  final String tipo;
  final String descricao;
  final DateTime dataHora;
  final String? observacoes;

  Relatorio({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.dataHora,
    this.observacoes,
  });

  factory Relatorio.fromJson(Map<String, dynamic> json) {
    return Relatorio(
      id: json['id'],
      tipo: json['tipo'],
      descricao: json['descricao'],
      dataHora: DateTime.parse(json['data_hora']),
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'descricao': descricao,
      'data_hora': dataHora.toIso8601String(),
      'observacoes': observacoes,
    };
  }
}

