import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';
import 'local_storage.dart';

class ApiClient {
  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await LocalStorage.getToken(); // opcional

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    _handleErrors(response);
    return response;
  }

  static Future<http.Response> get(String endpoint) async {
    final token = await LocalStorage.getToken(); // opcional

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    _handleErrors(response);
    return response;
  }

  static void _handleErrors(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('Erro na API: ${response.statusCode} - ${response.body}');
    }
  }
}
