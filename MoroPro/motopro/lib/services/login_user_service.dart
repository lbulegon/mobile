// lib/services/login_user_service.dart

// lib/services/login_user_service.dart
import 'package:dio/dio.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/services/session_manager.dart';
import 'package:motopro/services/local_storage.dart';
import '../utils/app_config.dart';

Future<bool> login(String email, String password) async {
  final dio = DioClient.dio;

  try {
    final response = await dio.post(
      AppConfig.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    final access = data['access'];
    final refresh = data['refresh'];

    if (access != null && refresh != null) {
      await SessionManager.saveTokens(access, refresh);

      final perfilResp = await dio.get(AppConfig.userProfile);

      if (perfilResp.statusCode == 200) {
        final perfil = perfilResp.data;
        final motoboyId = perfil['id'];
        print('[DEBUG] Perfil retornado: $perfil');
        if (motoboyId != null) {
          await LocalStorage.salvarMotoboyId(motoboyId);
          final idSalvo = await LocalStorage.getMotoboyId();
          print('[DEBUG] ID salvo e recuperado do SharedPreferences: $idSalvo');
        }
      } else {
        print(
          '⚠️ Erro ao buscar perfil: ${perfilResp.statusCode} - ${perfilResp.data}',
        );
      }

      return true;
    }
  } on DioException catch (e) {
    print("❌ Erro no login: ${e.response?.statusCode} → ${e.response?.data}");
  } catch (e) {
    print('❌ Erro inesperado: $e');
  }

  return false;
}
