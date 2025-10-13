import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../state/asset_list_provider.dart';
import '../../data/models/asset.dart';
import 'package:go_router/go_router.dart';

class CreateAssetPage extends ConsumerStatefulWidget {
  const CreateAssetPage({super.key});

  @override
  ConsumerState<CreateAssetPage> createState() => _CreateAssetPageState();
}

class _CreateAssetPageState extends ConsumerState<CreateAssetPage> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _type = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _hm = TextEditingController(text: '0');

  bool _saving = false;

  @override
  void dispose() {
    _code.dispose();
    _type.dispose();
    _brand.dispose();
    _model.dispose();
    _hm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final id = const Uuid().v4(); // ID único
      final a = Asset(
        id: id,
        code: _code.text.trim(),
        type: _type.text.trim(),
        brand: _brand.text.trim(),
        model: _model.text.trim(),
        hourmeter: int.tryParse(_hm.text.trim()) ?? 0,
      );
      final create = ref.read(createAssetProvider);
      await create(a);

      if (!mounted) return;
      // Ir directo a ver su QR (o a la FDU si querés)
      context.go('/qr/preview/$id');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear equipo: $e')));
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
      appBar: AppBar(title: const Text('Nuevo equipo')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _code,
              decoration: _dec('Código visible', hint: 'Ej: GRP07-001'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _type,
              decoration: _dec('Tipo', hint: 'Generador, Torre, etc.'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brand,
              decoration: _dec('Marca', hint: 'Cummins, Atlas Copco...'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _model,
              decoration: _dec('Modelo', hint: 'QSB6.7, QLT H50...'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hm,
              keyboardType: TextInputType.number,
              decoration: _dec('Horómetro inicial (h)'),
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
              label: const Text('Crear y ver QR'),
            ),
          ],
        ),
      ),
    );
  }
}
