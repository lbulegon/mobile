// lib/services/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/services/local_storage.dart';

class DioClient {
  // Instância única de Dio configurada com baseUrl do app_config
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl, // URL vem do app_config.dart
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
      // Adiciona o token automaticamente em cada requisição
      onRequest: (options, handler) async {
        String? accessToken = await LocalStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },

      // Intercepta erros 401 para tentar refresh automático
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final opts = e.requestOptions;
            return handler.resolve(await dio.fetch(opts));
          }
        }
        return handler.next(e);
      },
    ));

  /// Faz o refresh do token automaticamente
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await LocalStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await dio.post(
        AppConfig.refreshToken,
        data: {"refresh": refreshToken},
      );

      final newAccess = response.data['access'];
      await LocalStorage.saveTokens(newAccess, refreshToken);
      return true;
    } catch (_) {
      await LocalStorage.clearTokens();
      return false;
    }
  }
}
