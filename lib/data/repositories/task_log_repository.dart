import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_log.dart';

abstract class TaskLogRepository {
  Future<List<TaskLog>> listByTask(String taskId);
  Future<void> add(TaskLog log);
}

class LocalTaskLogRepository implements TaskLogRepository {
  static const _kKey = 'task_logs_user';
  List<TaskLog>? _cache;

  Future<void> _load() async {
    if (_cache != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) {
      _cache = <TaskLog>[];
      return;
    }
    final arr = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    _cache = arr.map(TaskLog.fromJson).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKey,
      json.encode((_cache ?? []).map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<TaskLog>> listByTask(String taskId) async {
    await _load();
    final items = (_cache ?? []).where((e) => e.taskId == taskId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  @override
  Future<void> add(TaskLog log) async {
    await _load();
    _cache = [...?_cache, log];
    await _save();
  }
}
