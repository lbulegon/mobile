import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Serviço para cache offline de dados
class OfflineCacheService {
  static const String _keyMinhasVagas = 'cache_minhas_vagas';
  static const String _keyCacheTimestamp = 'cache_timestamp';
  static const Duration _cacheValidity = Duration(hours: 1); // Cache válido por 1 hora

  /// Salva dados das vagas no cache local
  static Future<void> saveMinhasVagas(List<Map<String, dynamic>> vagas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vagasJson = jsonEncode(vagas);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setString(_keyMinhasVagas, vagasJson);
      await prefs.setInt(_keyCacheTimestamp, timestamp);
      
      debugPrint('[OfflineCache] Vagas salvas no cache: ${vagas.length} itens');
    } catch (e) {
      debugPrint('[OfflineCache] Erro ao salvar cache: $e');
    }
  }

  /// Recupera dados das vagas do cache local
  static Future<List<Map<String, dynamic>>?> getMinhasVagas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vagasJson = prefs.getString(_keyMinhasVagas);
      final timestamp = prefs.getInt(_keyCacheTimestamp);
      
      if (vagasJson == null || timestamp == null) {
        debugPrint('[OfflineCache] Nenhum cache encontrado');
        return null;
      }
      
      // Verificar se o cache ainda é válido
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheValidity) {
        debugPrint('[OfflineCache] Cache expirado');
        return null;
      }
      
      final vagas = List<Map<String, dynamic>>.from(jsonDecode(vagasJson));
      debugPrint('[OfflineCache] Cache recuperado: ${vagas.length} itens');
      return vagas;
    } catch (e) {
      debugPrint('[OfflineCache] Erro ao recuperar cache: $e');
      return null;
    }
  }

  /// Verifica se há cache válido disponível
  static Future<bool> hasValidCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_keyCacheTimestamp);
      
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) <= _cacheValidity;
    } catch (e) {
      debugPrint('[OfflineCache] Erro ao verificar cache: $e');
      return false;
    }
  }

  /// Limpa todo o cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyMinhasVagas);
      await prefs.remove(_keyCacheTimestamp);
      debugPrint('[OfflineCache] Cache limpo');
    } catch (e) {
      debugPrint('[OfflineCache] Erro ao limpar cache: $e');
    }
  }

  /// Obtém informações sobre o cache
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_keyCacheTimestamp);
      final vagasJson = prefs.getString(_keyMinhasVagas);
      
      if (timestamp == null || vagasJson == null) {
        return {
          'hasCache': false,
          'itemCount': 0,
          'age': null,
          'isValid': false,
        };
      }
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final age = now.difference(cacheTime);
      final vagas = jsonDecode(vagasJson) as List;
      
      return {
        'hasCache': true,
        'itemCount': vagas.length,
        'age': age,
        'isValid': age <= _cacheValidity,
        'cacheTime': cacheTime,
      };
    } catch (e) {
      debugPrint('[OfflineCache] Erro ao obter info do cache: $e');
      return {
        'hasCache': false,
        'itemCount': 0,
        'age': null,
        'isValid': false,
      };
    }
  }
}
