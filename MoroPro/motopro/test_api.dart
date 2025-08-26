import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  
  try {
    print('🔍 Testando API de login...');
    
    final response = await dio.post(
      'https://motopro-development.up.railway.app/api/v1/token/',
      data: {
        'email': 'teste@teste.com',
        'password': 'teste123',
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => true, // Aceita qualquer status
      ),
    );
    
    print('📊 Status Code: ${response.statusCode}');
    print('📄 Response Data: ${response.data}');
    print('📋 Response Headers: ${response.headers}');
    
  } catch (e) {
    print('❌ Erro ao testar API: $e');
  }
}

