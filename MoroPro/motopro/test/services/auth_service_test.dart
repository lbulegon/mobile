import 'package:flutter_test/flutter_test.dart';
import 'package:motopro/services/auth_service.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      SharedPreferences.setMockInitialValues({});
    });

    group('isAuthenticated', () {
      test('deve retornar false quando não há token', () async {
        final isAuth = await authService.isAuthenticated();
        expect(isAuth, isFalse);
      });

      test('deve retornar true quando há token válido', () async {
        // Simula token válido salvo
        await LocalStorage.setAccessToken('valid.token.here');
        final isAuth = await authService.isAuthenticated();
        expect(isAuth, isTrue);
      });
    });

    group('getCurrentMotoboyId', () {
      test('deve retornar 0 quando não há ID salvo', () async {
        final id = await authService.getCurrentMotoboyId();
        expect(id, equals(0));
      });

      test('deve retornar ID correto quando salvo', () async {
        await LocalStorage.saveMotoboyData(123, 'João', '11999999999', 'joao@test.com');
        final id = await authService.getCurrentMotoboyId();
        expect(id, equals(123));
      });
    });

    group('getCurrentMotoboyName', () {
      test('deve retornar string vazia quando não há nome salvo', () async {
        final nome = await authService.getCurrentMotoboyName();
        expect(nome, equals(''));
      });

      test('deve retornar nome correto quando salvo', () async {
        await LocalStorage.saveMotoboyData(123, 'João Silva', '11999999999', 'joao@test.com');
        final nome = await authService.getCurrentMotoboyName();
        expect(nome, equals('João Silva'));
      });
    });

    group('needsTokenRefresh', () {
      test('deve retornar true quando não há token', () async {
        final needsRefresh = await authService.needsTokenRefresh();
        expect(needsRefresh, isTrue);
      });

      test('deve retornar false quando há token válido', () async {
        // Token que expira em 2 horas (válido)
        final validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE4OTM0NTYwMDB9.invalid';
        await LocalStorage.setAccessToken(validToken);
        
        final needsRefresh = await authService.needsTokenRefresh();
        expect(needsRefresh, isFalse);
      });
    });

    group('getValidToken', () {
      test('deve retornar null quando não há token', () async {
        final token = await authService.getValidToken();
        expect(token, isNull);
      });

      test('deve retornar token quando válido', () async {
        final validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE4OTM0NTYwMDB9.invalid';
        await LocalStorage.setAccessToken(validToken);
        
        final token = await authService.getValidToken();
        expect(token, equals(validToken));
      });
    });

    group('logout', () {
      test('deve limpar todos os dados', () async {
        // Salva dados primeiro
        await LocalStorage.saveTokens('access', 'refresh');
        await LocalStorage.saveMotoboyData(123, 'João', '11999999999', 'joao@test.com');
        
        // Faz logout
        await authService.logout();
        
        // Verifica se foram limpos
        final accessToken = await LocalStorage.getAccessToken();
        final refreshToken = await LocalStorage.getRefreshToken();
        final id = await LocalStorage.getMotoboyId();
        final nome = await LocalStorage.getNome();
        
        expect(accessToken, isNull);
        expect(refreshToken, isNull);
        expect(id, equals(0));
        expect(nome, equals(''));
      });
    });

    group('forceLogout', () {
      test('deve executar logout sem erros', () async {
        // Salva dados primeiro
        await LocalStorage.saveTokens('access', 'refresh');
        
        // Força logout
        await authService.forceLogout();
        
        // Verifica se foram limpos
        final accessToken = await LocalStorage.getAccessToken();
        expect(accessToken, isNull);
      });
    });
  });
}
