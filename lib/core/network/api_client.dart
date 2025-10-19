import 'package:dio/dio.dart';
import 'env.dart';
import 'interceptors.dart';

Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.addAll([AuthInterceptor(), LogInterceptorCompact()]);
  return dio;
}
