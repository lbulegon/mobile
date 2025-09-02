//motopro/lib/main.dart
import 'package:flutter/material.dart';
import 'package:motopro/theme/app_theme.dart';
import 'package:motopro/pages/splash_screen.dart';
import 'package:motopro/pages/login_page.dart';
import 'package:motopro/pages/home_page.dart';
import 'package:motopro/pages/pre_cadastro_page.dart';
import 'package:motopro/utils/navigation_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:motopro/providers/user_provider.dart';
import 'package:motopro/pages/recuperar_senha_page.dart';


void main() async {
  print('🚀 [MAIN] Iniciando aplicativo MotoPro...');
  WidgetsFlutterBinding.ensureInitialized();
  print('🔧 [MAIN] WidgetsFlutterBinding inicializado');
  
  await initializeDateFormatting('pt_BR', null);
  print('🌍 [MAIN] Formatação de data PT-BR inicializada');

  print('🏗️ [MAIN] Configurando providers...');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
  print('✅ [MAIN] App iniciado com sucesso!');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 [MyApp] Construindo MaterialApp...');
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MotoPro',
      theme: AppTheme.darkTheme, // Aqui aplica o tema escuro
      // SplashScreen será a primeira tela
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/pre-cadastro': (context) => const PreCadastroPage(),
        '/recuperar-senha': (context) => const RecuperarSenhaPage(), // NOVA
      },
      onGenerateRoute: (settings) {
        print('🧭 [MyApp] Navegando para: ${settings.name}');
        return null;
      },
    );
  }
}
