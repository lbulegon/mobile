// lib/services/pre_cadastro_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:motopro/utils/app_config.dart'; // importa o AppConfig

class PreCadastroResponse {
  final bool success;
  final String message;

  PreCadastroResponse({required this.success, required this.message});
}

Future<PreCadastroResponse> preCadastroMotoboy({
  required String nome,
  required String cpf,
  required String email,
  required String telefone,
  required String password,
  required String confirmPassword,
}) async {
  final String url = AppConfig.preCadastro;

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'telefone': telefone,
        'password1': password,
        'password2': confirmPassword,
        'is_motoboy': true,
      }),
    );

    if (response.statusCode == 201) {
      return PreCadastroResponse(
        success: true,
        message: 'Pré-cadastro realizado com sucesso.',
      );
    } else {
      final data = jsonDecode(response.body);
      final errors = data['errors'] ?? 'Erro desconhecido';

      return PreCadastroResponse(
        success: false,
        message: errors.toString(),
      );
    }
  } catch (e) {
    return PreCadastroResponse(
      success: false,
      message: 'Erro na conexão: $e',
    );
  }
}
