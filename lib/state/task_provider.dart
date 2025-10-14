import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import 'task_log_provider.dart';

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

/// Crear tarea + log "creada"
final createTaskProvider = Provider<Future<void> Function(Task)>((ref) {
  return (Task t) async {
    final repo = ref.read(taskRepoProvider);
    await repo.add(t);
    await logTaskCreated(ref, t.id, t.title);
    ref.invalidate(taskListByIntakeProvider(t.intakeId));
  };
});

/// Actualizar tarea (si cambia estado, loguea el cambio)
final updateTaskProvider =
    Provider<Future<void> Function(Task, {Task? before})>((ref) {
      return (Task t, {Task? before}) async {
        final repo = ref.read(taskRepoProvider);

        // Si no me pasaste el "before", lo busco
        before ??= (await repo.loadAll()).firstWhere(
          (e) => e.id == t.id,
          orElse: () => t,
        );

        await repo.update(t);

        if (before.status != t.status) {
          await logTaskStatusChange(
            ref,
            t.id,
            before.status.name,
            t.status.name,
          );
        }

        ref.invalidate(taskListByIntakeProvider(t.intakeId));
      };
    });

/// Helper: cambiar estado por ID, sin armar el Task afuera
final updateTaskStatusByIdProvider =
    Provider<
      Future<void> Function({
        required String taskId,
        required String intakeId,
        required TaskStatus newStatus,
      })
    >((ref) {
      return ({
        required String taskId,
        required String intakeId,
        required TaskStatus newStatus,
      }) async {
        final repo = ref.read(taskRepoProvider);
        final all = await repo.loadAll();
        final current = all.firstWhere((e) => e.id == taskId);
        final updated = current.copyWith(status: newStatus);

        await ref.read(updateTaskProvider)(updated, before: current);
      };
    });
