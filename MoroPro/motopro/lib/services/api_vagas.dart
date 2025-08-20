// lib/services/api_vagas.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/api_client.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/utils/date_utils.dart';

// Função auxiliar para formatar horário corretamente
String formatarHora(String hora) {
  if (hora == '00:00') {
    return '00:00:00'; // Mantém a virada de meia-noite
  }
  return '$hora:00'; // Adiciona segundos
}

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
  required int vagaId,
  required int estabelecimentoId,
  required String data,
  required String horaInicio,
  required String horaFim,
}) async {
  // Tenta APENAS com vaga_id (método mais simples e direto)
  final payload = {
    "vaga_id": vagaId,
  };
  
  // DEBUG: Log do payload
  debugPrint('🔍 DEBUG - Payload candidatura:');
  debugPrint('  vaga_id: $vagaId');
  debugPrint('  payload: $payload');
  
  final response = await ApiClient.post(AppConfig.candidatar, payload);
  
  // DEBUG: Log da resposta
  debugPrint('🔍 DEBUG - Resposta do servidor:');
  debugPrint('  status: ${response.statusCode}');
  debugPrint('  body: ${response.body}');
  
  if (response.statusCode == 200 || response.statusCode == 201) {
    debugPrint('✅ Sucesso na candidatura!');
    return;
  }
  
  // Se falhou, tenta com payload completo como fallback
  debugPrint('⚠️ Fallback para payload completo...');
  
  final payloadCompleto = {
    "motoboy": motoboyId,
    "vaga_id": vagaId,
    "estabelecimento": estabelecimentoId,
    "data": formatarDataISO(data),
    "hora_inicio": formatarHora(horaInicio),
    "hora_fim": formatarHora(horaFim),
  };
  
  debugPrint('🔍 DEBUG - Horários formatados:');
  debugPrint('  hora_inicio: ${formatarHora(horaInicio)}');
  debugPrint('  hora_fim: ${formatarHora(horaFim)}');
  
  debugPrint('🔍 DEBUG - Payload completo:');
  debugPrint('  payload: $payloadCompleto');
  
  final responseCompleto = await ApiClient.post(AppConfig.candidatar, payloadCompleto);
  
  debugPrint('🔍 DEBUG - Resposta payload completo:');
  debugPrint('  status: ${responseCompleto.statusCode}');
  debugPrint('  body: ${responseCompleto.body}');
  
  if (responseCompleto.statusCode != 200 && responseCompleto.statusCode != 201) {
    try {
      final erro = jsonDecode(responseCompleto.body);
      throw Exception(
          'Erro ao candidatar-se: ${erro['detail'] ?? responseCompleto.body}');
    } catch (_) {
      throw Exception('Erro ao candidatar-se: ${responseCompleto.body}');
    }
  }
}

Future<void> cancelarCandidatura(int vagaId) async {
  final payload = {
    "vaga_id": vagaId,
  };
  final response = await ApiClient.post(AppConfig.cancelarCandidatura, payload);
  if (response.statusCode != 200 && response.statusCode != 204) {
    try {
      final erro = jsonDecode(response.body);
      throw Exception(
          'Erro ao cancelar candidatura: ${erro['detail'] ?? response.body}');
    } catch (_) {
      throw Exception('Erro ao cancelar candidatura: ${response.body}');
    }
  }
}

// Método simplificado que tenta candidatar apenas com o ID da vaga
Future<void> candidatarVagaSimples(int vagaId) async {
  debugPrint('🔍 DEBUG - Candidatura simples para vaga: $vagaId');
  
  final payload = {
    "vaga_id": vagaId,
  };
  
  final response = await ApiClient.post(AppConfig.candidatar, payload);
  
  debugPrint('🔍 DEBUG - Resposta candidatura simples:');
  debugPrint('  status: ${response.statusCode}');
  debugPrint('  body: ${response.body}');
  
  if (response.statusCode != 200 && response.statusCode != 201) {
    try {
      final erro = jsonDecode(response.body);
      throw Exception(
          'Erro ao candidatar-se: ${erro['detail'] ?? response.body}');
    } catch (_) {
      throw Exception('Erro ao candidatar-se: ${response.body}');
    }
  }
  
  debugPrint('✅ Sucesso na candidatura simples!');
}
