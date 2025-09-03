// motopro/lib/models/vagas.dart
import 'package:intl/intl.dart';

class Vaga {
  final int id;
  final String empresa;
  final String local;
  final String dia;
  final String hora;
  final String observacao;
  final int estabelecimentoId;
  final String horaInicio;
  final String horaFim;
  final String _dataISO;
  final int quantidadeDisponivel;

  Vaga({
    required this.id,
    required this.empresa,
    required this.local,
    required this.dia,
    required this.hora,
    required this.observacao,
    required this.estabelecimentoId,
    required this.horaInicio,
    required this.horaFim,
    required String dataISO,
    required this.quantidadeDisponivel,
  }) : _dataISO = dataISO;

  String get dataISO => _dataISO;

  factory Vaga.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['data_da_vaga'] ?? '').toString().trim();
    String diaFormatado = '';
    String dataIsoFormatada = '';

    try {
      DateTime parsedDate;
      try {
        parsedDate = DateFormat('yyyy-MM-dd').parseStrict(rawDate);
      } catch (_) {
        parsedDate = DateTime.tryParse(rawDate) ??
            (throw FormatException('Formato inválido: $rawDate'));
      }

      dataIsoFormatada = DateFormat('yyyy-MM-dd').format(parsedDate);
      final formatter = DateFormat('EEEE, dd/MM/yyyy', 'pt_BR');
      diaFormatado = formatter.format(parsedDate).replaceFirstMapped(
            RegExp(r'^\w'),
            (m) => m.group(0)!.toUpperCase(),
          );
    } catch (e) {
      diaFormatado = rawDate;
      dataIsoFormatada = '';
    }

    // Preferir campos formatados vindos da API, com fallback seguro para os padrões
    final String inicioRaw =
        (json['hora_inicio_formatada'] ?? json['hora_inicio_padrao'] ?? '')
            .toString();
    final String fimRaw =
        (json['hora_fim_formatada'] ?? json['hora_fim_padrao'] ?? '')
            .toString();
    final String inicio = inicioRaw.length >= 5 ? inicioRaw.substring(0, 5) : inicioRaw;
    final String fim = fimRaw.length >= 5 ? fimRaw.substring(0, 5) : fimRaw;
    final horaFormatada = '$inicio às $fim';

    // Se a API enviar a data já formatada, priorizar para exibição
    final diaApi = (json['data_formatada'] ?? '').toString().trim();
    if (diaApi.isNotEmpty) {
      diaFormatado = diaApi;
    }

    return Vaga(
      id: json['id'] ?? 0,
      empresa: json['estabelecimento_nome'] ?? 'Desconhecido',
      local: (json['local'] ?? json['estabelecimento_endereco'] ?? 'Endereço não informado')
          .toString(),
      dia: diaFormatado,
      hora: horaFormatada,
      observacao: '',
      estabelecimentoId: json['estabelecimento_id'] ?? 0,
      horaInicio: inicio,
      horaFim: fim,
      dataISO: dataIsoFormatada,
      quantidadeDisponivel: json['quantidade_vagas_disponiveis'] ?? 0,
    );
  }
}
