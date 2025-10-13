import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/asset_list_provider.dart';
import '../../state/intake_provider.dart';
import 'package:go_router/go_router.dart';

class FduPage extends ConsumerWidget {
  final String assetId;
  const FduPage({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetAsync = ref.watch(assetListProvider);
    final intakeAsync = ref.watch(activeIntakeByAssetProvider(assetId));

    return Scaffold(
      appBar: AppBar(title: const Text('FDU · Ingreso')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            FilledButton.icon(
              onPressed: () => context.push('/qr/preview/$assetId'),
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Ver QR del equipo'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.push('/intake/new/$assetId'),
              icon: const Icon(Icons.add_task),
              label: const Text('Nuevo ingreso'),
            ),

            const SizedBox(height: 8),
            intakeAsync.when(
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
                    title: Text('Estado: ${i.state.name.toUpperCase()}'),
                    subtitle: Text(
                      'Motivo: ${i.reason} · Prioridad: ${i.priority}',
                    ),
                  ),
                );
              },
              // loading/error igual que antes…
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error intake: $e'),
            ),

            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                // Navegar a próximas pantallas (diagnóstico, tareas, repuestos, etc.)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navegación a módulos en construcción'),
                  ),
                );
              },
              icon: const Icon(Icons.playlist_add_check),
              label: const Text(
                'Abrir módulos (Diagnóstico, Tareas, Repuestos)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
