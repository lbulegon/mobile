// lib/services/network/dio_client.dart
import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class DioClient {
  static final Dio _dio = Dio()
    ..interceptors.add(AuthInterceptor())
    ..options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    );

  static Dio get dio => _dio;
}
