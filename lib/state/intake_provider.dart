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

// acción crear ingreso
final createIntakeProvider = Provider<Future<void> Function(WorkIntake)>((ref) {
  return (WorkIntake i) async {
    final repo = ref.read(intakeRepoProvider);
    await repo.add(i);
    // refrescar lista
    ref.invalidate(intakeListProvider);
  };
});
