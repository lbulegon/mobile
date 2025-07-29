// lib/pages/recuperar_senha_page.dart
import 'package:flutter/material.dart';
import 'package:motopro/services/password_reset_service.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _novaSenhaController = TextEditingController();

  bool _codigoEnviado = false;
  bool _carregando = false;
  String? _mensagem;

  Future<void> _enviarCodigo() async {
    setState(() {
      _carregando = true;
      _mensagem = null;
    });

    final sucesso = await enviarCodigoOTP(_emailController.text.trim());

    setState(() {
      _carregando = false;
      _mensagem = sucesso
          ? 'Código enviado para o seu e-mail'
          : 'Erro ao enviar código. Verifique o e-mail.';
      _codigoEnviado = sucesso;
    });
  }

  Future<void> _resetarSenha() async {
    setState(() {
      _carregando = true;
      _mensagem = null;
    });

    final sucesso = await confirmarNovaSenha(
      _emailController.text.trim(),
      _otpController.text.trim(),
      _novaSenhaController.text.trim(),
    );

    setState(() {
      _carregando = false;
      _mensagem =
          sucesso ? 'Senha redefinida com sucesso!' : 'Erro ao redefinir senha.';
    });

    if (sucesso && mounted) {
      // Retorna para login
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_mensagem != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _mensagem!,
                  style: TextStyle(
                      color: _mensagem!.contains('sucesso')
                          ? Colors.green
                          : Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            if (_codigoEnviado) ...[
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Código OTP'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _novaSenhaController,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _resetarSenha,
                      child: const Text('Redefinir Senha'),
                    ),
            ] else ...[
              _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _enviarCodigo,
                      child: const Text('Enviar Código'),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
