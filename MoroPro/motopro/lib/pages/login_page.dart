//lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:motopro/services/login_user_service.dart';
import 'package:provider/provider.dart';
import 'package:motopro/providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _carregando = false;
  String? _erro;

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    // Chama o serviço de login (agora retorna LoginResult?)
    final loginResult = await login(
      _emailController.text.trim(),
      _senhaController.text.trim(),
    );

    setState(() => _carregando = false);

    if (loginResult != null) {
      // Tokens e dados já salvos no LocalStorage dentro do login()

      // Atualiza Provider com dados do usuário logado
      context.read<UserProvider>().setUserData(
            id: loginResult.motoboyId,
            nome: loginResult.nome,
            email: loginResult.email,
          );

      // Navega para a Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _erro = 'E-mail ou senha inválidos');
    }
  }

  void _irParaCadastro() {
    Navigator.pushNamed(context, '/pre-cadastro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_erro != null)
                Text(_erro!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite o e-mail' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite a senha' : null,
              ),
              const SizedBox(height: 24),
              _carregando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _fazerLogin,
                      child: const Text('Entrar'),
                    ),
              const SizedBox(height: 24),

              // Botão para cadastro
              TextButton(
                onPressed: _irParaCadastro,
                child: const Text('Ainda não tem cadastro? Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
