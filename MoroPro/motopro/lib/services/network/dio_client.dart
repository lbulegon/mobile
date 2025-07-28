import 'package:dio/dio.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/app_config.dart';

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
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Busca o token do armazenamento
          final token = await LocalStorage.getAccessToken();
          print('TOKEN DIRETO 5 : $token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Debug
          print('📡 ${options.method}: ${options.uri}');
          print('🔐 Token: ${token ?? "null"}');
          print('📬 Headers: ${options.headers}');

          return handler.next(options);
        },
        onError: (e, handler) {
          // Debug de erros
          print('❌ Erro Dio: ${e.message}');
          if (e.response != null) {
            print('Status Code: ${e.response?.statusCode}');
            print('Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
}
