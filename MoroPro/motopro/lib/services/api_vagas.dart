// lib/services/api_vagas.dart
import 'dart:convert';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/services/api_client.dart';
import '../utils/date_utils.dart';

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
Future<void> candidatarVaga(Vaga vaga, int motoboyId) async {
  final motoboyId = await LocalStorage.getMotoboyId();

  if (motoboyId == 0) {
    throw Exception('Motoboy ID não encontrado. Faça login novamente.');
  }

  if (vaga.estabelecimentoId == 0) {
    throw Exception('Estabelecimento ID inválido.');
  }

  final dataFormatada = formatarDataISO(vaga.dataISO);

  print('[DEBUG] Enviando candidatura com:');
  print({
    "motoboy": motoboyId,
    "estabelecimento": vaga.estabelecimentoId,
    "data": dataFormatada,
    "hora_inicio": "${vaga.horaInicio}:00",
    "hora_fim": "${vaga.horaFim == '00:00' ? '23:59' : vaga.horaFim}:00",
  });

  final response = await ApiClient.post(
    '/motoboy-vaga/candidatar/',
    {
      "motoboy": motoboyId,
      "estabelecimento": vaga.estabelecimentoId,
      "data": dataFormatada,
      "hora_inicio": "${vaga.horaInicio}:00",
      "hora_fim": "${vaga.horaFim == '00:00' ? '23:59' : vaga.horaFim}:00",
    },
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Erro ao candidatar-se: ${response.body}');
  }
}

/// 🚫 Cancelar candidatura na vaga
Future<void> cancelarCandidatura(int vagaId) async {
  final response =
      await ApiClient.post('/vagas/$vagaId/cancelar-candidatura/', {});

  if (response.statusCode != 200) {
    throw Exception('Erro ao cancelar candidatura: ${response.body}');
  }
}
