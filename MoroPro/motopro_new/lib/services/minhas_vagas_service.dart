import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/utils/app_config.dart';

class MinhasVagasService {
  /// Busca todas as vagas reservadas do motoboy
  static Future<List<Candidatura>> getMinhasVagas() async {
    try {
      debugPrint('[INFO] Buscando minhas vagas...');

      final url = AppConfig.minhasVagas; // GET /api/v1/motoboy-vaga/minhas-vagas/
      debugPrint('[GET] $url');

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

        // Filtrar apenas vagas da data e hora atual em diante
        // Inclui vagas futuras e vagas que ainda não terminaram hoje
        // Também inclui vagas com data final em maio (ou qualquer mês futuro)
        final agora = DateTime.now();
        final candidaturas = todas.where((c) {
          // Criar DateTime completo da vaga (data + hora de início)
          final dataHoraVaga = DateTime(
            c.dataVaga.year,
            c.dataVaga.month,
            c.dataVaga.day,
            c.horaInicio.hour,
            c.horaInicio.minute,
          );
          
          // Se a data/hora da vaga for posterior à data/hora atual, inclui
          // Isso inclui automaticamente vagas de maio e outros meses futuros
          if (dataHoraVaga.isAfter(agora)) {
            debugPrint('[DEBUG] Vaga ${c.id} - Data/hora futura: ${dataHoraVaga} (atual: $agora)');
            return true;
          }
          
          // Se for exatamente hoje e a hora atual ainda não passou do início da vaga
          if (c.dataVaga.year == agora.year &&
              c.dataVaga.month == agora.month &&
              c.dataVaga.day == agora.day) {
            
            // Converter tudo para minutos para facilitar a comparação
            final minutosAtual = agora.hour * 60 + agora.minute;
            final minutosInicio = c.horaInicio.hour * 60 + c.horaInicio.minute;
            final minutosFim = c.horaFim.hour * 60 + c.horaFim.minute;
            
            // Inclui se:
            // 1. Ainda não começou (minutosAtual < minutosInicio) OU
            // 2. Já começou mas ainda não terminou (minutosAtual >= minutosInicio && minutosAtual < minutosFim)
            final aindaNaoComecou = minutosAtual < minutosInicio;
            final estaEmAndamento = minutosAtual >= minutosInicio && minutosAtual < minutosFim;
            
            final deveIncluir = aindaNaoComecou || estaEmAndamento;
            
            debugPrint('[DEBUG] Vaga ${c.id} - Hoje ${c.horaInicio.hour}:${c.horaInicio.minute.toString().padLeft(2, '0')}-'
                     '${c.horaFim.hour}:${c.horaFim.minute.toString().padLeft(2, '0')} | '
                     'Agora: ${agora.hour}:${agora.minute.toString().padLeft(2, '0')} | '
                     'Ainda não começou: $aindaNaoComecou | Em andamento: $estaEmAndamento | Incluir: $deveIncluir');
            
            return deveIncluir;
          }
          
          return false;
        }).toList();

        // Caso tudo tenha sido filtrado, retornar ao menos todas para debug visual
        if (candidaturas.isEmpty && todas.isNotEmpty) {
          debugPrint('[WARN] Todas as vagas foram filtradas por data. Retornando todas para debug.');
          candidaturas.addAll(todas);
        }

        // Ordenar por data (mais próximas primeiro)
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
