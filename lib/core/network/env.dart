class AppEnv {
  AppEnv._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5027', // fallback local
  );

  static String? get bearerToken => null; // si después metés auth
}
