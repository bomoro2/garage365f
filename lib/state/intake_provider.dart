import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/work_intake.dart';
import '../data/repositories/work_intake_repository.dart';

final intakeRepoProvider = Provider<WorkIntakeRepository>(
  (ref) => LocalWorkIntakeRepository(),
);

final intakeListProvider = FutureProvider<List<WorkIntake>>((ref) async {
  final repo = ref.watch(intakeRepoProvider);
  return repo.loadAll();
});

final activeIntakeByAssetProvider = FutureProvider.family<WorkIntake?, String>((
  ref,
  assetId,
) async {
  final list = await ref.watch(intakeListProvider.future);
  try {
    return list.lastWhere(
      (i) => i.assetId == assetId && i.state != IntakeState.cerrado,
    );
  } catch (_) {
    return null;
  }
});

/// Historial completo para el asset (incluye cerrados), ordenado por fecha descendente
final intakeHistoryByAssetProvider =
    FutureProvider.family<List<WorkIntake>, String>((ref, assetId) async {
      final list = await ref.watch(intakeListProvider.future);
      final filtered = list.where((i) => i.assetId == assetId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });

// acción crear ingreso
final createIntakeProvider = Provider<Future<void> Function(WorkIntake)>((ref) {
  return (WorkIntake i) async {
    final repo = ref.read(intakeRepoProvider);
    await repo.add(i);
    // refrescar ambas vistas
    ref.invalidate(intakeListProvider);
    ref.invalidate(activeIntakeByAssetProvider(i.assetId));
    ref.invalidate(intakeHistoryByAssetProvider(i.assetId));
  };
});
