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
      final url = AppConfig.minhasVagas; // GET /api/v1/motoboy-vaga/minhas-vagas/
      
      // Verificar se há token válido antes de fazer a requisição
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      final response = await DioClient.dio.get(
        url,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Normalizar a lista de itens independente do formato
        List<dynamic> items;
        if (data is List) {
          items = data;
        } else if (data is Map<String, dynamic>) {
          items = (data['alocacoes'] ??
                  data['results'] ??
                  data['data'] ??
                  data['items'] ??
                  data['vagas'] ??
                  []) as List<dynamic>;
        } else {
          return [];
        }

        // Parsear primeiro em objetos de domínio
        final List<Candidatura> todas;
        try {
          todas = items.map((e) => Candidatura.fromJson(e as Map<String, dynamic>)).toList();
        } catch (e) {
          return [];
        }

        // Filtrar vagas considerando data e horário (inclui vagas que vão até madrugada)
        final candidaturas = todas.where((c) {
          // Usar o novo método que considera data e horário
          final shouldShow = DataValidator.shouldShowVaga(c.dataVaga, c.horaInicio, c.horaFim);
          return shouldShow;
        }).toList();

        // Ordenar por data (mais próximas primeiro)
        candidaturas.sort((a, b) => a.dataVaga.compareTo(b.dataVaga));
        
        // Salvar no cache offline para uso futuro
        try {
          final vagasParaCache = candidaturas.map((c) => c.toJson()).toList();
          await OfflineCacheService.saveMinhasVagas(vagasParaCache);
        } catch (cacheError) {
          // Erro silencioso no cache
        }
        
        return candidaturas;
      }

      // Se chegou até aqui, retorna lista vazia
      return [];

    } on DioException catch (e) {
      
      // Tentar usar cache offline em caso de erro de conectividade
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        try {
          final cachedData = await OfflineCacheService.getMinhasVagas();
          if (cachedData != null && cachedData.isNotEmpty) {
            final candidaturas = cachedData.map((e) => Candidatura.fromJson(e)).toList();
            
            // Aplicar filtro nas vagas do cache
            final candidaturasFiltradas = candidaturas.where((c) {
              return DataValidator.shouldShowVaga(c.dataVaga, c.horaInicio, c.horaFim);
            }).toList();
            
            candidaturasFiltradas.sort((a, b) => a.dataVaga.compareTo(b.dataVaga));
            return candidaturasFiltradas;
          }
        } catch (cacheError) {
          // Erro silencioso no cache
        }
      }
      
      // Tratamento específico para diferentes tipos de erro
      if (e.response?.statusCode == 404) {
        return [];
      } else if (e.response?.statusCode == 500) {
        return [];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        return [];
      } else if (e.type == DioExceptionType.connectionError) {
        return [];
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return [];
      } else if (e.type == DioExceptionType.sendTimeout) {
        return [];
      } else if (e.type == DioExceptionType.badResponse) {
        return [];
      } else if (e.type == DioExceptionType.cancel) {
        return [];
      } else if (e.type == DioExceptionType.unknown) {
        return [];
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Inicia uma operação para uma alocação específica
  static Future<bool> iniciarOperacao(int alocacaoId) async {
    try {
      final response = await DioClient.dio.post(
        AppConfig.operacaoIniciar,
        data: {
          "alocacao_id": alocacaoId,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Busca operação ativa do motoboy
  static Future<Map<String, dynamic>?> getOperacaoAtiva() async {
    try {
      final response = await DioClient.dio.get(AppConfig.operacaoAtiva);
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
