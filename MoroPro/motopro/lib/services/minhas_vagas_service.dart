import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:motopro/models/operacao.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/services/local_storage.dart';

class MinhasVagasService {
    /// Busca todas as vagas reservadas do motoboy
  static Future<List<Candidatura>> getMinhasVagas() async {
    try {
      // Primeiro, precisamos obter o ID do motoboy
      final motoboyId = await LocalStorage.getMotoboyId();
      if (motoboyId == null) {
        debugPrint('[ERROR] Motoboy ID não encontrado');
        return [];
      }

      // O endpoint só aceita POST, não GET
      final url = '${AppConfig.apiUrl}/motoboy-vaga/motoboy/$motoboyId/';
      debugPrint('[POST] $url');

      final response = await DioClient.dio.post(
        url,
        data: {
          "motoboy_id": motoboyId,
          "status": "ativa"
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('[RESPONSE] Status: ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = (response.data as List?) ?? [];
        debugPrint('[INFO] Encontradas ${data.length} vagas reservadas');
        return data.map((json) => Candidatura.fromJson(json)).toList();
      }

      // Se chegou até aqui, retorna lista vazia
      debugPrint('[INFO] Nenhuma resposta válida, retornando lista vazia');
      return [];
    } on DioException catch (e) {
      debugPrint('[ERROR] DioException: ${e.message}');
      debugPrint('[ERROR] Status: ${e.response?.statusCode}');
      debugPrint('[ERROR] Data: ${e.response?.data}');
      debugPrint('[ERROR] Headers: ${e.response?.headers}');
      
      // Se for erro 404, 500 ou erro de conexão, retorna lista vazia
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        debugPrint('[INFO] ${e.response?.statusCode} - Retornando lista vazia');
        return [];
      }
      
      // Se for erro de conexão ou timeout, retorna lista vazia
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        debugPrint('[INFO] Erro de conexão - Retornando lista vazia');
        return [];
      }
      
      // Para outros erros, também retorna lista vazia para não quebrar a UI
      debugPrint('[INFO] Outro erro - Retornando lista vazia');
      return [];
    } catch (e) {
      debugPrint('[ERROR] Exception: $e');
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Inicia uma operação para uma candidatura
  static Future<Operacao> iniciarOperacao(int candidaturaId) async {
    try {
      final response = await DioClient.dio.post(
        '${AppConfig.apiUrl}/operacao/iniciar/',
        data: {
          'candidatura_id': candidaturaId,
        },
      );

      return Operacao.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao iniciar operação: ${e.message}');
    }
  }

  /// Busca operação ativa (em andamento)
  static Future<Operacao?> getOperacaoAtiva() async {
    try {
      final response = await DioClient.dio.get(
        '${AppConfig.apiUrl}/operacao/ativa/',
      );

      if (response.data != null) {
        return Operacao.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Nenhuma operação ativa
      }
      throw Exception('Erro ao buscar operação ativa: ${e.message}');
    }
  }

  /// Cancela uma reserva de vaga
  static Future<void> cancelarCandidatura(int candidaturaId) async {
    try {
      await DioClient.dio.post(
        '${AppConfig.apiUrl}/motoboy-vaga/cancelar/',
        data: {
          'candidatura_id': candidaturaId,
        },
      );
    } on DioException catch (e) {
      throw Exception('Erro ao cancelar reserva: ${e.message}');
    }
  }

  /// Busca detalhes de uma vaga reservada específica
  static Future<Candidatura> getCandidatura(int candidaturaId) async {
    try {
      final response = await DioClient.dio.get(
        '${AppConfig.apiUrl}/motoboy-vaga/$candidaturaId/',
      );

      return Candidatura.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao buscar vaga reservada: ${e.message}');
    }
  }
}
