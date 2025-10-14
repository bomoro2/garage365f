import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/work_intake.dart';
import 'prefs_store.dart';

abstract class WorkIntakeRepository {
  Future<List<WorkIntake>> loadAll();
  Future<void> add(WorkIntake i);
  Future<void> updateState({
    required String intakeId,
    required IntakeState newState,
  });
}

class PrefsWorkIntakeRepository implements WorkIntakeRepository {
  static const _kKey = 'intakes_user';
  List<WorkIntake>? _cache;

  Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    final raw = await PrefsStore.readList(_kKey);
    if (raw.isNotEmpty) {
      _cache = raw.map(WorkIntake.fromJson).toList();
      return;
    }
    // si querés seed inicial:
    try {
      final seedStr = await rootBundle.loadString(
        'assets/dummy/work_intakes.json',
      );
      final seed = (json.decode(seedStr) as List).cast<Map<String, dynamic>>();
      _cache = seed.map(WorkIntake.fromJson).toList();
    } catch (_) {
      _cache = <WorkIntake>[];
    }
    await _save();
  }

  Future<void> _save() async {
    await PrefsStore.writeList(
      _kKey,
      (_cache ?? []).map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<List<WorkIntake>> loadAll() async {
    await _ensureLoaded();
    return _cache ?? <WorkIntake>[];
  }

  @override
  Future<void> add(WorkIntake i) async {
    await _ensureLoaded();
    _cache = [...?_cache, i];
    await _save();
  }

  @override
  Future<void> updateState({
    required String intakeId,
    required IntakeState newState,
  }) async {
    await _ensureLoaded();
    final idx = _cache!.indexWhere((e) => e.id == intakeId);
    if (idx != -1) {
      _cache![idx] = _cache![idx].copyWith(state: newState);
      await _save();
    }
  }
}
