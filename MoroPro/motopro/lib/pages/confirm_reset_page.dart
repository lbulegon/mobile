import 'package:flutter/material.dart';
import 'package:motopro/services/password_reset_service.dart';

class ConfirmResetPage extends StatefulWidget {
  final String email; // Recebe o e-mail da tela anterior

  const ConfirmResetPage({super.key, required this.email});

  @override
  State<ConfirmResetPage> createState() => _ConfirmResetPageState();
}

class _ConfirmResetPageState extends State<ConfirmResetPage> {
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  /// Função que confirma o reset de senha via OTP
  Future<void> _confirmarReset() async {
    final otp = _otpController.text.trim();
    final novaSenha = _newPasswordController.text.trim();
    final confirmarSenha = _confirmPasswordController.text.trim();

    if (otp.isEmpty || novaSenha.isEmpty || confirmarSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    if (novaSenha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final sucesso = await confirmarNovaSenha(widget.email, otp, novaSenha);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (sucesso) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso!')),
      );

      if (!mounted) return;
      // Redireciona para login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido ou expirado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enviamos um código de 6 dígitos para o e-mail ${widget.email}.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Código OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nova senha",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar nova senha",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmarReset,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Redefinir Senha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
