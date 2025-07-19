import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:motopro/services/session_manager.dart';
import '../utils/app_config.dart';

class ApiClient {
  static const String _baseUrl = AppConfig.apiUrl;

  static Future<http.Response> get(String endpoint) async {
    final token = await SessionManager.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // ✅ Corrige duplicação de baseUrl
    final Uri url = endpoint.startsWith('http')
        ? Uri.parse(endpoint)
        : Uri.parse('$_baseUrl$endpoint');

    // 🐞 LOG de debug
    print('📡 GET: $url');
    print('🔐 Token: $token');
    print('📬 Headers: $headers');

    return await http.get(url, headers: headers);
  }

  static Future<http.Response> post(String endpoint, dynamic data) async {
    final token = await SessionManager.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = endpoint.startsWith('http')
        ? Uri.parse(endpoint)
        : Uri.parse('$_baseUrl$endpoint');

    final body = jsonEncode(data);

    // 🐞 LOG de debug
    print('📡 POST: $url');
    print('📦 Body: $body');
    print('🔐 Token: $token');
    print('📬 Headers: $headers');

    return await http.post(url, headers: headers, body: body);
  }
}
