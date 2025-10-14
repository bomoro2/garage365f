import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'asset_list_provider.dart';
import 'intake_provider.dart';
import 'intake_log_provider.dart';
import 'task_provider.dart';
import 'task_log_provider.dart';

import '../data/repositories/prefs_store.dart';

final resetDemoProvider = FutureProvider<void>((ref) async {
  await PrefsStore.clearAll();
  // invalidar para que recarguen desde estado inicial
  ref.invalidate(assetRepoProvider);
  ref.invalidate(intakeRepoProvider);
  ref.invalidate(intakeLogRepoProvider);
  ref.invalidate(taskRepoProvider);
  ref.invalidate(taskLogRepoProvider);
});
