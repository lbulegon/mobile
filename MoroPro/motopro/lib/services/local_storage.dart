import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyMotoboyId = 'motoboy_id';
  static const String _keyNome = 'nome';
  static const String _keyTelefone = 'telefone';
  static const String _keyEmail = 'email';

  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> saveMotoboyId(int motoboyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_motoboyIdKey, motoboyId);
  }

  static Future<int?> getMotoboyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_motoboyIdKey);
  }

  static Future<void> saveNome(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nomeKey, nome);
  }

  static Future<void> saveTelefone(String telefone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_telefoneKey, telefone);
  }

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Limpar dados do usuário
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nomeKey);
    await prefs.remove(_telefoneKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_motoboyIdKey);

    // Adicionado: limpa também os tokens
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
