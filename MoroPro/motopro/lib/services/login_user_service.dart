// lib/services/login_user_service.dart
import 'package:dio/dio.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/services/local_storage.dart';
final Dio dio = Dio(BaseOptions(
  baseUrl: AppConfig.apiUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
));

/// Função de login
Future<bool> login(String email, String senha) async {
  try {
    final response = await dio.post(
      AppConfig.login,
      data: {
        "email": email,
        "password": senha,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Tokens
      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      if (accessToken != null && refreshToken != null) {
        await LocalStorage.saveAccessToken(accessToken);
        await LocalStorage.saveRefreshToken(refreshToken);
      }

      // Salva dados adicionais
      final nome = data['nome'];
      final telefone = data['telefone'];
      final userEmail = data['email'];
      final motoboyId = data['motoboy_id'] ?? data['motoboyId'];

      if (nome != null) await LocalStorage.saveNome(nome);
      if (telefone != null) await LocalStorage.saveTelefone(telefone);
      if (userEmail != null) await LocalStorage.saveEmail(userEmail);

      if (motoboyId != null) {
        await LocalStorage.saveMotoboyId(motoboyId);
      }

      return true;
    }

    return false;
  } catch (e) {
    print("Erro no login: $e");
    return false;
  }
}

/// Função de refresh token
Future<String?> refreshAccessToken() async {
  try {
    final refreshToken = await LocalStorage.getRefreshToken();

    if (refreshToken == null) return null;

    final response = await dio.post(
      AppConfig.refreshToken,
      data: {"refresh": refreshToken},
    );

    if (response.statusCode == 200) {
      final newAccess = response.data['access'];

      if (newAccess != null) {
        await LocalStorage.saveAccessToken(newAccess);
        return newAccess;
      }
    }
    return null;
  } catch (e) {
    print("Erro no refresh token: $e");
    return null;
  }
}

/// Logout
Future<void> logout() async {
   await LocalStorage.clearUserData();
}
