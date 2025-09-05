import 'package:flutter_test/flutter_test.dart';
import 'package:motopro/services/jwt_service.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('JwtService', () {
    late JwtService jwtService;

    setUp(() {
      jwtService = JwtService();
      SharedPreferences.setMockInitialValues({});
    });

    group('isTokenExpired', () {
      test('deve retornar true para token nulo', () {
        expect(JwtService.isTokenExpired(null), isTrue);
      });

      test('deve retornar true para token vazio', () {
        expect(JwtService.isTokenExpired(''), isTrue);
      });

      test('deve retornar true para token inválido', () {
        expect(JwtService.isTokenExpired('invalid.token'), isTrue);
      });

      test('deve retornar true para token expirado', () {
        // Token JWT expirado (exp: 1000000000 = 2001-09-09)
        final expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjEwMDAwMDAwMDB9.invalid';
        expect(JwtService.isTokenExpired(expiredToken), isTrue);
      });

      test('deve retornar false para token válido futuro', () {
        // Token JWT válido até 2030 (exp: 1893456000)
        final validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE4OTM0NTYwMDB9.invalid';
        expect(JwtService.isTokenExpired(validToken), isFalse);
      });
    });

    group('isTokenNearExpiry', () {
      test('deve retornar true para token nulo', () {
        expect(jwtService.isTokenNearExpiry(null), isTrue);
      });

      test('deve retornar true para token vazio', () {
        expect(jwtService.isTokenNearExpiry(''), isTrue);
      });

      test('deve retornar true para token próximo de expirar', () {
        // Token que expira em 5 minutos
        final nearExpiryToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE3MDAwMDAwMDB9.invalid';
        expect(jwtService.isTokenNearExpiry(nearExpiryToken), isTrue);
      });

      test('deve retornar false para token com tempo suficiente', () {
        // Token que expira em 2 horas
        final validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE4OTM0NTYwMDB9.invalid';
        expect(jwtService.isTokenNearExpiry(validToken), isFalse);
      });
    });

    group('isUserActive', () {
      test('deve retornar false quando não há requisições', () {
        expect(jwtService.isUserActive(), isFalse);
      });

      test('deve retornar true para usuário ativo', () {
        // Simula uma requisição recente
        jwtService.getValidToken();
        expect(jwtService.isUserActive(), isTrue);
      });
    });

    group('getOptimalRefreshThreshold', () {
      test('deve retornar 8 minutos para usuário ativo', () {
        // Simula usuário ativo
        jwtService.getValidToken();
        final threshold = jwtService.getOptimalRefreshThreshold();
        expect(threshold.inMinutes, equals(8));
      });

      test('deve retornar 5 minutos para usuário inativo', () {
        // Usuário inativo (sem requisições)
        final threshold = jwtService.getOptimalRefreshThreshold();
        expect(threshold.inMinutes, equals(5));
      });
    });

    group('isAuthenticated', () {
      test('deve retornar false quando não há token', () async {
        final isAuth = await jwtService.isAuthenticated();
        expect(isAuth, isFalse);
      });

      test('deve retornar true quando há token válido', () async {
        // Simula token válido salvo
        await LocalStorage.setAccessToken('valid.token.here');
        final isAuth = await jwtService.isAuthenticated();
        expect(isAuth, isTrue);
      });
    });

    group('clearTokens', () {
      test('deve limpar todos os tokens', () async {
        // Salva tokens primeiro
        await LocalStorage.saveTokens('access', 'refresh');
        
        // Limpa tokens
        await jwtService.clearTokens();
        
        // Verifica se foram limpos
        final accessToken = await LocalStorage.getAccessToken();
        final refreshToken = await LocalStorage.getRefreshToken();
        
        expect(accessToken, isNull);
        expect(refreshToken, isNull);
      });
    });
  });
}
