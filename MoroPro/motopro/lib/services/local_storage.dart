import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _motoboyIdKey = 'motoboy_id';
  static const _tokenKey = 'auth_token';

  /// Salvar ID do motoboy logado
  static Future<void> salvarMotoboyId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_motoboyIdKey, id);
  }

  /// Obter ID salvo do motoboy
  static Future<int> getMotoboyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_motoboyIdKey) ?? 0;
  }

  /// Apagar ID do motoboy (logout)
  static Future<void> limparMotoboyId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_motoboyIdKey);
  }

  /// Salvar token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Obter token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Apagar token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
