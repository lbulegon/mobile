// lib/services/password_reset_service.dart
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/utils/app_config.dart';

/// Envia o código OTP para o email informado
Future<bool> enviarCodigoOTP(String email) async {
  try {
    final response = await DioClient.dio.post(
      AppConfig.passwordReset, // Ex: "/api/v1/password-reset/"
      data: {"email": email},
    );
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

/// Confirma nova senha usando OTP
Future<bool> confirmarNovaSenha(String email, String otp, String novaSenha) async {
  try {
    final response = await DioClient.dio.post(
      AppConfig.passwordResetConfirm, // Ex: "/api/v1/password-reset/confirm/"
      data: {
        "email": email,
        "otp": otp,
        "new_password": novaSenha,
      },
    );
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
