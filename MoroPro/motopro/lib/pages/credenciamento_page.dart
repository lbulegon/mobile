import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CredenciamentoPage extends StatefulWidget {
  const CredenciamentoPage({super.key});

  @override
  State<CredenciamentoPage> createState() => _CredenciamentoPageState();
}

class _CredenciamentoPageState extends State<CredenciamentoPage> {
  final _formKey = GlobalKey<FormState>();

  final _apelido = TextEditingController();
  final _cnh = TextEditingController();
  final _categoria = TextEditingController();
  final _placa = TextEditingController();
  final _modelo = TextEditingController();
  final _ano = TextEditingController();
  final _cep = TextEditingController();
  final _logradouro = TextEditingController();
  final _numero = TextEditingController();
  final _complemento = TextEditingController();

  // Mock IDs (você deve buscar da API de estados, cidades e bairros)
  final int estadoId = 21;
  final int cidadeId = 1;
  final int bairroId = 1;

  bool isLoading = false;

  Future<void> _enviarCredenciamento() async {
    setState(() => isLoading = true);

    const url =
        'https://motopro-development.up.railway.app/api/motoboy/credenciamento/';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer SEU_TOKEN_AQUI'
      },
      body: jsonEncode({
        'apelido': _apelido.text,
        'cnh': _cnh.text,
        'categoria': _categoria.text,
        'placa_moto': _placa.text,
        'modelo_moto': _modelo.text,
        'ano_moto': int.parse(_ano.text),
        'cep': _cep.text,
        'logradouro': _logradouro.text,
        'numero': _numero.text,
        'complemento': _complemento.text,
        'estado': estadoId,
        'cidade': cidadeId,
        'bairro': bairroId,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciamento atualizado!')),
      );
      Navigator.pop(context);
    } else {
      final resp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${resp.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credenciamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _apelido,
                  decoration: const InputDecoration(labelText: 'Apelido')),
              TextFormField(
                  controller: _cnh,
                  decoration: const InputDecoration(labelText: 'CNH')),
              TextFormField(
                  controller: _categoria,
                  decoration:
                      const InputDecoration(labelText: 'Categoria CNH')),
              TextFormField(
                  controller: _placa,
                  decoration:
                      const InputDecoration(labelText: 'Placa da Moto')),
              TextFormField(
                  controller: _modelo,
                  decoration:
                      const InputDecoration(labelText: 'Modelo da Moto')),
              TextFormField(
                  controller: _ano,
                  decoration: const InputDecoration(labelText: 'Ano da Moto')),
              const Divider(),
              TextFormField(
                  controller: _cep,
                  decoration: const InputDecoration(labelText: 'CEP')),
              TextFormField(
                  controller: _logradouro,
                  decoration: const InputDecoration(labelText: 'Logradouro')),
              TextFormField(
                  controller: _numero,
                  decoration: const InputDecoration(labelText: 'Número')),
              TextFormField(
                  controller: _complemento,
                  decoration: const InputDecoration(labelText: 'Complemento')),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _enviarCredenciamento,
                      child: const Text('Enviar Credenciamento'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
