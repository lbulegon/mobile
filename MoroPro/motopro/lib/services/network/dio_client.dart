// lib/services/network/dio_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static late Dio _dio;

  static Dio get dio {
    if (_dio == null) {
      print('🔧 [DioClient] Inicializando cliente Dio...');
      _initializeDio();
    }
    return _dio;
  }

  static void _initializeDio() {
    print('⚙️ [DioClient] Configurando cliente Dio...');
    
    _dio = Dio(BaseOptions(
      baseUrl: 'https://motopro-development.up.railway.app',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Adicionar interceptor para token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('📤 [DioClient] Requisição para ${options.uri}');
          print('🔑 [DioClient] Token adicionado ao header');
          
          final token = await LocalStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('✅ [DioClient] Token Bearer adicionado: ${token.substring(0, 20)}...');
          } else {
            print('⚠️ [DioClient] Token não encontrado, requisição sem autenticação');
          }
          
          print('📋 [DioClient] Headers: ${options.headers}');
          if (options.data != null) {
            print('📄 [DioClient] Body: ${options.data}');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 [DioClient] Resposta ${response.requestOptions.method} ${response.requestOptions.uri} -> ${response.statusCode}');
          print('📊 [DioClient] Tamanho da resposta: ${response.data?.toString().length ?? 0} caracteres');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ [DioClient] Erro na requisição ${error.requestOptions.method} ${error.requestOptions.uri}');
          print('📊 [DioClient] Status: ${error.response?.statusCode}');
          print('📄 [DioClient] Dados do erro: ${error.response?.data}');
          print('💬 [DioClient] Mensagem: ${error.message}');
          handler.next(error);
        },
      ),
    );

    // Adicionar LogInterceptor em modo debug
    if (kDebugMode) {
      print('🐛 [DioClient] Modo debug ativo, adicionando LogInterceptor');
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          print('📡 [DioClient] $obj');
        },
      ));
    }

    print('✅ [DioClient] Cliente Dio configurado com sucesso');
  }
}
