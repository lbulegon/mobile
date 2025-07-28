// lib/services/login_user_service.dart
import 'package:dio/dio.dart';
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
    final response = await DioClient.dio.post(
      AppConfig.login,
      data: {
        "email": email,
        "password": senha,
      },
    );

    print('🔑 Resposta do login: ${response.data}');

    // Checar se as chaves existem
    if (response.data['access'] == null || response.data['refresh'] == null) {
      print('❌ ERRO: API não retornou tokens.');
      return null;
    }

    // Montar objeto
    final loginResult = LoginResult(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      nome: response.data['nome'] ?? '',
      email: response.data['email'] ?? '',
      telefone: response.data['telefone'] ?? '',
      motoboyId: response.data['motoboy_id'] ?? 0,
    );

    // Salvar tokens
    await LocalStorage.saveTokens(
        loginResult.accessToken, loginResult.refreshToken);
      
    print('DEBUG: Tokens salvos: ${loginResult.accessToken}');
    print('✅ Access salvo: ${loginResult.accessToken.substring(0, 10)}...');
    print('✅ Refresh salvo: ${loginResult.refreshToken.substring(0, 10)}...');

    // Salvar dados do motoboy
    await LocalStorage.saveMotoboyData(
      loginResult.motoboyId,
      loginResult.nome,
      loginResult.telefone,
      loginResult.email,
    );

    return loginResult;
  } on DioException catch (e) {
    print('⚠️ Erro login: ${e.response?.statusCode} - ${e.message}');
    if (e.response?.statusCode == 401) {
      return null;
    }
    rethrow;
  }
}
