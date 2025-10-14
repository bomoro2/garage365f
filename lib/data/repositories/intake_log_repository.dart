import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/intake_log.dart';

abstract class IntakeLogRepository {
  Future<List<IntakeLog>> listByIntake(String intakeId);
  Future<void> add(IntakeLog log);
}

class LocalIntakeLogRepository implements IntakeLogRepository {
  static const _kLogsKey = 'intake_logs_user';
  List<IntakeLog>? _cache; // todos

  Future<void> _loadCache() async {
    if (_cache != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLogsKey);
    if (raw == null || raw.isEmpty) {
      _cache = <IntakeLog>[];
      return;
    }
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    _cache = list.map(IntakeLog.fromJson).toList();
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode((_cache ?? []).map((e) => e.toJson()).toList());
    await prefs.setString(_kLogsKey, data);
  }

  @override
  Future<List<IntakeLog>> listByIntake(String intakeId) async {
    await _loadCache();
    final items = (_cache ?? []).where((e) => e.intakeId == intakeId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  @override
  Future<void> add(IntakeLog log) async {
    await _loadCache();
    _cache = [...?_cache, log];
    await _saveCache();
  }
}
