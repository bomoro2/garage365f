import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> loadAll();
  Future<void> add(Task t);
  Future<void> update(Task t);
}

class LocalTaskRepository implements TaskRepository {
  static const _kKey = 'tasks_user';
  List<Task>? _cache;

  Future<void> _loadCache() async {
    if (_cache != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) {
      _cache = [];
      return;
    }
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    _cache = list.map(Task.fromJson).toList();
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode((_cache ?? []).map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, data);
  }

  @override
  Future<List<Task>> loadAll() async {
    await _loadCache();
    return _cache ?? [];
  }

  @override
  Future<void> add(Task t) async {
    await _loadCache();
    _cache = [...?_cache, t];
    await _saveCache();
  }

  @override
  Future<void> update(Task t) async {
    await _loadCache();
    final i = _cache!.indexWhere((e) => e.id == t.id);
    if (i != -1) _cache![i] = t;
    await _saveCache();
  }
}
