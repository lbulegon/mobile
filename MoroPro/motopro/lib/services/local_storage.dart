// lib/services/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyMotoboyId = 'motoboy_id';
  static const String _keyNome = 'nome';
  static const String _keyTelefone = 'telefone';
  static const String _keyEmail = 'email';

  // TOKENS
  static Future<void> saveTokens(String access, String refresh) async {
    print('💾 [LocalStorage] Salvando tokens...');
    print('🔑 [LocalStorage] Access token: ${access.substring(0, 20)}...');
    print('🔄 [LocalStorage] Refresh token: ${refresh.substring(0, 20)}...');
    
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyAccessToken, access);
    await p.setString(_keyRefreshToken, refresh);
    
    print('✅ [LocalStorage] Tokens salvos com sucesso');
  }

  static Future<void> setAccessToken(String access) async {
    print('💾 [LocalStorage] Salvando access token: ${access.substring(0, 20)}...');
    
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyAccessToken, access);
    
    print('✅ [LocalStorage] Access token salvo');
  }

  static Future<void> setRefreshToken(String refresh) async {
    print('💾 [LocalStorage] Salvando refresh token: ${refresh.substring(0, 20)}...');
    
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyRefreshToken, refresh);
    
    print('✅ [LocalStorage] Refresh token salvo');
  }

  static Future<void> setTokensIfPresent(
      {String? access, String? refresh}) async {
    print('💾 [LocalStorage] Salvando tokens se presentes...');
    
    final p = await SharedPreferences.getInstance();
    if (access != null && access.isNotEmpty) {
      print('🔑 [LocalStorage] Access token presente: ${access.substring(0, 20)}...');
      await p.setString(_keyAccessToken, access);
    } else {
      print('⚠️ [LocalStorage] Access token não presente ou vazio');
    }
    
    if (refresh != null && refresh.isNotEmpty) {
      print('🔄 [LocalStorage] Refresh token presente: ${refresh.substring(0, 20)}...');
      await p.setString(_keyRefreshToken, refresh);
    } else {
      print('⚠️ [LocalStorage] Refresh token não presente ou vazio');
    }
    
    print('✅ [LocalStorage] Tokens processados');
  }

  static Future<String?> getAccessToken() async {
    print('🔍 [LocalStorage] Buscando access token...');
    
    final p = await SharedPreferences.getInstance();
    final token = p.getString(_keyAccessToken);
    
    if (token != null && token.isNotEmpty) {
      print('✅ [LocalStorage] Access token encontrado: ${token.substring(0, 20)}...');
    } else {
      print('❌ [LocalStorage] Access token não encontrado ou vazio');
    }
    
    return token;
  }

  static Future<String?> getRefreshToken() async {
    print('🔍 [LocalStorage] Buscando refresh token...');
    
    final p = await SharedPreferences.getInstance();
    final token = p.getString(_keyRefreshToken);
    
    if (token != null && token.isNotEmpty) {
      print('✅ [LocalStorage] Refresh token encontrado: ${token.substring(0, 20)}...');
    } else {
      print('❌ [LocalStorage] Refresh token não encontrado ou vazio');
    }
    
    return token;
  }

  static Future<void> clearTokens() async {
    print('🗑️ [LocalStorage] Limpando tokens...');
    
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyAccessToken);
    await p.remove(_keyRefreshToken);
    
    print('✅ [LocalStorage] Tokens limpos');
  }

  // DADOS
  static Future<void> saveMotoboyData(
      int id, String nome, String telefone, String email) async {
    print('💾 [LocalStorage] Salvando dados do motoboy...');
    print('🆔 [LocalStorage] ID: $id');
    print('📛 [LocalStorage] Nome: $nome');
    print('📱 [LocalStorage] Telefone: $telefone');
    print('📧 [LocalStorage] Email: $email');
    
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyMotoboyId, id);
    await p.setString(_keyNome, nome);
    await p.setString(_keyTelefone, telefone);
    await p.setString(_keyEmail, email);
    
    print('✅ [LocalStorage] Dados do motoboy salvos');
  }

  static Future<int> getMotoboyId() async {
    print('🔍 [LocalStorage] Buscando ID do motoboy...');
    
    final p = await SharedPreferences.getInstance();
    final id = p.getInt(_keyMotoboyId) ?? 0;
    
    print('🆔 [LocalStorage] ID encontrado: $id');
    return id;
  }

  static Future<String> getNome() async {
    print('🔍 [LocalStorage] Buscando nome do motoboy...');
    
    final p = await SharedPreferences.getInstance();
    final nome = p.getString(_keyNome) ?? '';
    
    print('📛 [LocalStorage] Nome encontrado: $nome');
    return nome;
  }

  static Future<String> getTelefone() async {
    print('🔍 [LocalStorage] Buscando telefone do motoboy...');
    
    final p = await SharedPreferences.getInstance();
    final telefone = p.getString(_keyTelefone) ?? '';
    
    print('📱 [LocalStorage] Telefone encontrado: $telefone');
    return telefone;
  }

  static Future<String> getEmail() async {
    print('🔍 [LocalStorage] Buscando email do motoboy...');
    
    final p = await SharedPreferences.getInstance();
    final email = p.getString(_keyEmail) ?? '';
    
    print('📧 [LocalStorage] Email encontrado: $email');
    return email;
  }

  // LIMPAR
  static Future<void> clearAll() => clear();
  static Future<void> clear() async {
    print('🗑️ [LocalStorage] Limpando todos os dados...');
    
    final p = await SharedPreferences.getInstance();
    await p.clear();
    
    print('✅ [LocalStorage] Todos os dados limpos');
  }
}
