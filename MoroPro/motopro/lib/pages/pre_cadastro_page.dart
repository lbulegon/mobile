// lib/pages/pre_cadastro_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motopro/services/pre_cadastro_service.dart';
import 'package:motopro/utils/app_config.dart';

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

  bool isLoading = false;

  Future<void> _preCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final url = AppConfig.preCadastro;

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome_completo': _nomeController.text,
        'cpf': _cpfController.text,
        'email': _emailController.text,
        'telefone': _telefoneController.text,
        'password': _passwordController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pré-cadastro realizado com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      final resp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${resp['errors'] ?? 'Tente novamente'}')),
      );
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
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6
                    ? 'Senha deve ter no mínimo 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await preCadastroMotoboy(
                            nome: _nomeController.text,
                            cpf: _cpfController.text,
                            email: _emailController.text,
                            telefone: _telefoneController.text,
                            password: _passwordController.text,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response.message)),
                          );

                          if (response.success) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text('Realizar Pré-Cadastro'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
