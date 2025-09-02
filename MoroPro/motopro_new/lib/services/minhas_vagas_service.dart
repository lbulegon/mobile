import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/app_config.dart';

class MinhasVagasService {
  /// Busca todas as vagas reservadas do motoboy
  static Future<List<Candidatura>> getMinhasVagas() async {
    try {
      debugPrint('[INFO] Buscando minhas vagas...');

      // Usando o endpoint correto: GET /api/v1/motoboy-vaga/minhas-vagas/
      final url = AppConfig.minhasVagas;
      debugPrint('[GET] $url');

      final response = await DioClient.dio.get(
        url,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('[RESPONSE] Status: ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final alocacoes = (responseData['alocacoes'] as List?) ?? [];
        debugPrint('[INFO] Encontradas ${alocacoes.length} vagas reservadas');
        
        // Filtrar apenas vagas a partir da data atual
        final vagasFiltradas = alocacoes.where((json) {
          try {
            final candidatura = Candidatura.fromJson(json);
            final hoje = DateTime.now();
            final dataVaga = candidatura.dataVaga;
            
            // Comparar apenas a data (ignorar hora)
            final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
            final dataVagaSemHora = DateTime(dataVaga.year, dataVaga.month, dataVaga.day);
            
            final isFutura = dataVagaSemHora.isAfter(hojeSemHora) || dataVagaSemHora.isAtSameMomentAs(hojeSemHora);
            debugPrint('[DEBUG] Vaga ${candidatura.id} - Data: $dataVagaSemHora, Hoje: $hojeSemHora, É futura: $isFutura');
            
            return isFutura;
          } catch (e) {
            debugPrint('[ERROR] Erro ao processar vaga: $e');
            return false;
          }
        }).toList();
        
        debugPrint('[INFO] Vagas filtradas (a partir de hoje): ${vagasFiltradas.length}');
        
        // Ordenar por data (mais próximas primeiro)
        final candidaturas = vagasFiltradas.map((json) => Candidatura.fromJson(json)).toList();
        candidaturas.sort((a, b) => a.dataVaga.compareTo(b.dataVaga));
        
        return candidaturas;
      }

      // Se chegou até aqui, retorna lista vazia
      debugPrint('[INFO] Nenhuma resposta válida, retornando lista vazia');
      return [];

    } on DioException catch (e) {
      debugPrint('[ERROR] DioException: ${e.message}');
      debugPrint('[ERROR] Status: ${e.response?.statusCode}');
      debugPrint('[ERROR] Data: ${e.response?.data}');
      
      // Tratamento específico para diferentes tipos de erro
      if (e.response?.statusCode == 404) {
        debugPrint('[INFO] 404 - Retornando lista vazia');
        return [];
      } else if (e.response?.statusCode == 500) {
        debugPrint('[INFO] 500 - Retornando lista vazia');
        return [];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        debugPrint('[ERROR] Timeout de conexão');
        return [];
      } else if (e.type == DioExceptionType.connectionError) {
        debugPrint('[ERROR] Erro de conexão');
        return [];
      }
      
      debugPrint('[ERROR] Erro desconhecido, retornando lista vazia');
      return [];
    } catch (e) {
      debugPrint('[ERROR] Erro geral: $e');
      return [];
    }
  }

  /// Inicia uma operação para uma alocação específica
  static Future<bool> iniciarOperacao(int alocacaoId) async {
    try {
      debugPrint('[INFO] Iniciando operação para alocação ID: $alocacaoId');
      
      final response = await DioClient.dio.post(
        AppConfig.operacaoIniciar,
        data: {
          "alocacao_id": alocacaoId,
        },
      );

      debugPrint('[RESPONSE] Operação iniciada: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[ERROR] Erro ao iniciar operação: $e');
      return false;
    }
  }

  /// Busca operação ativa do motoboy
  static Future<Map<String, dynamic>?> getOperacaoAtiva() async {
    try {
      debugPrint('[INFO] Buscando operação ativa');
      
      final response = await DioClient.dio.get(AppConfig.operacaoAtiva);
      
      debugPrint('[RESPONSE] Operação ativa: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('[ERROR] Erro ao buscar operação ativa: $e');
      return null;
    }
  }
}
