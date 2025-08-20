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

    if (token != null && token.isNotEmpty) {
      // Pega também os dados salvos do motoboy
      final id = await LocalStorage.getMotoboyId();
      final nome = await LocalStorage.getNome();
      final email = await LocalStorage.getEmail();

      if (!mounted) return;
      
      // Atualiza o Provider
      context.read<UserProvider>().setUserData(
            id: id,
            nome: nome,
            email: email,
          );

      if (!mounted) return;
      // Vai para Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      // Vai para Login
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
