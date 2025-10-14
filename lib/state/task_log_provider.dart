import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/task_log.dart';
import '../data/repositories/task_log_repository.dart';

final taskLogRepoProvider = Provider<TaskLogRepository>(
  (ref) => LocalTaskLogRepository(),
);

final taskLogListByTaskProvider = FutureProvider.family<List<TaskLog>, String>((
  ref,
  taskId,
) async {
  final repo = ref.watch(taskLogRepoProvider);
  return repo.listByTask(taskId);
});

final addTaskLogProvider = Provider<Future<void> Function(TaskLog)>((ref) {
  return (TaskLog log) async {
    final repo = ref.read(taskLogRepoProvider);
    await repo.add(log);
    ref.invalidate(taskLogListByTaskProvider(log.taskId));
  };
});

/// Helpers (ahora aceptan `Ref`, no `WidgetRef`)
Future<void> logTaskCreated(Ref ref, String taskId, String title) async {
  await ref.read(addTaskLogProvider)(
    TaskLog(
      id: const Uuid().v4(),
      taskId: taskId,
      type: TaskLogType.created,
      message: 'Tarea creada: $title',
      timestamp: DateTime.now(),
    ),
  );
}

Future<void> logTaskStatusChange(
  Ref ref,
  String taskId,
  String from,
  String to,
) async {
  await ref.read(addTaskLogProvider)(
    TaskLog(
      id: const Uuid().v4(),
      taskId: taskId,
      type: TaskLogType.statusChanged,
      message: 'Estado: $from → $to',
      timestamp: DateTime.now(),
      fromStatus: from,
      toStatus: to,
    ),
  );
}
