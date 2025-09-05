import 'package:flutter_test/flutter_test.dart';
import 'package:motopro/services/network/auth_interceptor_v2.dart';
import 'package:dio/dio.dart';

void main() {
  group('AuthInterceptorV2', () {
    late AuthInterceptorV2 interceptor;

    setUp(() {
      interceptor = AuthInterceptorV2();
    });

    test('deve ser criado corretamente', () {
      expect(interceptor, isA<AuthInterceptorV2>());
    });

    test('deve ser um Interceptor', () {
      expect(interceptor, isA<Interceptor>());
    });
  });
}
