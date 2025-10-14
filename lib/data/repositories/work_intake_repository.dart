import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_intake.dart';

abstract class WorkIntakeRepository {
  Future<List<WorkIntake>> loadAll();
  Future<void> add(WorkIntake intake);
  Future<void> updateState({
    required String intakeId,
    required IntakeState newState,
  });
}

class LocalWorkIntakeRepository implements WorkIntakeRepository {
  static const _kUserIntakesKey = 'intakes_user';
  List<WorkIntake>? _cache;

  @override
  Future<List<WorkIntake>> loadAll() async {
    if (_cache != null) return _cache!;
    // base dummy
    final baseStr = await rootBundle.loadString(
      'assets/dummy/work_intakes.json',
    );
    final baseList = (json.decode(baseStr) as List)
        .cast<Map<String, dynamic>>();
    final base = baseList.map(WorkIntake.fromJson).toList();

    // user persistidos
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_kUserIntakesKey);
    final user = <WorkIntake>[];
    if (userStr != null && userStr.isNotEmpty) {
      final arr = (json.decode(userStr) as List).cast<Map<String, dynamic>>();
      user.addAll(arr.map(WorkIntake.fromJson));
    }

    _cache = [...base, ...user];
    return _cache!;
  }

  @override
  Future<void> add(WorkIntake intake) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    _cache = [...all, intake];

    // persistimos solo overrides/user
    final userStr = prefs.getString(_kUserIntakesKey);
    final list = <Map<String, dynamic>>[];
    if (userStr != null && userStr.isNotEmpty) {
      list.addAll((json.decode(userStr) as List).cast<Map<String, dynamic>>());
    }
    list.add(intake.toJson());
    await prefs.setString(_kUserIntakesKey, json.encode(list));
  }

  @override
  Future<void> updateState({
    required String intakeId,
    required IntakeState newState,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();

    final idx = all.indexWhere((w) => w.id == intakeId);
    if (idx == -1) return;
    final updated = all[idx].copyWith(state: newState);
    all[idx] = updated;
    _cache = [...all];

    final userStr = prefs.getString(_kUserIntakesKey);
    final userList = <Map<String, dynamic>>[];

    if (userStr != null && userStr.isNotEmpty) {
      userList.addAll(
        (json.decode(userStr) as List).cast<Map<String, dynamic>>(),
      );
    }

    final uIdx = userList.indexWhere((m) => m['id'] == intakeId);
    if (uIdx >= 0) {
      userList[uIdx] = updated.toJson();
    } else {
      userList.add(updated.toJson());
    }

    await prefs.setString(_kUserIntakesKey, json.encode(userList));
  }
}
