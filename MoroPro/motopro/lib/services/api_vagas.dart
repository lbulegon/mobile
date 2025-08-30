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
      final response = await DioClient.dio.post(
        AppConfig.candidatar,
        data: {
          'motoboy_id': motoboyId,
          'vaga_id': vagaId,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
