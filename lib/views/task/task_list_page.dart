import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../state/task_provider.dart';
import '../../data/models/task.dart';

class TaskListPage extends ConsumerWidget {
  final String intakeId;
  const TaskListPage({super.key, required this.intakeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListByIntakeProvider(intakeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tareas del ingreso')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('Sin tareas aún.'));
          }
          return ListView.separated(
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final t = tasks[i];
              return ListTile(
                title: Text(t.title),
                subtitle: Text(
                  '${t.type.name.toUpperCase()} • ${t.status.name}',
                ),
                trailing: PopupMenuButton<TaskStatus>(
                  onSelected: (s) async {
                    final updated = t.copyWith(status: s);
                    await ref.read(updateTaskProvider)(updated);
                  },
                  itemBuilder: (_) => TaskStatus.values
                      .map((s) => PopupMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final titleC = TextEditingController();
    TaskType selectedType = TaskType.diagnostico;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 8),
            DropdownButton<TaskType>(
              value: selectedType,
              onChanged: (v) {
                if (v != null) selectedType = v;
              },
              items: TaskType.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final text = titleC.text.trim();
              if (text.isEmpty) return;
              final newTask = Task(
                id: const Uuid().v4(),
                intakeId: intakeId,
                type: selectedType,
                title: text,
                status: TaskStatus.todo,
                createdAt: DateTime.now(),
              );
              await ref.read(createTaskProvider)(newTask);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
