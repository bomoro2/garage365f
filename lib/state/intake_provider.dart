import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/work_intake.dart';
import 'asset_list_provider.dart'; // importa aquí para usar dummyRepoProvider

final intakeListProvider = FutureProvider<List<WorkIntake>>((ref) async {
  final repo = ref.watch(dummyRepoProvider);
  return repo.loadWorkIntakes();
});

// Retorna nullable de forma segura (sin crashear si no existe)
final activeIntakeByAssetProvider = FutureProvider.family<WorkIntake?, String>((
  ref,
  assetId,
) async {
  final list = await ref.watch(intakeListProvider.future);
  try {
    return list.firstWhere(
      (i) => i.assetId == assetId && i.state != IntakeState.cerrado,
    );
  } catch (_) {
    return null;
  }
});
