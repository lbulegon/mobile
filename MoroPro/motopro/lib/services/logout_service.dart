import 'package:flutter/material.dart';
import 'package:motopro/services/session_manager.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/providers/user_provider.dart';
import 'package:motopro/utils/navigation_service.dart'; // navigatorKey

void logout() async {
  // 1. Limpa tokens
  await SessionManager.clearTokens();

  // 2. Limpa dados salvos localmente
  await LocalStorage.clearAll();

  // 3. Reseta estado do Provider
  final context = navigatorKey.currentContext!;
  context.read<UserProvider>().clearUserData();

  print("✅ Logout completo.");

  // 4. (Opcional) Redireciona para a tela de login
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
}
