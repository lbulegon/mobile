//lib/pages/login_page.dart
// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:motopro/services/login_user_service.dart';
import 'package:provider/provider.dart';
import 'package:motopro/providers/user_provider.dart';
import 'package:motopro/services/local_storage.dart';

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

  /// Faz login e salva dados do usuário + tokens
  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    final loginResult = await login(
      _emailController.text.trim(),
      _senhaController.text.trim(),
    );

    setState(() => _carregando = false);

    if (loginResult != null) {
      // Atualiza Provider
      context.read<UserProvider>().setUserData(
            id: loginResult.motoboyId,
            nome: loginResult.nome,
            email: loginResult.email,
          );

      // DEBUG: Verifica se o token foi salvo
      final tokenSalvo = await LocalStorage.getAccessToken();
      print('🔐 Token salvo no login: $tokenSalvo');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _erro = 'E-mail ou senha inválidos');
    }
  }

  void _irParaCadastro() {
    Navigator.pushNamed(context, '/pre-cadastro');
  }

  void _irParaRecuperarSenha() {
    Navigator.pushNamed(context, '/recuperar-senha'); // Tela de OTP
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Permite o ajuste com teclado
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_erro != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _erro!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Digite o e-mail' : null,
                    keyboardType: TextInputType.emailAddress,
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
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _fazerLogin,
                          child: const Text('Entrar'),
                        ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _irParaCadastro,
                    child: const Text('Ainda não tem cadastro? Criar conta'),
                  ),
                  TextButton(
                    onPressed: _irParaRecuperarSenha,
                    child: const Text('Recuperar senha'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
