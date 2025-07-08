import 'package:flutter/material.dart';
import 'package:motopro/pages/boasvindas_page.dart';
import 'package:motopro/pages/login_page.dart';
import 'package:motopro/pages/home_page.dart'; // você pode criar uma página básica por enquanto
import 'package:intl/date_symbol_data_local.dart'; // ✅ import obrigatório

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
      'pt_BR', null); // ✅ habilita suporte a datas em português

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MotoPro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const BoasVindasPage(),
        '/login': (_) => const LoginPage(),
        '/home': (_) =>
            const HomePage(), // você pode criar uma tela placeholder
      },
    );
  }
}
