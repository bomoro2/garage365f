import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/asset_list_provider.dart';
// no hace falta importar la vista directa si la tenés en el router,
// pero lo dejamos por si querés usar Navigator.push
import '../sensors/sensor_scope_page.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage365 · Equipos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: assets.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('No hay equipos registrados'))
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final a = list[i];
                  return ListTile(
                    title: Text('${a.code} · ${a.type}'),
                    subtitle:
                        Text('${a.brand} ${a.model} · ${a.hourmeter} h'),
                    trailing: const Icon(Icons.qr_code_2),
                    onTap: () => context.push('/fdu/${a.id}'),
                  );
                },
              ),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Nuevo equipo
          Tooltip(
            message: 'Nuevo equipo',
            child: FloatingActionButton.extended(
              heroTag: 'fab-create-asset',
              onPressed: () => context.push('/assets/new'),
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Nuevo equipo'),
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Escanear QR
          Tooltip(
            message: 'Escanear QR',
            child: FloatingActionButton.extended(
              heroTag: 'fab-scan-qr',
              onPressed: () => context.push('/qr/scan'),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Escanear QR'),
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 NUEVO: abrir SensorScope
          Tooltip(
            message: 'SensorScope',
            child: FloatingActionButton.extended(
              heroTag: 'fab-sensor-scope',
              onPressed: () => context.push('/sensor-scope'),
              icon: const Icon(Icons.multitrack_audio_rounded),
              label: const Text('Sensores'),
            ),
          ),
        ],
      ),
    );
  }
}
