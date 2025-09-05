// lib/services/network/auth_interceptor_v2.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/services/jwt_service.dart';
import 'package:motopro/utils/navigation_service.dart';

class AuthInterceptorV2 extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Pula autenticação para rotas de login e refresh
    if (_shouldSkipAuth(options.path)) {
      return handler.next(options);
    }

    try {
      // Obtém um token válido (faz refresh automático se necessário)
      final token = await JwtService().getValidToken();
      
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Erro silencioso
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Se não é 401, passa o erro adiante
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Se é rota de refresh, não tenta refresh novamente
    if (_shouldSkipAuth(err.requestOptions.path)) {
      return handler.next(err);
    }

    try {
      // Tenta fazer refresh
      final newToken = await JwtService().refreshToken();
      
      if (newToken != null && newToken.isNotEmpty) {
        // Refaz a requisição com o novo token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
        
        final dio = Dio();
        final retryResponse = await dio.fetch(retryOptions);
        
        return handler.resolve(retryResponse);
      } else {
        await _forceLogout();
        return handler.next(err);
      }
    } catch (e) {
      await _forceLogout();
      return handler.next(err);
    }
  }

  /// Verifica se deve pular autenticação para esta rota
  bool _shouldSkipAuth(String path) {
    final skipPaths = [
      '/token/',
      '/token/refresh/',
      '/token/verify/',
      '/password/password-reset/',
      '/motoboy/pre-cadastro/',
      '/motoboy/credenciamento/',
    ];
    
    return skipPaths.any((skipPath) => path.contains(skipPath));
  }

  /// Força logout do usuário
  Future<void> _forceLogout() async {
    try {
      await JwtService().clearTokens();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
      // Erro silencioso
    }
  }
}
