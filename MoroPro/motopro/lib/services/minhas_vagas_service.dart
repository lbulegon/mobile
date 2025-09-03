import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:motopro/services/network/dio_client.dart';
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
        final data = response.data;

        // Normalizar a lista de itens independente do formato
        List<dynamic> items;
        if (data is List) {
          items = data;
          print('ℹ️ [MinhasVagasService] Resposta é uma lista com ${items.length} itens');
        } else if (data is Map<String, dynamic>) {
          items = (data['alocacoes'] ??
                  data['results'] ??
                  data['data'] ??
                  data['items'] ??
                  data['vagas'] ??
                  []) as List<dynamic>;
          print('ℹ️ [MinhasVagasService] Resposta é um mapa. Itens normalizados: ${items.length}');
        } else {
          print('⚠️ [MinhasVagasService] Formato de resposta inesperado: ${data.runtimeType}');
          return [];
        }

        // Parsear primeiro em objetos de domínio
        final List<Candidatura> todas;
        try {
          todas = items.map((e) => Candidatura.fromJson(e as Map<String, dynamic>)).toList();
        } catch (e) {
          print('❌ [MinhasVagasService] Falha ao parsear itens: $e');
          return [];
        }
        print('📊 [MinhasVagasService] Total parseado: ${todas.length}');

        // Filtrar apenas vagas a partir da data atual (comparando apenas a data)
        final hoje = DateTime.now();
        final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
        final candidaturas = todas.where((c) {
          final d = DateTime(c.dataVaga.year, c.dataVaga.month, c.dataVaga.day);
          final isFuturaOuHoje = d.isAfter(hojeSemHora) || d.isAtSameMomentAs(hojeSemHora);
          print('📅 [MinhasVagasService] Candidatura ${c.id} em $d. Hoje: $hojeSemHora. Exibir: $isFuturaOuHoje');
          return isFuturaOuHoje;
        }).toList();

        // Caso tudo tenha sido filtrado, retornar ao menos todas para debug visual
        if (candidaturas.isEmpty && todas.isNotEmpty) {
          print('⚠️ [MinhasVagasService] Todas as vagas foram filtradas por data. Retornando todas para debug.');
          candidaturas.addAll(todas);
        }

        // Ordenar por data
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
