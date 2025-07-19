// lib/services/api_vagas.dart
import 'dart:convert';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/api_client.dart';
import 'package:motopro/utils/date_utils.dart';

/// 🔍 Buscar vagas abertas
Future<List<Vaga>> fetchVagas() async {
  final response = await ApiClient.get('/vagas/?status=aberta');

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((vaga) => Vaga.fromJson(vaga)).toList();
  } else {
    throw Exception('Erro ao buscar vagas: ${response.statusCode}');
  }
}

/// 🔍 Buscar minhas vagas (vagas onde estou alocado ou vinculado)
Future<List<Vaga>> fetchMinhasVagas() async {
  final response = await ApiClient.get('/vagas/minhas-vagas/');

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((vaga) => Vaga.fromJson(vaga)).toList();
  } else {
    throw Exception('Erro ao buscar suas vagas: ${response.statusCode}');
  }
}

/// ✅ Candidatar-se a uma vaga
Future<void> candidatarVaga({
  required int motoboyId,
  required int estabelecimentoId,
  required String data,
  required String horaInicio,
  required String horaFim,
}) async {
  if (motoboyId == 0) {
    throw Exception('Motoboy ID não encontrado. Faça login novamente.');
  }

  if (estabelecimentoId == 0) {
    throw Exception('Estabelecimento ID inválido.');
  }

  final dataFormatada = formatarDataISO(data);
  final horaInicioFormatado = '$horaInicio:00';
  final horaFimFormatado = (horaFim == '00:00') ? '23:59:00' : '$horaFim:00';

  final payload = {
    "motoboy": motoboyId,
    "estabelecimento": estabelecimentoId,
    "data": dataFormatada,
    "hora_inicio": horaInicioFormatado,
    "hora_fim": horaFimFormatado,
  };

  print('[📤 ENVIANDO CANDIDATURA]');
  print(payload);

  final response = await ApiClient.post(
    AppConfig.candidatar,
    payload,
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    try {
      final erro = jsonDecode(response.body);
      throw Exception(
        'Erro ao candidatar-se: ${erro['detail'] ?? response.body}',
      );
    } catch (_) {
      throw Exception('Erro ao candidatar-se: ${response.body}');
    }
  }

  print('[✅ CANDIDATURA CONFIRMADA] Status: ${response.statusCode}');
}

/// 🚫 Cancelar candidatura na vaga
Future<void> cancelarCandidatura(int vagaId) async {
  final response =
      await ApiClient.post('/vagas/$vagaId/cancelar-candidatura/', {});

  if (response.statusCode != 200) {
    throw Exception('Erro ao cancelar candidatura: ${response.body}');
  }
}
