// lib/services/jwt_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/app_config.dart';

class JwtService {
  static final JwtService _instance = JwtService._internal();
  factory JwtService() => _instance;
  JwtService._internal();

  // Dio separado para refresh (sem interceptors)
  final Dio _refreshDio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshQueue = [];
  DateTime? _lastRefreshTime;
  DateTime? _lastRequestTime;
  static const Duration _refreshCooldown = Duration(minutes: 15); // Cooldown de 15 minutos
  static const Duration _adaptiveThreshold = Duration(minutes: 8); // Threshold adaptativo

  /// Verifica se o token está próximo de expirar (threshold adaptativo)
  bool isTokenNearExpiry(String? token) {
    if (token == null || token.isEmpty) return true;
    
    try {
      // Decodifica o JWT (sem verificar assinatura)
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      // Decodifica o payload (parte do meio)
      final payload = parts[1];
      // Adiciona padding se necessário
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);
      
      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;
      
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final timeUntilExpiry = expiryTime.difference(now);
      
      // Usa threshold adaptativo baseado na atividade do usuário
      final threshold = getOptimalRefreshThreshold();
      return timeUntilExpiry < threshold;
    } catch (e) {
      return true; // Em caso de erro, considera expirado
    }
  }

  /// Verifica se o token está realmente expirado (não apenas próximo)
  static bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;
    
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);
      
      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;
      
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      return now.isAfter(expiryTime);
    } catch (e) {
      return true;
    }
  }


  /// Obtém um token válido, fazendo refresh se necessário
  Future<String?> getValidToken() async {
    final currentToken = await LocalStorage.getAccessToken();
    
    // Se não há token, retorna null
    if (currentToken == null || currentToken.isEmpty) {
      return null;
    }
    
    // Atualiza timestamp da última requisição
    _lastRequestTime = DateTime.now();
    
    // Se o token não está próximo de expirar, retorna o atual
    if (!isTokenNearExpiry(currentToken)) {
      return currentToken;
    }
    
    // Verifica se já fez refresh recentemente (cooldown)
    if (_lastRefreshTime != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
      if (timeSinceLastRefresh < _refreshCooldown) {
        // Ainda está no cooldown, retorna o token atual
        return currentToken;
      }
    }
    
    // Se está próximo de expirar e não está no cooldown, faz refresh
    return await refreshToken();
  }

  /// Faz refresh do token
  Future<String?> refreshToken() async {
    // Se já está fazendo refresh, aguarda o resultado
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      return await completer.future;
    }

    _isRefreshing = true;
    
    try {
      final refreshToken = await LocalStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _completeRefreshQueue(null);
        return null;
      }
      
      final response = await _refreshDio.post(
        AppConfig.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        final newRefresh = response.data['refresh'];
        
        if (newAccess != null && newAccess.isNotEmpty) {
          // Salva os novos tokens
          await LocalStorage.setTokensIfPresent(
            access: newAccess,
            refresh: newRefresh,
          );
          
          // Atualiza o timestamp do último refresh
          _lastRefreshTime = DateTime.now();
          
          await _completeRefreshQueue(newAccess);
          return newAccess;
        } else {
          await _completeRefreshQueue(null);
          return null;
        }
      } else {
        await _completeRefreshQueue(null);
        return null;
      }
    } catch (e) {
      await _completeRefreshQueue(null);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Completa todas as requisições aguardando refresh
  Future<void> _completeRefreshQueue(String? newToken) async {
    for (final completer in _refreshQueue) {
      if (!completer.isCompleted) {
        completer.complete(newToken);
      }
    }
    _refreshQueue.clear();
  }

  /// Limpa todos os tokens
  Future<void> clearTokens() async {
    await LocalStorage.clearTokens();
    _isRefreshing = false;
    _refreshQueue.clear();
  }

  /// Verifica se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    final token = await LocalStorage.getAccessToken();
    return token != null && token.isNotEmpty && !isTokenExpired(token);
  }

  /// Verifica se o usuário está ativo (fez requisições recentemente)
  bool isUserActive() {
    if (_lastRequestTime == null) return false;
    final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
    return timeSinceLastRequest < const Duration(minutes: 5);
  }

  /// Obtém o tempo ideal para refresh baseado na atividade do usuário
  Duration getOptimalRefreshThreshold() {
    if (isUserActive()) {
      // Usuário ativo: refresh mais cedo (8 minutos)
      return const Duration(minutes: 8);
    } else {
      // Usuário inativo: refresh mais tarde (5 minutos)
      return const Duration(minutes: 5);
    }
  }
}
