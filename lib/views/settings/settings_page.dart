import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reset_demo_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _runReset(BuildContext context, WidgetRef ref) async {
    await ref.refresh(resetDemoProvider.future);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Demo reseteada')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Reset Demo'),
              subtitle: const Text(
                'Borra todos los datos locales (SharedPreferences)',
              ),
              trailing: ElevatedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Confirmar'),
                      content: const Text(
                        '¿Seguro que querés borrar todos los datos locales?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sí, borrar'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await _runReset(context, ref);
                  }
                },
                child: const Text('Borrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
