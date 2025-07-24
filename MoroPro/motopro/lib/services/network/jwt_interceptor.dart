import 'package:dio/dio.dart';
import 'package:motopro/services/session_manager.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:motopro/utils/navigation_service.dart';

class JwtInterceptor extends Interceptor {
  final Dio dio;

  JwtInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Adiciona token de acesso em todas as requisições
    final token = await SessionManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Se o erro for 401 e não for a rota de refresh
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != AppConfig.refreshToken) {
      try {
        final refresh = await SessionManager.getRefreshToken();
        if (refresh == null) {
          return _forceLogout(handler, err);
        }

        // Tenta renovar o token
        final refreshResponse = await dio.post(
          AppConfig.refreshToken,
          data: {'refresh': refresh},
        );

        final newAccess = refreshResponse.data['access'];
        final newRefresh = refreshResponse.data['refresh'];

        // Salva novos tokens
        await SessionManager.saveTokens(newAccess, newRefresh);

        // Refaz a requisição original com o novo token
        final retryRequest = err.requestOptions;
        retryRequest.headers['Authorization'] = 'Bearer $newAccess';

        final cloneResponse = await dio.fetch(retryRequest);
        return handler.resolve(cloneResponse);
      } catch (_) {
        return _forceLogout(handler, err);
      }
    }

    return handler.next(err);
  }

  Future<void> _forceLogout(ErrorInterceptorHandler handler, DioException err) async {
    // Limpa tokens e redireciona para login
    await SessionManager.clearTokens();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    return handler.next(err);
  }
}
