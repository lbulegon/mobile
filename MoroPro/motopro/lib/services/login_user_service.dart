// lib/services/login_user_service.dart
import 'package:dio/dio.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/services/session_manager.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/providers/user_provider.dart';
import 'package:motopro/utils/navigation_service.dart';
import 'package:motopro/utils/app_config.dart';
import 'package:provider/provider.dart';

Future<bool> login(String email, String password) async {
  final dio = DioClient.dio;

  try {
    final response = await dio.post(
      AppConfig.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    final data = response.data;
    print('[📦 DATA]: $data');
    print('[🧪 ACCESS]: ${data['access']}');
    print('[🧪 REFRESH]: ${data['refresh']}');
    print('[🎯 Enviando login]');
    print('Email digitado: "$email"');
    print('Senha digitada: "$password"');

    final access = data['access'];
    final refresh = data['refresh'];

    if (access != null && refresh != null) {
      // Salvar tokens
      await SessionManager.saveTokens(access, refresh);

      // Salvar dados locais
      final motoboyId = data['motoboy_id'] ?? 0;
      final nome = data['nome'] ?? '';
      final telefone = data['telefone'] ?? '';
      final userEmail = data['email'] ?? '';

      await LocalStorage.saveMotoboyId(motoboyId);
      await LocalStorage.saveNome(nome);
      await LocalStorage.saveTelefone(telefone);
      await LocalStorage.saveEmail(userEmail);

      // Atualizar Provider
      final context = navigatorKey.currentContext!;
      context.read<UserProvider>().setUser(
            nome,
            userEmail,
            telefone,
            motoboyId,
          );

      print(
          '[✅ LOGIN] Motoboy ID: $motoboyId | Nome: $nome | Email: $userEmail');
      return true;
    }
  } on DioException catch (e) {
    if (e.response != null) {
      print('❌ Erro de login: ${e.response?.statusCode}');
      print('❌ Detalhes: ${e.response?.data}');
    } else {
      print('❌ Erro de conexão: $e');
    }
  } catch (e) {
    print('❌ Erro inesperado: $e');
  }

  return false;
}
