import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/task_provider.dart';
import '../../state/task_log_provider.dart';
import '../../data/models/task_log.dart'; // 👈 necesario para TaskLogType

class TaskDetailPage extends ConsumerWidget {
  final String taskId;
  final String intakeId;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    required this.intakeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListByIntakeProvider(intakeId));
    final logsAsync = ref.watch(taskLogListByTaskProvider(taskId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de tarea')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Header de la tarea
          tasksAsync.when(
            data: (list) {
              final t = list.firstWhere((e) => e.id == taskId);
              return Card(
                child: ListTile(
                  title: Text(t.title),
                  subtitle: Text(
                    '${t.type.name.toUpperCase()} • ${t.status.name}',
                  ),
                  trailing: Text(
                    _fmt(t.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error tarea: $e'),
          ),

          const SizedBox(height: 12),
          const Text('Timeline', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          // Timeline de logs
          logsAsync.when(
            data: (items) {
              if (items.isEmpty) return const Text('Sin eventos.');
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final it = items[i];

                  final icon = switch (it.type) {
                    TaskLogType.created => Icons.fiber_new,
                    TaskLogType.statusChanged => Icons.compare_arrows,
                    TaskLogType.note => Icons.note_alt_outlined,
                  };

                  final title = switch (it.type) {
                    TaskLogType.created => 'Creada',
                    TaskLogType.statusChanged => 'Cambio de estado',
                    TaskLogType.note => 'Nota',
                  };

                  return ListTile(
                    leading: Icon(icon),
                    title: Text(title),
                    subtitle: Text(it.message),
                    trailing: Text(
                      _fmt(it.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error timeline: $e'),
          ),
        ],
      ),
    );
  }
}

// Helpers
String _fmt(DateTime dt) =>
    '${_pad2(dt.day)}/${_pad2(dt.month)} ${_pad2(dt.hour)}:${_pad2(dt.minute)}';

String _pad2(int v) => v.toString().padLeft(2, '0');
