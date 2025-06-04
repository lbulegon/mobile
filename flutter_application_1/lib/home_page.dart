import 'package:flutter/material.dart';
import 'package:flutter_application_1/boasvindas_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [ // Aqui vai uma lista de widgets
          const Text(
            'Home Page',
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () async {
              bool saiu = await sair();
              if (saiu) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BoasVindasPage(),
                  ),
                );
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }


  Future<bool> sair() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    return true;
  }
}
