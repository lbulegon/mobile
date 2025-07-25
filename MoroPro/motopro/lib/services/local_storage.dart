// lib/services/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Chaves para SharedPreferences
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyMotoboyId = 'motoboy_id';
  static const String _keyNome = 'nome';
  static const String _keyTelefone = 'telefone';
  static const String _keyEmail = 'email';

  // -----------------------------------------------------
  // TOKENS
  // -----------------------------------------------------
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // -----------------------------------------------------
  // DADOS DO MOTOBOY
  // -----------------------------------------------------
  static Future<void> saveMotoboyData(
    int id,
    String nome,
    String telefone,
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMotoboyId, id);
    await prefs.setString(_keyNome, nome);
    await prefs.setString(_keyTelefone, telefone);
    await prefs.setString(_keyEmail, email);
  }

  static Future<int> getMotoboyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMotoboyId) ?? 0;
  }

  static Future<String> getNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNome) ?? '';
  }

  static Future<String> getTelefone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTelefone) ?? '';
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  static Future<void> clearMotoboyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMotoboyId);
    await prefs.remove(_keyNome);
    await prefs.remove(_keyTelefone);
    await prefs.remove(_keyEmail);
  }

  // -----------------------------------------------------
  // LIMPAR TUDO (tokens + dados motoboy)
  // -----------------------------------------------------
  static Future<void> clearAll() async {
    await clearTokens();
    await clearMotoboyData();
  }
}
