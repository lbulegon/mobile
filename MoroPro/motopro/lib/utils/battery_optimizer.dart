import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Utilitário para otimização de bateria
class BatteryOptimizer {
  static final BatteryOptimizer _instance = BatteryOptimizer._internal();
  factory BatteryOptimizer() => _instance;
  BatteryOptimizer._internal();

  // Cache de requisições para evitar chamadas desnecessárias
  final Map<String, _CacheEntry> _cache = {};
  final Duration _cacheTimeout = const Duration(minutes: 5);
  
  // Debounce para evitar múltiplas chamadas rápidas
  final Map<String, Timer> _debounceTimers = {};
  final Duration _debounceDelay = const Duration(milliseconds: 500);
  
  // Controle de conectividade
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true;
  
  /// Inicializa o otimizador de bateria
  void initialize() {
    _startConnectivityMonitoring();
    _startCacheCleanup();
  }
  
  /// Verifica se há conectividade
  bool get isConnected => _isConnected;
  
  /// Monitora conectividade para evitar requisições desnecessárias
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _isConnected = results.any((result) => result != ConnectivityResult.none);
        debugPrint('[BatteryOptimizer] Conectividade: ${_isConnected ? "CONECTADO" : "DESCONECTADO"}');
      },
    );
  }
  
  /// Limpa cache expirado periodicamente
  void _startCacheCleanup() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _cleanExpiredCache();
    });
  }
  
  /// Verifica se uma requisição pode ser feita (cache ou conectividade)
  bool canMakeRequest(String key) {
    if (!_isConnected) {
      debugPrint('[BatteryOptimizer] Bloqueando requisição - sem conectividade: $key');
      return false;
    }
    
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      debugPrint('[BatteryOptimizer] Usando cache para: $key');
      return false; // Não fazer requisição, usar cache
    }
    
    return true;
  }
  
  /// Armazena resultado no cache
  void cacheResult(String key, dynamic data) {
    _cache[key] = _CacheEntry(data, DateTime.now());
    debugPrint('[BatteryOptimizer] Cache armazenado: $key');
  }
  
  /// Recupera dados do cache
  dynamic getCachedResult(String key) {
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }
    return null;
  }
  
  /// Aplica debounce para evitar múltiplas chamadas
  void debounce(String key, VoidCallback callback) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(_debounceDelay, callback);
  }
  
  /// Limpa cache expirado
  void _cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => entry.isExpired);
    debugPrint('[BatteryOptimizer] Cache limpo. Itens restantes: ${_cache.length}');
  }
  
  /// Limpa todo o cache
  void clearCache() {
    _cache.clear();
    debugPrint('[BatteryOptimizer] Cache completamente limpo');
  }
  
  /// Cancela todos os timers de debounce
  void cancelDebounce() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }
  
  /// Libera recursos
  void dispose() {
    _connectivitySubscription?.cancel();
    cancelDebounce();
    clearCache();
  }
}

/// Entrada do cache com timestamp
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  
  _CacheEntry(this.data, this.timestamp);
  
  bool get isExpired {
    return DateTime.now().difference(timestamp) > 
           BatteryOptimizer()._cacheTimeout;
  }
}
