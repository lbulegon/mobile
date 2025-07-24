// motopro/lib/pages/splash_screen.dart
import 'package:motopro/theme/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:motopro/services/session_manager.dart'; // <-- Import correto para tokens

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Espera 2 segundos para mostrar a splash
    await Future.delayed(const Duration(seconds: 2));

    // Pega o access token salvo no SessionManager
    final accessToken = await SessionManager.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      // Token existe -> vai direto para Home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Sem token -> vai para Login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/app_icon.png',
              width: 150,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
