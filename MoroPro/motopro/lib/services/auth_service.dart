// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:motopro/services/jwt_service.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/navigation_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Verifica se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    try {
      return await JwtService().isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  /// Obtém o ID do motoboy autenticado
  Future<int> getCurrentMotoboyId() async {
    try {
      return await LocalStorage.getMotoboyId();
    } catch (e) {
      return 0;
    }
  }

  /// Obtém o nome do motoboy autenticado
  Future<String> getCurrentMotoboyName() async {
    try {
      return await LocalStorage.getNome();
    } catch (e) {
      return '';
    }
  }

  /// Faz logout completo do usuário
  Future<void> logout() async {
    try {
      // Limpa todos os tokens
      await JwtService().clearTokens();
      
      // Limpa todos os dados do usuário
      await LocalStorage.clearAll();
      
      // Navega para a tela de login
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
      // Mesmo com erro, tenta navegar para login
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  /// Força logout (usado quando tokens são inválidos)
  Future<void> forceLogout() async {
    try {
      await logout();
    } catch (e) {
      // Erro silencioso
    }
  }

  /// Verifica se o token precisa de refresh
  Future<bool> needsTokenRefresh() async {
    try {
      final token = await LocalStorage.getAccessToken();
      return JwtService().isTokenNearExpiry(token);
    } catch (e) {
      return true;
    }
  }

  /// Obtém um token válido (faz refresh se necessário)
  Future<String?> getValidToken() async {
    try {
      return await JwtService().getValidToken();
    } catch (e) {
      return null;
    }
  }
}
