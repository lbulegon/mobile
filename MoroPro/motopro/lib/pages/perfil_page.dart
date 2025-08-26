import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:motopro/providers/user_provider.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar com ação de câmera
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/user_placeholder.png'),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      // 📸 Trocar foto
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // Nome e e-mail
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    Text(
                      userProvider.nome ?? 'Nome do Usuário',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userProvider.email ?? 'usuario@email.com',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Card com opções
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Perfil'),
                    onTap: () {
                      // ✏️ Editar perfil
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Alterar Senha'),
                    onTap: () {
                      // 🔐 Alterar senha
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Enviar Documentos'),
                    onTap: () {
                      // 📎 Upload de documentos
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
