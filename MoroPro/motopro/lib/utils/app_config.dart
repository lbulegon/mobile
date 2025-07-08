class AppConfig {
  static const String baseUrl =
      'https://motopro-development.up.railway.app/api/v1';

  static const String apiUrl = baseUrl;

  // Endpoints JWT
  static const String loginUrl = '$baseUrl/token/';
  static const String refreshUrl = '$baseUrl/token/refresh/';

  // Chaves para SharedPreferences
  static const String tokenKey = 'access';
  static const String refreshTokenKey = 'refresh';
}
