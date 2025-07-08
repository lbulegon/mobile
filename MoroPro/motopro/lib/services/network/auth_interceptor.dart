import 'package:dio/dio.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/services/session_manager.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SessionManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/token/refresh')) {
      final success = await _refreshToken();

      if (success) {
        final newAccess = await SessionManager.getAccessToken();
        final cloned = await _retry(err.requestOptions, newAccess!);
        return handler.resolve(cloned);
      }
    }

    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refresh = await SessionManager.getRefreshToken();
    if (refresh == null) return false;

    try {
      final dio = Dio();
      final response = await dio.post(
        '${AppConfig.apiUrl}/api/v1/token/refresh/',
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
      print('Erro ao renovar token: $e');
    }

    return false;
  }

  Future<Response> _retry(RequestOptions requestOptions, String token) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    final dio = Dio();
    return dio.request(
      '${AppConfig.apiUrl}${requestOptions.path}',
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
