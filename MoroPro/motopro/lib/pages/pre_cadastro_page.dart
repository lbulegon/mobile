//motopro/lib/pages/pre_cadastro_page.dart
import 'package:flutter/material.dart';
import 'package:motopro/services/pre_cadastro_service.dart';

class PreCadastroPage extends StatefulWidget {
  const PreCadastroPage({super.key});

  @override
  State<PreCadastroPage> createState() => _PreCadastroPageState();
}

class _PreCadastroPageState extends State<PreCadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response = await preCadastroMotoboy(
      nome: _nomeController.text,
      cpf: _cpfController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmarSenhaController.text,
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );

    if (response.success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pré-Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite seu nome' : null,
              ),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite seu CPF' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Digite seu e-mail' : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Digite seu telefone'
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (value) => value == null || value.length < 6
                    ? 'Senha deve ter no mínimo 6 caracteres'
                    : null,
              ),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                validator: (value) => value != _passwordController.text
                    ? 'As senhas não coincidem'
                    : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Realizar Pré-Cadastro'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
