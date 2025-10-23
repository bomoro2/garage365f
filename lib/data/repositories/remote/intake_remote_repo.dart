import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/result.dart';
import '../../../core/network/endpoints.dart';
import '../../models/work_intake.dart';
import '../../../state/remote_sync_provider.dart';

class IntakeRemoteRepo {
  final Dio _dio;
  IntakeRemoteRepo(this._dio);

  Future<NetResult<List<WorkIntake>>> fetchByAsset(String assetId) =>
      mapDio(() async {
        final res = await _dio.get(
          ApiPath.intakes,
          queryParameters: {'assetId': assetId},
        );
        final list = (res.data as List)
            .map((j) => WorkIntake.fromJson(j))
            .toList();
        return list;
      });

  Future<NetResult<WorkIntake>> create(WorkIntake i) => mapDio(() async {
    final res = await _dio.post(ApiPath.intakes, data: i.toJson());
    return WorkIntake.fromJson(res.data);
  });
}

final intakeRemoteRepoProvider = Provider(
  (ref) => IntakeRemoteRepo(ref.read(dioProvider)),
);
