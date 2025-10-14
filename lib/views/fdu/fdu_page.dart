import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/asset_list_provider.dart';
import '../../state/intake_provider.dart';
import '../../data/models/work_intake.dart';

class FduPage extends ConsumerWidget {
  final String assetId;
  const FduPage({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetAsync = ref.watch(assetListProvider);
    final openAsync = ref.watch(openIntakesByAssetProvider(assetId));
    final historyAsync = ref.watch(intakeHistoryByAssetProvider(assetId));

    return Scaffold(
      appBar: AppBar(title: const Text('FDU · Ingresos')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // --- Asset card ---
          assetAsync.when(
            data: (assets) {
              final a = assets.firstWhere((x) => x.id == assetId);
              return Card(
                child: ListTile(
                  title: Text('${a.code} · ${a.type}'),
                  subtitle: Text('${a.brand} ${a.model} · ${a.hourmeter} h'),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error asset: $e'),
          ),

          const SizedBox(height: 8),
          // Acciones rápidas
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/qr/preview/$assetId'),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Ver QR'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/intake/new/$assetId'),
                  icon: const Icon(Icons.add_task),
                  label: const Text('Nuevo ingreso'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // --- Ingresos abiertos ---
          openAsync.when(
            data: (list) {
              final count = list.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingresos abiertos ($count)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (list.isEmpty) const Text('No hay ingresos abiertos.'),
                  ...list.map(
                    (i) => _OpenIntakeCard(assetId: assetId, intake: i),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error ingresos abiertos: $e'),
          ),

          const SizedBox(height: 16),
          const Text(
            'Historial (cerrados)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // --- Historial (solo cerrados) ---
          historyAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Text('Sin ingresos cerrados aún.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, idx) {
                  final it = items[idx];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.archive_outlined),
                    title: Text('${_stateLabel(it.state)} · ${it.priority}'),
                    subtitle: Text(it.reason),
                    trailing: Text(
                      _fmt(it.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () =>
                        context.push('/intake/detail/${it.id}/$assetId'),
                  );
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error historial: $e'),
          ),

          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Módulos en construcción')),
              );
            },
            icon: const Icon(Icons.playlist_add_check),
            label: const Text('Abrir módulos (Diagnóstico, Tareas, Repuestos)'),
          ),
        ],
      ),
    );
  }
}

/// Card reutilizable para un ingreso abierto (con dropdown de estado + acceso a tareas)
class _OpenIntakeCard extends ConsumerWidget {
  final String assetId;
  final WorkIntake intake;
  const _OpenIntakeCard({required this.assetId, required this.intake});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.assignment_turned_in_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Estado: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          DropdownButton<IntakeState>(
                            value: intake.state,
                            items: IntakeState.values.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(_stateLabel(s)),
                              );
                            }).toList(),
                            onChanged: (newS) async {
                              if (newS == null) return;
                              final update = ref.read(
                                updateIntakeStateProvider,
                              );
                              await update(
                                intakeId: intake.id,
                                assetId: assetId,
                                newState: newS,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Estado actualizado a ${_stateLabel(newS)}',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Motivo: ${intake.reason}\nPrioridad: ${intake.priority}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _fmt(intake.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () =>
                    context.push('/intake/detail/${intake.id}/$assetId'),
                icon: const Icon(Icons.timeline),
                label: const Text('Ver timeline'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/intake/${intake.id}/tasks'),
                icon: const Icon(Icons.list_alt_outlined),
                label: const Text('Ver tareas'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// --- helpers ---
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
