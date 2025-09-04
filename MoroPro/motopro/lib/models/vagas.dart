// motopro/lib/models/vagas.dart
import 'package:intl/intl.dart';
import 'package:motopro/utils/data_validator.dart';

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
      DateTime? parsedDate;
      
      // Tentar parsear como ISO primeiro
      try {
        parsedDate = DateFormat('yyyy-MM-dd').parseStrict(rawDate);
      } catch (_) {
        parsedDate = DateTime.tryParse(rawDate);
      }
      
      // Validar se a data é válida
      if (parsedDate != null && DataValidator.isValidDate(parsedDate)) {
        dataIsoFormatada = DateFormat('yyyy-MM-dd').format(parsedDate);
        final formatter = DateFormat('EEEE, dd/MM/yyyy', 'pt_BR');
        diaFormatado = formatter.format(parsedDate).replaceFirstMapped(
              RegExp(r'^\w'),
              (m) => m.group(0)!.toUpperCase(),
            );
      } else {
        // Fallback para data inválida
        diaFormatado = rawDate.isNotEmpty ? rawDate : 'Data não informada';
        dataIsoFormatada = '';
      }
    } catch (e) {
      diaFormatado = rawDate.isNotEmpty ? rawDate : 'Data não informada';
      dataIsoFormatada = '';
    }

    // Preferir campos formatados vindos da API, com fallback seguro para os padrões
    final String inicioRaw =
        (json['hora_inicio_formatada'] ?? json['hora_inicio_padrao'] ?? '')
            .toString();
    final String fimRaw =
        (json['hora_fim_formatada'] ?? json['hora_fim_padrao'] ?? '')
            .toString();
    
    // Validar e formatar horas
    final String inicio = _formatTime(inicioRaw);
    final String fim = _formatTime(fimRaw);
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

  /// Formata e valida uma string de tempo
  static String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '00:00';
    
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        
        if (DataValidator.isValidTime(hour, minute)) {
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
      }
    } catch (e) {
      // Fallback para formato inválido
    }
    
    return '00:00';
  }
}
