import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset.dart';

abstract class AssetRepository {
  Future<List<Asset>> loadAll();
  Future<void> add(Asset a);
}

class LocalAssetRepository implements AssetRepository {
  static const _kUserAssetsKey = 'assets_user';
  List<Asset>? _cache;

  @override
  Future<List<Asset>> loadAll() async {
    if (_cache != null) return _cache!;
    // base (assets.json)
    final baseStr = await rootBundle.loadString('assets/dummy/assets.json');
    final baseList = (json.decode(baseStr) as List)
        .cast<Map<String, dynamic>>();
    final base = baseList.map(Asset.fromJson).toList();

    // user-added (persistentes)
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_kUserAssetsKey);
    final user = <Asset>[];
    if (userStr != null && userStr.isNotEmpty) {
      final userList = (json.decode(userStr) as List)
          .cast<Map<String, dynamic>>();
      user.addAll(userList.map(Asset.fromJson));
    }

    _cache = [...base, ...user];
    return _cache!;
  }

  @override
  Future<void> add(Asset a) async {
    // actualiza cache y prefs
    final prefs = await SharedPreferences.getInstance();
    final current = await loadAll();
    _cache = [...current, a];

    // solo persistimos los "user" (no mezclamos con base)
    final userStr = prefs.getString(_kUserAssetsKey);
    final user = <Map<String, dynamic>>[];
    if (userStr != null && userStr.isNotEmpty) {
      user.addAll((json.decode(userStr) as List).cast<Map<String, dynamic>>());
    }
    user.add(a.toJson());
    await prefs.setString(_kUserAssetsKey, json.encode(user));
  }
}
