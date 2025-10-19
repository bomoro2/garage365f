import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/result.dart';
import '../../../core/network/endpoints.dart';
import '../../../state/remote_sync_provider.dart';

class PingRepo {
  final Dio _dio;
  PingRepo(this._dio);

  Future<NetResult<String>> ping() => mapDio(() async {
    final res = await _dio.get(ApiPath.ping);
    return (res.data is String) ? (res.data as String) : 'ok';
  });
}

final pingRepoProvider = Provider<PingRepo>((ref) {
  final dio = ref.read(dioProvider);
  return PingRepo(dio);
});
