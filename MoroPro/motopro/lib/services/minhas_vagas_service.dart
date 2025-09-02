import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/app_config.dart';

class MinhasVagasService {
  /// Busca todas as vagas reservadas do motoboy
  static Future<List<Candidatura>> getMinhasVagas() async {
    print('📡 [MinhasVagasService] Iniciando busca das minhas vagas...');
    try {
      debugPrint('[INFO] Buscando minhas vagas...');
      print('🔗 [MinhasVagasService] Endpoint: ${AppConfig.minhasVagas}');

      // Usando o endpoint correto: GET /api/v1/motoboy-vaga/minhas-vagas/
      final url = AppConfig.minhasVagas;
      debugPrint('[GET] $url');
      print('📤 [MinhasVagasService] Enviando requisição GET para: $url');

      final response = await DioClient.dio.get(
        url,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('📥 [MinhasVagasService] Resposta recebida - Status: ${response.statusCode}');
      debugPrint('[RESPONSE] Status: ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ [MinhasVagasService] Resposta 200 OK, processando dados...');
        final responseData = response.data as Map<String, dynamic>;
        final alocacoes = (responseData['alocacoes'] as List?) ?? [];
        print('📊 [MinhasVagasService] Total de alocações encontradas: ${alocacoes.length}');
        debugPrint('[INFO] Encontradas ${alocacoes.length} vagas reservadas');
        
        // Filtrar apenas vagas a partir da data atual
        print('🔍 [MinhasVagasService] Filtrando vagas futuras...');
        final vagasFiltradas = alocacoes.where((json) {
          try {
            final candidatura = Candidatura.fromJson(json);
            final hoje = DateTime.now();
            final dataVaga = candidatura.dataVaga;
            
            // Comparar apenas a data (ignorar hora)
            final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
            final dataVagaSemHora = DateTime(dataVaga.year, dataVaga.month, dataVaga.day);
            
            final isFutura = dataVagaSemHora.isAfter(hojeSemHora) || dataVagaSemHora.isAtSameMomentAs(hojeSemHora);
            print('📅 [MinhasVagasService] Vaga ${candidatura.id} - Data: $dataVagaSemHora, Hoje: $hojeSemHora, É futura: $isFutura');
            debugPrint('[DEBUG] Vaga ${candidatura.id} - Data: $dataVagaSemHora, Hoje: $hojeSemHora, É futura: $isFutura');
            
            return isFutura;
          } catch (e) {
            print('❌ [MinhasVagasService] Erro ao processar vaga: $e');
            debugPrint('[ERROR] Erro ao processar vaga: $e');
            return false;
          }
        }).toList();
        
        print('✅ [MinhasVagasService] Vagas filtradas (a partir de hoje): ${vagasFiltradas.length}');
        debugPrint('[INFO] Vagas filtradas (a partir de hoje): ${vagasFiltradas.length}');
        
        // Ordenar por data (mais próximas primeiro)
        print('📋 [MinhasVagasService] Ordenando vagas por data...');
        final candidaturas = vagasFiltradas.map((json) => Candidatura.fromJson(json)).toList();
        candidaturas.sort((a, b) => a.dataVaga.compareTo(b.dataVaga));
        
        print('🎯 [MinhasVagasService] Retornando ${candidaturas.length} candidaturas ordenadas');
        return candidaturas;
      }

      // Se chegou até aqui, retorna lista vazia
      print('⚠️ [MinhasVagasService] Status não é 200, retornando lista vazia');
      debugPrint('[INFO] Nenhuma resposta válida, retornando lista vazia');
      return [];

    } on DioException catch (e) {
      print('❌ [MinhasVagasService] DioException capturada: ${e.message}');
      print('📊 [MinhasVagasService] Status: ${e.response?.statusCode}');
      print('📄 [MinhasVagasService] Data: ${e.response?.data}');
      debugPrint('[ERROR] DioException: ${e.message}');
      debugPrint('[ERROR] Status: ${e.response?.statusCode}');
      debugPrint('[ERROR] Data: ${e.response?.data}');
      
      // Tratamento específico para diferentes tipos de erro
      if (e.response?.statusCode == 404) {
        print('ℹ️ [MinhasVagasService] 404 - Retornando lista vazia');
        debugPrint('[INFO] 404 - Retornando lista vazia');
        return [];
      } else if (e.response?.statusCode == 500) {
        print('ℹ️ [MinhasVagasService] 500 - Retornando lista vazia');
        debugPrint('[INFO] 500 - Retornando lista vazia');
        return [];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        print('⏰ [MinhasVagasService] Timeout de conexão');
        debugPrint('[ERROR] Timeout de conexão');
        return [];
      } else if (e.type == DioExceptionType.connectionError) {
        print('🔌 [MinhasVagasService] Erro de conexão');
        debugPrint('[ERROR] Erro de conexão');
        return [];
      }
      
      print('❓ [MinhasVagasService] Erro desconhecido, retornando lista vazia');
      debugPrint('[ERROR] Erro desconhecido, retornando lista vazia');
      return [];
    } catch (e) {
      print('💥 [MinhasVagasService] Erro geral capturado: $e');
      debugPrint('[ERROR] Erro geral: $e');
      return [];
    }
  }

  /// Inicia uma operação para uma alocação específica
  static Future<bool> iniciarOperacao(int alocacaoId) async {
    print('🚀 [MinhasVagasService] Iniciando operação para alocação ID: $alocacaoId');
    try {
      debugPrint('[INFO] Iniciando operação para alocação ID: $alocacaoId');
      print('🔗 [MinhasVagasService] Endpoint: ${AppConfig.operacaoIniciar}');
      
      final response = await DioClient.dio.post(
        AppConfig.operacaoIniciar,
        data: {
          'alocacao_id': alocacaoId,
        },
      );

      print('📥 [MinhasVagasService] Resposta recebida - Status: ${response.statusCode}');
      print('📄 [MinhasVagasService] Dados da resposta: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [MinhasVagasService] Operação iniciada com sucesso!');
        return true;
      } else {
        print('❌ [MinhasVagasService] Status não é 200/201: ${response.statusCode}');
        return false;
      }

    } on DioException catch (e) {
      print('❌ [MinhasVagasService] DioException ao iniciar operação: ${e.message}');
      print('📊 [MinhasVagasService] Status: ${e.response?.statusCode}');
      print('📄 [MinhasVagasService] Data: ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        print('ℹ️ [MinhasVagasService] 404 - Alocação não encontrada');
      } else if (e.response?.statusCode == 400) {
        print('ℹ️ [MinhasVagasService] 400 - Dados inválidos');
      } else if (e.response?.statusCode == 500) {
        print('ℹ️ [MinhasVagasService] 500 - Erro interno do servidor');
      }
      
      return false;
    } catch (e) {
      print('💥 [MinhasVagasService] Erro geral ao iniciar operação: $e');
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
