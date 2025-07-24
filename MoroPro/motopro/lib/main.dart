//motopro/lib/main.dart
import 'package:flutter/material.dart';
import 'package:motopro/pages/splash_screen.dart';
import 'package:motopro/pages/login_page.dart';
import 'package:motopro/pages/home_page.dart';
import 'package:motopro/pages/pre_cadastro_page.dart';
import 'package:motopro/utils/navigation_service.dart'; // navigatorKey está aqui
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:motopro/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MotoPro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(), // 🔄 trocado aqui
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/pre-cadastro': (_) => const PreCadastroPage(),
      },
    );
  }
}
