import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_intake.dart';

abstract class WorkIntakeRepository {
  Future<List<WorkIntake>> loadAll();
  Future<void> add(WorkIntake intake);
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

    // guardamos SOLO los user (no mezclamos con base)
    final userStr = prefs.getString(_kUserIntakesKey);
    final list = <Map<String, dynamic>>[];
    if (userStr != null && userStr.isNotEmpty) {
      list.addAll((json.decode(userStr) as List).cast<Map<String, dynamic>>());
    }
    list.add(intake.toJson());
    await prefs.setString(_kUserIntakesKey, json.encode(list));
  }
}
