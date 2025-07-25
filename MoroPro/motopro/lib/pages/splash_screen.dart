// motopro/lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:motopro/services/local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Verifica se o usuário tem sessão salva
  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2)); // animação rápida

    final accessToken = await LocalStorage.getAccessToken();
    final motoboyId = await LocalStorage.getMotoboyId();

    if (accessToken != null && accessToken.isNotEmpty && motoboyId > 0) {
      // Tem sessão: vai para Home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // Não tem sessão: vai para Login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 120),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
