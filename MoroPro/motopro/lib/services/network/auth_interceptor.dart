// lib/services/network/auth_interceptor.dart
// lib/services/network/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/services/session_manager.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SessionManager.getAccessToken();
    print("TOKEN DIRETO 4: $token");
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isNotRefresh = !err.requestOptions.path.contains('/token/refresh');

    if (isUnauthorized && isNotRefresh) {
      final success = await _refreshToken();
      if (success) {
        final newToken = await SessionManager.getAccessToken();
        final retryResponse = await _retry(err.requestOptions, newToken!);
        return handler.resolve(retryResponse);
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refresh = await SessionManager.getRefreshToken();
    if (refresh == null) return false;

    try {
      final dio = Dio();
      final response = await dio.post(
        AppConfig.refreshToken,
        data: {'refresh': refresh},
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data['access'] != null) {
        await SessionManager.saveAccessToken(response.data['access']);
        return true;
      }
    } catch (e) {
      print('❌ Erro ao renovar token: $e');
    }

    return false;
  }

  Future<Response<dynamic>> _retry(
      RequestOptions requestOptions, String token) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    final dio = Dio();
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
