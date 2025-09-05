// lib/services/api_vagas.dart
import 'package:dio/dio.dart';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/utils/app_config.dart';

class ApiVagas {
  static Future<List<Vaga>> getVagasDisponiveis() async {
    try {
      final response = await DioClient.dio.get(AppConfig.vagasDisponiveis);

      if (response.statusCode == 200) {
        final dynamic body = response.data;

        List<dynamic> items;
        if (body is List) {
          items = body;
        } else if (body is Map<String, dynamic>) {
          items = (body['vagas'] ??
                  body['results'] ??
                  body['data'] ??
                  body['items'] ??
                  body['alocacoes'] ??
                  []) as List<dynamic>;
        } else {
          items = [];
        }

        final vagas = items
            .where((e) => e is Map<String, dynamic>)
            .map<Vaga>((e) => Vaga.fromJson(e as Map<String, dynamic>))
            .toList();

        return vagas;
      } else {
        throw Exception('Erro ao carregar vagas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar vagas: $e');
    }
  }

  static Future<bool> candidatarVaga(int motoboyId, int vagaId) async {
    try {
      print('🔍 DEBUG: Candidatando vaga - Motoboy: $motoboyId, Vaga: $vagaId');

      // Primeiro, precisamos buscar os detalhes da vaga para ter todos os campos
      print('🔍 DEBUG: Buscando detalhes da vaga $vagaId para candidatura...');
      final vagas = await getVagasDisponiveis();
      final vaga = vagas.firstWhere((v) => v.id == vagaId);

      print(
          '🔍 DEBUG: Vaga encontrada: ${vaga.empresa} - ${vaga.dia} - ${vaga.hora}');
      print(
          '🔍 DEBUG: Data ISO: ${vaga.dataISO}, Hora Início: ${vaga.horaInicio}, Hora Fim: ${vaga.horaFim}');

      final payload = {
        'motoboy': motoboyId,
        'estabelecimento': vaga.estabelecimentoId,
        'data': vaga.dataISO,
        'hora_inicio': '${vaga.horaInicio}:00',
        'hora_fim': '${vaga.horaFim}:00',
      };

      print('🔍 DEBUG: Payload completo: $payload');

      final response = await DioClient.dio.post(
        AppConfig.candidatar,
        data: payload,
      );

      print('🔍 DEBUG: Resposta candidatura - Status: ${response.statusCode}');
      print('🔍 DEBUG: Resposta candidatura - Data: ${response.data}');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('🔍 DEBUG: Erro ao candidatar: $e');
      print('🔍 DEBUG: Status: ${e.response?.statusCode}');
      print('🔍 DEBUG: Data: ${e.response?.data}');

      // Tratamento específico para erro 400
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null &&
            errorData.toString().contains('pendente_documentacao')) {
          print('🔍 DEBUG: Motoboy com status pendente_documentacao');
          throw Exception(
              'Você precisa finalizar a documentação para se candidatar a vagas.');
        }
      }

      return false;
    } catch (e) {
      print('🔍 DEBUG: Erro geral ao candidatar: $e');
      return false;
    }
  }
}
