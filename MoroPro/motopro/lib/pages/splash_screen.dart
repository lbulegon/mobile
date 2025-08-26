// motopro/lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:provider/provider.dart';
import 'package:motopro/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Lê token
    final token = await LocalStorage.getAccessToken();
    debugPrint('TOKEN DIRETO 1: $token');
    print('🔑 Splash: Token encontrado: ${token != null ? "SIM" : "NÃO"}');

    if (token != null && token.isNotEmpty) {
      print('🔑 Splash: Token válido, carregando dados do usuário...');
      // Pega também os dados salvos do motoboy
      final id = await LocalStorage.getMotoboyId();
      final nome = await LocalStorage.getNome();
      final email = await LocalStorage.getEmail();
      
      print('🔑 Splash: Dados carregados - ID: $id, Nome: $nome, Email: $email');

      if (!mounted) return;
      
      // Atualiza o Provider
      context.read<UserProvider>().setUserData(
            id: id,
            nome: nome,
            email: email,
          );

      if (!mounted) return;
      // Vai para Home
      print('🔑 Splash: Navegando para /home');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      // Vai para Login
      print('🔑 Splash: Navegando para /login');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
