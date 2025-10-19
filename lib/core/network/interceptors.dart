import 'package:dio/dio.dart';
import 'env.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AppEnv.bearerToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class LogInterceptorCompact extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log corto
    // ignore: avoid_print
    print(
      '[API][ERROR] ${err.requestOptions.method} ${err.requestOptions.uri} → ${err.message}',
    );
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print(
      '[API] ${response.requestOptions.method} ${response.requestOptions.uri} → ${response.statusCode}',
    );
    handler.next(response);
  }
}
