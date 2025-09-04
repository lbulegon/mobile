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
  final _confirmarSenhaController = TextEditingController();

  bool _codigoEnviado = false;
  bool _carregando = false;
  bool _obscureNovaSenha = true;
  bool _obscureConfirmarSenha = true;
  String? _mensagem;

  /// Envia o OTP para o e-mail informado
  Future<void> _enviarCodigo() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _mensagem = 'Informe um e-mail válido');
      return;
    }

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

  /// Confirma nova senha usando OTP
  Future<void> _resetarSenha() async {
    if (_otpController.text.trim().isEmpty ||
        _novaSenhaController.text.trim().isEmpty ||
        _confirmarSenhaController.text.trim().isEmpty) {
      setState(() => _mensagem = 'Preencha todos os campos');
      return;
    }

    if (_novaSenhaController.text.trim() !=
        _confirmarSenhaController.text.trim()) {
      setState(() => _mensagem = 'As senhas não coincidem');
      return;
    }

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
      _mensagem = sucesso
          ? 'Senha redefinida com sucesso!'
          : 'Erro ao redefinir senha.';
    });

    if (sucesso && mounted) {
      // Retorna para login após 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
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
                        : Colors.red,
                  ),
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
                obscureText: _obscureNovaSenha,
                decoration: InputDecoration(
                  labelText: 'Nova Senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNovaSenha ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNovaSenha = !_obscureNovaSenha;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmarSenhaController,
                obscureText: _obscureConfirmarSenha,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmarSenha ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmarSenha = !_obscureConfirmarSenha;
                      });
                    },
                  ),
                ),
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
