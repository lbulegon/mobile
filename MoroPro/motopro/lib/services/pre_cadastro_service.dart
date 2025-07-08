import 'dart:convert';
import 'package:http/http.dart' as http;

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
}) async {
  const String url =
      'https://motopro-development.up.railway.app/api/motoboy/pre-cadastro/';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'telefone': telefone,
        'password': password,
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
