import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/asset_list_provider.dart';
import 'package:go_router/go_router.dart';

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
          IconButton(
            tooltip: 'Nuevo equipo',
            onPressed: () => context.push('/assets/new'),
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),

      body: assets.when(
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final a = list[i];
            return ListTile(
              title: Text('${a.code} · ${a.type}'),
              subtitle: Text('${a.brand} ${a.model} · ${a.hourmeter} h'),
              trailing: const Icon(Icons.qr_code_2),
              onTap: () => context.push('/fdu/${a.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/qr/scan'),
        label: const Text('Escanear QR'),
        icon: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }
}
