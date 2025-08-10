// lib/services/api_vagas.dart
import 'dart:convert';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/api_client.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/utils/date_utils.dart';

Future<List<Vaga>> fetchVagas() async {
  final response = await ApiClient.get('/vagas/', query: {'status': 'aberta'});
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final list = (data is List) ? data : (data['results'] ?? []);
    return List.from(list).map((v) => Vaga.fromJson(v)).toList();
  } else {
    throw Exception(
        'Erro ao buscar vagas: ${response.statusCode} — ${response.body}');
  }
}

Future<List<Vaga>> fetchMinhasVagas() async {
  final response = await ApiClient.get('/vagas/minhas-vagas/');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final list = (data is List) ? data : (data['results'] ?? []);
    return List.from(list).map((v) => Vaga.fromJson(v)).toList();
  } else {
    throw Exception(
        'Erro ao buscar suas vagas: ${response.statusCode} — ${response.body}');
  }
}

Future<void> candidatarVaga({
  required int motoboyId,
  required int estabelecimentoId,
  required String data,
  required String horaInicio,
  required String horaFim,
}) async {
  final payload = {
    "motoboy": motoboyId,
    "estabelecimento": estabelecimentoId,
    "data": formatarDataISO(data),
    "hora_inicio": '$horaInicio:00',
    "hora_fim": (horaFim == '00:00') ? '23:59:00' : '$horaFim:00',
  };
  final response = await ApiClient.post(AppConfig.candidatar, payload);
  if (response.statusCode != 200 && response.statusCode != 201) {
    try {
      final erro = jsonDecode(response.body);
      throw Exception(
          'Erro ao candidatar-se: ${erro['detail'] ?? response.body}');
    } catch (_) {
      throw Exception('Erro ao candidatar-se: ${response.body}');
    }
  }
}
