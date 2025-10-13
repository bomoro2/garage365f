import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/work_intake.dart';
import '../data/repositories/work_intake_repository.dart';

import '../data/models/intake_log.dart';
import 'intake_log_provider.dart';

/// --- Repositorio principal ---
final intakeRepoProvider = Provider<WorkIntakeRepository>(
  (ref) => LocalWorkIntakeRepository(),
);

/// --- Lista completa de ingresos ---
final intakeListProvider = FutureProvider<List<WorkIntake>>((ref) async {
  final repo = ref.watch(intakeRepoProvider);
  return repo.loadAll();
});

/// --- Crear nuevo ingreso (y log 'created') ---
final createIntakeProvider = Provider<Future<void> Function(WorkIntake)>((ref) {
  return (WorkIntake intake) async {
    final repo = ref.read(intakeRepoProvider);
    await repo.add(intake);

    // Log: created
    final addLog = ref.read(addIntakeLogProvider);
    await addLog(
      IntakeLog(
        id: const Uuid().v4(),
        intakeId: intake.id,
        type: IntakeLogType.created,
        message: 'Ingreso creado (estado: ${intake.state.name.toUpperCase()})',
        timestamp: DateTime.now(),
      ),
    );

    // refrescos
    ref.invalidate(intakeListProvider);
    ref.invalidate(activeIntakeByAssetProvider(intake.assetId));
    ref.invalidate(intakeHistoryByAssetProvider(intake.assetId));
  };
});

/// --- Último ingreso ACTIVO (no cerrado) ---
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

/// --- Historial de ingresos (todos, incluso cerrados) ---
final intakeHistoryByAssetProvider =
    FutureProvider.family<List<WorkIntake>, String>((ref, assetId) async {
      final list = await ref.watch(intakeListProvider.future);
      final filtered = list.where((i) => i.assetId == assetId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });

/// --- Actualizar estado de un ingreso (y log 'stateChanged') ---
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

        // necesitamos el estado anterior para el log
        final all = await ref.read(intakeListProvider.future);
        final before = all.firstWhere((e) => e.id == intakeId);

        await repo.updateState(intakeId: intakeId, newState: newState);

        final addLog = ref.read(addIntakeLogProvider);
        await addLog(
          IntakeLog(
            id: const Uuid().v4(),
            intakeId: intakeId,
            type: IntakeLogType.stateChanged,
            message:
                'Estado: ${before.state.name.toUpperCase()} → ${newState.name.toUpperCase()}',
            timestamp: DateTime.now(),
            fromState: before.state.name,
            toState: newState.name,
          ),
        );

        // refrescar providers relacionados
        ref.invalidate(intakeListProvider);
        ref.invalidate(activeIntakeByAssetProvider(assetId));
        ref.invalidate(intakeHistoryByAssetProvider(assetId));
      };
    });
