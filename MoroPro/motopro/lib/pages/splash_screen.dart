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
    print('🔄 [SplashScreen] initState chamado');
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    print('🔍 [SplashScreen] Iniciando verificação de login...');
    
    // Lê token
    final token = await LocalStorage.getAccessToken();
    debugPrint('TOKEN DIRETO 1: $token');
    print('🔑 [SplashScreen] Token encontrado: ${token != null ? "SIM" : "NÃO"}');
    print('🔑 [SplashScreen] Token valor: ${token?.substring(0, 20)}...');

    if (token != null && token.isNotEmpty) {
      print('✅ [SplashScreen] Token válido, carregando dados do usuário...');
      
      // Pega também os dados salvos do motoboy
      final id = await LocalStorage.getMotoboyId();
      final nome = await LocalStorage.getNome();
      final email = await LocalStorage.getEmail();
      
      print('👤 [SplashScreen] Dados carregados - ID: $id, Nome: $nome, Email: $email');

      if (!mounted) {
        print('⚠️ [SplashScreen] Widget não está montado, abortando...');
        return;
      }
      
      // Atualiza o Provider
      print('🔄 [SplashScreen] Atualizando UserProvider...');
      context.read<UserProvider>().setUserData(
            id: id,
            nome: nome,
            email: email,
          );
      print('✅ [SplashScreen] UserProvider atualizado');

      if (!mounted) {
        print('⚠️ [SplashScreen] Widget não está montado após atualizar provider, abortando...');
        return;
      }
      
      // Vai para Home
      print('🏠 [SplashScreen] Navegando para /home');
      Navigator.pushReplacementNamed(context, '/home');
      print('✅ [SplashScreen] Navegação para /home concluída');
    } else {
      print('❌ [SplashScreen] Token não encontrado ou vazio');
      
      if (!mounted) {
        print('⚠️ [SplashScreen] Widget não está montado, abortando...');
        return;
      }
      
      // Vai para Login
      print('🔐 [SplashScreen] Navegando para /login');
      Navigator.pushReplacementNamed(context, '/login');
      print('✅ [SplashScreen] Navegação para /login concluída');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [SplashScreen] Construindo interface...');
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou ícone aqui
              Icon(
                Icons.motorcycle,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'MotoPro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('🗑️ [SplashScreen] dispose chamado');
    super.dispose();
  }
}
