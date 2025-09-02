// lib/services/api_vagas.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/utils/app_config.dart';

class ApiVagas {
  static Future<List<Vaga>> getVagasDisponiveis() async {
    try {
      final response = await DioClient.dio.get(AppConfig.vagasDisponiveis);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final vagas = data.map((json) => Vaga.fromJson(json)).toList();
        
        // Debug simples - verificar vagas do dia 30
        print('🔍 DEBUG: ${vagas.length} vagas carregadas');
        for (int i = 0; i < vagas.length; i++) {
          final vaga = vagas[i];
          print('  Vaga $i: ID=${vaga.id}, Empresa="${vaga.empresa}", Dia="${vaga.dia}"');
          if (vaga.dia.contains('30')) {
            print('🎯 VAGA DO DIA 30 ENCONTRADA! ID=${vaga.id}');
          }
        }
        
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
      
      final response = await DioClient.dio.post(
        AppConfig.candidatar,
        data: {
          'motoboy_id': motoboyId,
          'vaga_id': vagaId,
        },
      );

      print('🔍 DEBUG: Resposta candidatura - Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('🔍 DEBUG: Erro ao candidatar: $e');
      print('🔍 DEBUG: Status: ${e.response?.statusCode}');
      print('🔍 DEBUG: Data: ${e.response?.data}');
      
      // Tratamento específico para erro 400
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData.toString().contains('pendente_documentacao')) {
          print('🔍 DEBUG: Motoboy com status pendente_documentacao');
          throw Exception('Você precisa finalizar a documentação para se candidatar a vagas.');
        }
      }
      
      return false;
    } catch (e) {
      print('🔍 DEBUG: Erro geral ao candidatar: $e');
      return false;
    }
  }
}
