import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/result.dart';
import '../../../core/network/endpoints.dart';
import '../../models/task.dart';
import '../../../state/remote_sync_provider.dart';

class TaskRemoteRepo {
  final Dio _dio;
  TaskRemoteRepo(this._dio);

  Future<NetResult<List<Task>>> fetchByIntake(String intakeId) =>
      mapDio(() async {
        final res = await _dio.get(
          ApiPath.tasks,
          queryParameters: {'intakeId': intakeId},
        );
        final list = (res.data as List).map((j) => Task.fromJson(j)).toList();
        return list;
      });

  Future<NetResult<Task>> create(Task t) => mapDio(() async {
    final res = await _dio.post(ApiPath.tasks, data: t.toJson());
    return Task.fromJson(res.data);
  });
}

final taskRemoteRepoProvider = Provider(
  (ref) => TaskRemoteRepo(ref.read(dioProvider)),
);
