import 'package:flutter/material.dart';

class BoasVindasPage extends StatelessWidget {
  const BoasVindasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica se foi navegado por logout
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (args != null && args['logout'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout realizado com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo ao MotoPro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Seja bem-vindo!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/pre-cadastro');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Quero me cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
