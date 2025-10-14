import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';

final taskRepoProvider = Provider<TaskRepository>(
  (ref) => LocalTaskRepository(),
);

final taskListByIntakeProvider = FutureProvider.family<List<Task>, String>((
  ref,
  intakeId,
) async {
  final repo = ref.watch(taskRepoProvider);
  final all = await repo.loadAll();
  return all.where((t) => t.intakeId == intakeId).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final createTaskProvider = Provider<Future<void> Function(Task)>((ref) {
  return (Task t) async {
    final repo = ref.read(taskRepoProvider);
    await repo.add(t);
    ref.invalidate(taskListByIntakeProvider(t.intakeId));
  };
});

final updateTaskProvider = Provider<Future<void> Function(Task)>((ref) {
  return (Task t) async {
    final repo = ref.read(taskRepoProvider);
    await repo.update(t);
    ref.invalidate(taskListByIntakeProvider(t.intakeId));
  };
});
