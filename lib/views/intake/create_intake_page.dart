import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../state/intake_provider.dart';
import '../../data/models/work_intake.dart';

class CreateIntakePage extends ConsumerStatefulWidget {
  final String assetId;
  const CreateIntakePage({super.key, required this.assetId});

  @override
  ConsumerState<CreateIntakePage> createState() => _CreateIntakePageState();
}

class _CreateIntakePageState extends ConsumerState<CreateIntakePage> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  String _priority = 'MEDIA';
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final id = const Uuid().v4();
      final intake = WorkIntake(
        id: id,
        assetId: widget.assetId,
        state: IntakeState.ingresado, // estado inicial
        reason: _reason.text.trim(),
        priority: _priority,
        createdAt: DateTime.now(),
      );

      // usa el provider existente para crear y refrescar listas
      final create = ref.read(createIntakeProvider);
      await create(intake);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingreso creado')));
      context.pop(); // volver a la FDU manteniendo el back
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear ingreso: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo ingreso')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _reason,
              maxLines: 3,
              decoration: _dec(
                'Motivo',
                hint: 'Descripción breve del problema',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _priority,
                  items: const [
                    DropdownMenuItem(value: 'ALTA', child: Text('ALTA')),
                    DropdownMenuItem(value: 'MEDIA', child: Text('MEDIA')),
                    DropdownMenuItem(value: 'BAJA', child: Text('BAJA')),
                  ],
                  onChanged: (v) => setState(() => _priority = v ?? 'MEDIA'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Crear ingreso'),
            ),
          ],
        ),
      ),
    );
  }
}
