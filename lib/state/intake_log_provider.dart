import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/intake_log.dart';
import '../data/repositories/intake_log_repository.dart';

final intakeLogRepoProvider = Provider<IntakeLogRepository>(
  (ref) => LocalIntakeLogRepository(),
);

final intakeLogListByIntakeProvider =
    FutureProvider.family<List<IntakeLog>, String>((ref, intakeId) async {
      final repo = ref.watch(intakeLogRepoProvider);
      return repo.listByIntake(intakeId);
    });

final addIntakeLogProvider = Provider<Future<void> Function(IntakeLog)>((ref) {
  return (IntakeLog log) async {
    final repo = ref.read(intakeLogRepoProvider);
    await repo.add(log);
    ref.invalidate(intakeLogListByIntakeProvider(log.intakeId));
  };
});
