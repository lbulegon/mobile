import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto de perfil
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'assets/user_placeholder.png'), // Substitua com o caminho correto
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  onPressed: () {
                    // Lógica para alterar a foto de perfil
                  },
                  icon: const Icon(Icons.camera_alt),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nome do usuário
            Text(
              'Nome do Usuário',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // E-mail
            Text(
              'usuario@email.com',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Botões para ações do perfil
            ElevatedButton(
              onPressed: () {
                // Lógica para editar perfil
              },
              child: const Text('Editar Perfil'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Lógica para alterar senha
              },
              child: const Text('Alterar Senha'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Lógica para sair da conta
                _confirmarLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fechar o diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Fechar o diálogo
                Navigator.pop(context);

                // Navegar para a tela de login (como em HomePage)
                Navigator.pop(
                    context); // Substitua pela rota correta para a tela de login
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
