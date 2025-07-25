// lib/services/login_user_service.dart

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
      AppConfig.login, // "/api/v1/token/"
      data: {
        "email": email,
        "password": senha,
      },
    );

    print('Resposta do login: ${response.data}'); // DEBUG

    // Monta resultado do login
    final loginResult = LoginResult(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      nome: response.data['nome'],
      email: response.data['email'],
      telefone: response.data['telefone'],
      motoboyId: response.data['motoboy_id'],
    );

    // Salva tokens e dados do motoboy
    await LocalStorage.saveTokens(loginResult.accessToken, loginResult.refreshToken);
    await LocalStorage.saveMotoboyData(
      loginResult.motoboyId,
      loginResult.nome,
      loginResult.telefone,
      loginResult.email,
    );

    return loginResult;
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      return null; // credenciais inválidas
    }
    rethrow; // outro erro (servidor, rede etc.)
  }
}
