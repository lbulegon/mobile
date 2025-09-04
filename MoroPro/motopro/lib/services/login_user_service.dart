// lib/services/login_user_service.dart
// ✅ ADAPTADO: Suporte para user.full_name conforme plano de migração
// O backend pode retornar nome diretamente ou dentro de user.full_name
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/app_config.dart';

class LoginResult {
  final String accessToken;
  final String refreshToken;
  final String nome;
  final String email;
  final String telefone;
  final int motoboyId;

  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.motoboyId,
  });
}

Future<LoginResult?> login(String email, String senha) async {
  try {
    print('🔑 Tentando login para: $email');
    print('🔑 URL: ${AppConfig.login}');
    
    final response = await DioClient.dio.post(
      AppConfig.login,
      data: {
        "email": email,
        "password": senha,
      },
    );

    print('🔑 Resposta do login: ${response.data}');
    print('🔑 Status code: ${response.statusCode}');

    // Checar se as chaves existem
    if (response.data['access'] == null || response.data['refresh'] == null) {
      print('❌ ERRO: API não retornou tokens.');
      return null;
    }

    // Montar objeto
    final loginResult = LoginResult(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      nome: response.data['nome'] ?? response.data['user']?['full_name'] ?? '',  // ✅ Fallback para user.full_name
      email: response.data['email'] ?? '',
      telefone: response.data['telefone'] ?? '',
      motoboyId: response.data['motoboy_id'] ?? 0,
    );

    // Salvar tokens
    print('🔑 Salvando tokens...');
    await LocalStorage.saveTokens(
        loginResult.accessToken, loginResult.refreshToken);
    
    // Verificar se foram salvos
    final tokenSalvo = await LocalStorage.getAccessToken();
    final refreshSalvo = await LocalStorage.getRefreshToken();
    print('🔑 Token salvo verificado: ${tokenSalvo != null ? "SIM" : "NÃO"}');
    print('🔑 Refresh salvo verificado: ${refreshSalvo != null ? "SIM" : "NÃO"}');
      
    debugPrint('DEBUG: Tokens salvos: ${loginResult.accessToken}');
    debugPrint('✅ Access salvo: ${loginResult.accessToken.substring(0, 10)}...');
    debugPrint('✅ Refresh salvo: ${loginResult.refreshToken.substring(0, 10)}...');

    // Salvar dados do motoboy
    await LocalStorage.saveMotoboyData(
      loginResult.motoboyId,
      loginResult.nome,
      loginResult.telefone,
      loginResult.email,
    );

    return loginResult;
  } on DioException catch (e) {
    debugPrint('⚠️ Erro login: ${e.response?.statusCode} - ${e.message}');
    
    // Tratamento específico por status code
    switch (e.response?.statusCode) {
      case 401:
        print('🔑 Credenciais inválidas');
        return null;
      case 500:
        print('🔴 Erro interno do servidor (500)');
        print('🔴 Detalhes: ${e.response?.data}');
        throw Exception('Erro interno do servidor. Tente novamente mais tarde.');
      case 502:
      case 503:
      case 504:
        print('🔴 Servidor indisponível (${e.response?.statusCode})');
        throw Exception('Servidor temporariamente indisponível. Tente novamente.');
      default:
        print('🔴 Erro desconhecido: ${e.response?.statusCode}');
        rethrow;
    }
  }
}
