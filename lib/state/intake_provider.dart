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

/// Último ingreso ACTIVO (no cerrado), por fecha desc
final activeIntakeByAssetProvider = FutureProvider.family<WorkIntake?, String>((
  ref,
  assetId,
) async {
  final list = await ref.watch(intakeListProvider.future);
  final filtered =
      list
          .where((i) => i.assetId == assetId && i.state != IntakeState.cerrado)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return filtered.isEmpty ? null : filtered.first;
});

/// Historial completo (incluye cerrados), por fecha desc
final intakeHistoryByAssetProvider =
    FutureProvider.family<List<WorkIntake>, String>((ref, assetId) async {
      final list = await ref.watch(intakeListProvider.future);
      final filtered = list.where((i) => i.assetId == assetId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });

/// Acción: actualizar estado
final updateIntakeStateProvider =
    Provider<
      Future<void> Function({
        required String intakeId,
        required String assetId,
        required IntakeState newState,
      })
    >((ref) {
      return ({
        required String intakeId,
        required String assetId,
        required IntakeState newState,
      }) async {
        final repo = ref.read(intakeRepoProvider);
        await repo.updateState(intakeId: intakeId, newState: newState);
        // refrescos
        ref.invalidate(intakeListProvider);
        ref.invalidate(activeIntakeByAssetProvider(assetId));
        ref.invalidate(intakeHistoryByAssetProvider(assetId));
      };
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
