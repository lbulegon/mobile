// lib/services/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyMotoboyId = 'motoboy_id';
  static const String _keyNome = 'nome';
  static const String _keyTelefone = 'telefone';
  static const String _keyEmail = 'email';

  // Salvar tokens
  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, access);
    await prefs.setString(_keyRefreshToken, refresh);
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

  // Motoboy ID
  static Future<void> saveMotoboyId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMotoboyId, id);
  }

  static Future<int> getMotoboyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMotoboyId) ?? 0;
  }

  // Nome
  static Future<void> saveNome(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNome, nome);
  }

  static Future<String> getNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNome) ?? '';
  }

  // Telefone
  static Future<void> saveTelefone(String telefone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTelefone, telefone);
  }

  static Future<String> getTelefone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTelefone) ?? '';
  }

  // Email
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
