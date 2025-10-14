import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsStore {
  static Future<List<Map<String, dynamic>>> readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    return list;
  }

  static Future<void> writeList(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
  }
}
