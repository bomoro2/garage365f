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
      appBar: AppBar(title: const Text('Garage365 · Equipos')),
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
              onTap: () => context.go('/fdu/${a.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // acá más adelante: abrir cámara y leer QR → navegar a FDU
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Simulación de scan pendiente')),
          );
        },
        label: const Text('Escanear QR'),
        icon: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }
}
