import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../state/intake_provider.dart';
import '../../state/intake_log_provider.dart';
import '../../data/models/intake_log.dart';
import '../../data/models/work_intake.dart';

class IntakeDetailPage extends ConsumerWidget {
  final String intakeId;
  final String assetId; // para refrescos si hiciera falta
  const IntakeDetailPage({
    super.key,
    required this.intakeId,
    required this.assetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intakesAsync = ref.watch(intakeListProvider);
    final logsAsync = ref.watch(intakeLogListByIntakeProvider(intakeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del ingreso')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Header del ingreso
          intakesAsync.when(
            data: (list) {
              final intake = list.firstWhere((e) => e.id == intakeId);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: Text('Estado: ${_stateLabel(intake.state)}'),
                  subtitle: Text(
                    'Motivo: ${intake.reason}\nPrioridad: ${intake.priority}',
                  ),
                  trailing: Text(
                    _fmt(intake.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error ingreso: $e'),
          ),
          const SizedBox(height: 12),

          const Text('Timeline', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          // Timeline
          logsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Text('Sin eventos registrados.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final it = items[i];
                  final icon = switch (it.type) {
                    IntakeLogType.created => Icons.fiber_new,
                    IntakeLogType.stateChanged => Icons.compare_arrows,
                    IntakeLogType.note => Icons.note_alt_outlined,
                  };
                  final title = switch (it.type) {
                    IntakeLogType.created => 'Creado',
                    IntakeLogType.stateChanged => 'Cambio de estado',
                    IntakeLogType.note => 'Nota',
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

          const SizedBox(height: 12),
          _AddNoteBar(intakeId: intakeId),
        ],
      ),
    );
  }
}

// barra para agregar notas rápidas al log
class _AddNoteBar extends ConsumerStatefulWidget {
  final String intakeId;
  const _AddNoteBar({required this.intakeId});

  @override
  ConsumerState<_AddNoteBar> createState() => _AddNoteBarState();
}

class _AddNoteBarState extends ConsumerState<_AddNoteBar> {
  final _c = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _c.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);
    try {
      final addLog = ref.read(addIntakeLogProvider);
      await addLog(
        IntakeLog(
          id: const Uuid().v4(),
          intakeId: widget.intakeId,
          type: IntakeLogType.note,
          message: text,
          timestamp: DateTime.now(),
        ),
      );
      _c.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nota agregada')));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _c,
            decoration: const InputDecoration(
              hintText: 'Agregar nota al ingreso...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _posting ? null : _add,
          icon: _posting
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: const Text('Agregar'),
        ),
      ],
    );
  }
}

// helpers
String _fmt(DateTime dt) =>
    '${_2(dt.day)}/${_2(dt.month)} ${_2(dt.hour)}:${_2(dt.minute)}';
String _2(int v) => v.toString().padLeft(2, '0');

String _stateLabel(IntakeState s) {
  switch (s) {
    case IntakeState.ingresado:
      return 'INGRESADO';
    case IntakeState.diagnostico:
      return 'DIAGNÓSTICO';
    case IntakeState.aprobacion:
      return 'APROBACIÓN';
    case IntakeState.enProceso:
      return 'EN PROCESO';
    case IntakeState.esperaRepuestos:
      return 'ESPERA REPUESTOS';
    case IntakeState.pruebas:
      return 'PRUEBAS';
    case IntakeState.listo:
      return 'LISTO';
    case IntakeState.entregado:
      return 'ENTREGADO';
    case IntakeState.cerrado:
      return 'CERRADO';
  }
}
