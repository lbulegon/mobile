class AppConfig {
  static const String baseUrl = 'https://motopro-development.up.railway.app';
  static const String apiPrefix = '/api/v1';
  static const String apiUrl = '$baseUrl$apiPrefix';

  // Endpoints de autenticação
  static const login = '$apiUrl/token/';
  static const String userProfile = '$apiUrl/users/profile/';
  static const String refreshToken = '$apiUrl/token/refresh/';
  static const String tokenVerify = '$apiUrl/token/verify/';

  // Endpoints de motoboy
  static const String preCadastro = '$apiUrl/motoboy/pre-cadastro/';
  static const String credenciamento = '$baseUrl/api/motoboy/credenciamento/';
  
  // Endpoints de vagas
  static const String vagasDisponiveis = '$apiUrl/vagas/';
  static const String candidatar = '$apiUrl/motoboy-vaga/candidatar/';
  static const String cancelarCandidatura = '$apiUrl/motoboy-vaga/cancelar/';
  static const String minhasVagas = '$apiUrl/motoboy-vaga/minhas-vagas/';
  
  // Endpoints de operação
  static const String operacaoIniciar = '$apiUrl/operacao/iniciar/';
  static const String operacaoAtiva = '$apiUrl/operacao/ativa/';
  static const String operacaoMinhas = '$apiUrl/operacao/minhas-operacoes/';

  // Endpoints de senha
  static const String passwordReset = '$apiUrl/password/password-reset/';
  static const String passwordResetConfirm =
      '$apiUrl/password/password-reset/confirm/';
      
  // Endpoint para verificação de conectividade
  static const String healthCheck = '$apiUrl/';
}
