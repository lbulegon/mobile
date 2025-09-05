// lib/services/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:motopro/services/network/auth_interceptor_v2.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  DioClient._();
  static final DioClient _i = DioClient._();
  static Dio get dio => _i._build();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));

  Dio _build() {
    _dio.interceptors.clear();
    
    // Adicionar logs (somente em modo debug)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (o) => debugPrint(o.toString()),
      ));
    }
    
    // Adicionar interceptor de autenticação
    _dio.interceptors.add(AuthInterceptorV2());
    
    return _dio;
  }
}
