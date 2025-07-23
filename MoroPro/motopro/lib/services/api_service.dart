// motopro/lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'package:motopro/utils/app_config.dart';

class ApiService {
  static Future<Response> getPerfil() async {
    return await DioClient.dio.get('/motoboy/me/');
  }

  static Future<Response> getVagasDisponiveis() async {
    return await DioClient.dio.get(AppConfig.vagasDisponiveis);
  }

  static Future<Response> candidatar(String motoboyId, String vagaId) async {
    return await DioClient.dio.post(
      AppConfig.candidatar,
      data: {'motoboy_id': motoboyId, 'vaga_id': vagaId},
    );
  }

  static Future<Response> login(String email, String password) async {
    return await DioClient.dio.post(
      AppConfig.login,
      data: {'email': email, 'password': password},
    );
  }

  static Future<Response> preCadastro(Map<String, dynamic> dados) async {
    return await DioClient.dio.post(
      AppConfig.preCadastro,
      data: dados,
    );
  }
}
