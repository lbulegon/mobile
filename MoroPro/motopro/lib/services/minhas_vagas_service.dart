import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/utils/data_validator.dart';
import 'package:motopro/services/offline_cache_service.dart';

class MinhasVagasService {
  /// Busca todas as vagas reservadas do motoboy
  static Future<List<Candidatura>> getMinhasVagas() async {
    try {
      debugPrint('[INFO] Buscando minhas vagas...');

      final url = AppConfig.minhasVagas; // GET /api/v1/motoboy-vaga/minhas-vagas/
      debugPrint('[GET] $url');
      
      // Verificar se há token antes de fazer a requisição
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('[ERROR] Sem token de acesso');
        return [];
      }
      debugPrint('[INFO] Token encontrado, fazendo requisição...');

      final response = await DioClient.dio.get(
        url,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('[RESPONSE] Status: ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Normalizar a lista de itens independente do formato
        List<dynamic> items;
        if (data is List) {
          items = data;
          debugPrint('[INFO] Resposta é uma lista com ${items.length} itens');
        } else if (data is Map<String, dynamic>) {
          items = (data['alocacoes'] ??
                  data['results'] ??
                  data['data'] ??
                  data['items'] ??
                  data['vagas'] ??
                  []) as List<dynamic>;
          debugPrint('[INFO] Resposta é um mapa. Itens normalizados: ${items.length}');
        } else {
          debugPrint('[WARN] Formato de resposta inesperado: ${data.runtimeType}');
          return [];
        }

        // Parsear primeiro em objetos de domínio
        final List<Candidatura> todas;
        try {
          todas = items.map((e) => Candidatura.fromJson(e as Map<String, dynamic>)).toList();
        } catch (e) {
          debugPrint('[ERROR] Falha ao parsear itens: $e');
          return [];
        }
        debugPrint('[INFO] Total parseado: ${todas.length}');

        // Filtrar vagas considerando data e horário (inclui vagas que vão até madrugada)
        final candidaturas = todas.where((c) {
          debugPrint('[DEBUG] Analisando vaga ${c.id} - Data: ${c.dataVaga} | Hora: ${c.horaInicio.hour}:${c.horaInicio.minute.toString().padLeft(2, '0')}-${c.horaFim.hour}:${c.horaFim.minute.toString().padLeft(2, '0')}');
          
          // Usar o novo método que considera data e horário
          final shouldShow = DataValidator.shouldShowVaga(c.dataVaga, c.horaInicio, c.horaFim);
          
          if (shouldShow) {
            debugPrint('[DEBUG] Vaga ${c.id} - Deve ser exibida: ${c.dataVaga}');
          } else {
            debugPrint('[DEBUG] Vaga ${c.id} - Não deve ser exibida: ${c.dataVaga}');
          }
          
          return shouldShow;
        }).toList();

        // Log do resultado do filtro
        debugPrint('[INFO] Vagas filtradas: ${candidaturas.length} de ${todas.length} total');

        // Ordenar por data (mais próximas primeiro)
        candidaturas.sort((a, b) => a.dataVaga.compareTo(b.dataVaga));
        
        // Salvar no cache offline para uso futuro
        try {
          final vagasParaCache = candidaturas.map((c) => c.toJson()).toList();
          await OfflineCacheService.saveMinhasVagas(vagasParaCache);
          debugPrint('[INFO] Dados salvos no cache offline');
        } catch (cacheError) {
          debugPrint('[WARN] Erro ao salvar cache offline: $cacheError');
        }
        
        return candidaturas;
      }

      // Se chegou até aqui, retorna lista vazia
      debugPrint('[INFO] Nenhuma resposta válida, retornando lista vazia');
      return [];

    } on DioException catch (e) {
      debugPrint('[ERROR] DioException: ${e.message}');
      debugPrint('[ERROR] Tipo: ${e.type}');
      debugPrint('[ERROR] Status: ${e.response?.statusCode}');
      debugPrint('[ERROR] Data: ${e.response?.data}');
      debugPrint('[ERROR] URL: ${e.requestOptions.uri}');
      
      // Tentar usar cache offline em caso de erro de conectividade
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        debugPrint('[INFO] Tentando usar cache offline...');
        try {
          final cachedData = await OfflineCacheService.getMinhasVagas();
          if (cachedData != null && cachedData.isNotEmpty) {
            debugPrint('[INFO] Usando dados do cache offline: ${cachedData.length} itens');
            final candidaturas = cachedData.map((e) => Candidatura.fromJson(e)).toList();
            
            // Aplicar filtro nas vagas do cache
            final candidaturasFiltradas = candidaturas.where((c) {
              return DataValidator.shouldShowVaga(c.dataVaga, c.horaInicio, c.horaFim);
            }).toList();
            
            candidaturasFiltradas.sort((a, b) => a.dataVaga.compareTo(b.dataVaga));
            return candidaturasFiltradas;
          }
        } catch (cacheError) {
          debugPrint('[ERROR] Erro ao usar cache offline: $cacheError');
        }
      }
      
      // Tratamento específico para diferentes tipos de erro
      if (e.response?.statusCode == 404) {
        debugPrint('[INFO] 404 - Retornando lista vazia');
        return [];
      } else if (e.response?.statusCode == 500) {
        debugPrint('[INFO] 500 - Retornando lista vazia');
        return [];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        debugPrint('[ERROR] Timeout de conexão - Verifique sua internet');
        return [];
      } else if (e.type == DioExceptionType.connectionError) {
        debugPrint('[ERROR] Erro de conexão - Verifique sua internet');
        return [];
      } else if (e.type == DioExceptionType.receiveTimeout) {
        debugPrint('[ERROR] Timeout de recebimento - Servidor lento');
        return [];
      } else if (e.type == DioExceptionType.sendTimeout) {
        debugPrint('[ERROR] Timeout de envio - Verifique sua internet');
        return [];
      } else if (e.type == DioExceptionType.badResponse) {
        debugPrint('[ERROR] Resposta inválida do servidor');
        return [];
      } else if (e.type == DioExceptionType.cancel) {
        debugPrint('[ERROR] Requisição cancelada');
        return [];
      } else if (e.type == DioExceptionType.unknown) {
        debugPrint('[ERROR] Erro desconhecido - Verifique sua conexão');
        return [];
      }
      
      debugPrint('[ERROR] Erro não tratado, retornando lista vazia');
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
