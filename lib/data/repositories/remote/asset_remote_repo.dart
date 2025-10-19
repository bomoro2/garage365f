import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/result.dart';
import '../../../core/network/endpoints.dart';
import '../../models/asset.dart';
import '../../../state/remote_sync_provider.dart';

class AssetRemoteRepo {
  final Dio _dio;
  AssetRemoteRepo(this._dio);

  Future<NetResult<List<Asset>>> fetchAll() => mapDio(() async {
    final res = await _dio.get(ApiPath.assets);
    final list = (res.data as List).map((j) => Asset.fromJson(j)).toList();
    return list;
  });

  Future<NetResult<Asset>> create(Asset a) => mapDio(() async {
    final res = await _dio.post(ApiPath.assets, data: a.toJson());
    return Asset.fromJson(res.data);
  });

  Future<NetResult<Asset>> getById(String id) => mapDio(() async {
    final res = await _dio.get(ApiPath.assetById(id));
    return Asset.fromJson(res.data);
  });
}

final assetRemoteRepoProvider = Provider<AssetRemoteRepo>((ref) {
  final dio = ref.read(dioProvider);
  return AssetRemoteRepo(dio);
});
