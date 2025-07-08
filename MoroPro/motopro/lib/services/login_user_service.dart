import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:motopro/services/session_manager.dart';
import 'package:motopro/services/local_storage.dart';
import '../utils/app_config.dart';

/// 🔐 Login com email e senha usando dj-rest-auth
Future<bool> login(String email, String password) async {
  final url = Uri.parse('${AppConfig.apiUrl}/token/');
  final headers = {'Content-Type': 'application/json'};

  final body = jsonEncode({
    'email': email,
    'password': password,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final access = data['access'];
      final refresh = data['refresh'];

      if (access != null && refresh != null) {
        await SessionManager.saveTokens(access, refresh);

        // Buscar perfil do motoboy

        final perfilUrl = Uri.parse('${AppConfig.apiUrl}/motoboy/me/');
        final perfilResp = await http.get(perfilUrl, headers: {
          'Authorization': 'Bearer $access',
          'Content-Type': 'application/json',
        });

        if (perfilResp.statusCode == 200) {
          final perfil = jsonDecode(perfilResp.body);
          final motoboyId = perfil['id'];
          print('[DEBUG] Perfil retornado: $perfil');
          if (motoboyId != null) {
            await LocalStorage.salvarMotoboyId(motoboyId);
          }
        } else {
          print(
              '⚠️ Erro ao buscar perfil: ${perfilResp.statusCode} - ${perfilResp.body}');
        }

        return true;
      }
    } else {
      print("❌ Erro no login: ${response.statusCode} → ${response.body}");
    }
  } catch (e) {
    print('❌ Exceção no login: $e');
  }

  return false;
}
