import 'package:dio/dio.dart';

sealed class NetResult<T> {
  const NetResult();
}

class NetOk<T> extends NetResult<T> {
  final T data;
  const NetOk(this.data);
}

class NetErr<T> extends NetResult<T> {
  final String message;
  final int? status;
  const NetErr(this.message, {this.status});
}

Future<NetResult<R>> mapDio<R>(Future<R> Function() call) async {
  try {
    final data = await call();
    return NetOk<R>(data);
  } on DioException catch (e) {
    final status = e.response?.statusCode;
    final msg = e.response?.data is Map && (e.response!.data['error'] != null)
        ? e.response!.data['error'].toString()
        : (e.message ?? 'Network error');
    return NetErr<R>(msg, status: status);
  } catch (e) {
    return NetErr<R>(e.toString());
  }
}
