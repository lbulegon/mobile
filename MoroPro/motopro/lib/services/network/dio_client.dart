// lib/services/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/services/local_storage.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await LocalStorage.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.contains('refresh')) {
          final refreshed = await _refreshToken();

          if (refreshed) {
            final opts = e.requestOptions;
            final newAccess = await LocalStorage.getAccessToken();
            opts.headers['Authorization'] = 'Bearer $newAccess';

            final cloneReq = await dio.fetch(opts);
            return handler.resolve(cloneReq);
          }
        }
        return handler.next(e);
      },
    ));

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await LocalStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await dio.post(
        AppConfig.refreshToken, // ex: "/auth/jwt/refresh/"
        data: {"refresh": refreshToken},
      );

      final newAccess = response.data['access'];
      if (newAccess != null) {
        await LocalStorage.saveTokens(newAccess, refreshToken);
        return true;
      }
      return false;
    } catch (_) {
      await LocalStorage.clearTokens();
      return false;
    }
  }
}
