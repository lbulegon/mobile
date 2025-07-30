class AppConfig {
  static const String baseUrl = 'https://motopro-development.up.railway.app';
  static const String apiPrefix = '/api/v1';
  static const String apiUrl = '$baseUrl$apiPrefix';

  static const login = '$apiUrl/token/';

  static const String userProfile = '$apiUrl/users/profile/';

  static const String refreshToken = '$apiUrl/token/refresh/';
  static const String tokenVerify = '$apiUrl/token/verify/';

  // Outros endpoints
  static const String preCadastro = '$apiUrl/motoboy/pre-cadastro/';
  static const String vagasDisponiveis = '$apiUrl/vagas/disponiveis/';
  static const String candidatar = '$apiUrl/motoboy-vaga/candidatar/';

  static const String passwordReset = '$apiUrl/password/password-reset/';
  static const String passwordResetConfirm =
      '$apiUrl/password/password-reset/confirm/';
}
