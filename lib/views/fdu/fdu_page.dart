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
    final activeAsync = ref.watch(activeIntakeByAssetProvider(assetId));
    final historyAsync = ref.watch(
      intakeHistoryByAssetProvider(assetId),
    ); // <- HISTORIAL

    return Scaffold(
      appBar: AppBar(title: const Text('FDU · Ingreso')),
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
          const Text(
            'Ingreso activo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // --- Ingreso activo ---
          activeAsync.when(
            data: (i) {
              if (i == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sin ingreso activo.'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/intake/new/$assetId'),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear ingreso ahora'),
                    ),
                  ],
                );
              }
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment_turned_in_outlined),
                  title: Text('Estado: ${i.state.name.toUpperCase()}'),
                  subtitle: Text(
                    'Motivo: ${i.reason}\nPrioridad: ${i.priority}',
                  ),
                  trailing: Text(
                    _fmt(i.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error intake: $e'),
          ),

          const SizedBox(height: 16),
          const Text(
            'Historial de ingresos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // --- Historial (incluye cerrados) ---
          historyAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Text('No hay ingresos registrados.');
              }
              // Orden ya viene del provider por createdAt desc; por si acaso:
              final sorted = [...items]
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, idx) {
                  final it = sorted[idx];
                  final isActive = it.state != IntakeState.cerrado;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isActive
                          ? Icons.playlist_add_check
                          : Icons.archive_outlined,
                    ),
                    title: Text(
                      '${it.state.name.toUpperCase()} · ${it.priority}',
                    ),
                    subtitle: Text(it.reason),
                    trailing: Text(
                      _fmt(it.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                    // TODO: onTap → abrir detalle del ingreso cuando lo implementemos
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
              // Próximos módulos (diagnóstico, tareas, repuestos):
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

// --- helpers ---

String _fmt(DateTime dt) {
  // dd/MM HH:mm (simple; si preferís, usa intl)
  return '${_2(dt.day)}/${_2(dt.month)} ${_2(dt.hour)}:${_2(dt.minute)}';
}

String _2(int v) => v.toString().padLeft(2, '0');
