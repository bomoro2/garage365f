import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/asset.dart';
import 'prefs_store.dart';

abstract class AssetRepository {
  Future<List<Asset>> loadAll();
  Future<void> add(Asset a);
  Future<void> update(Asset a);
}

class PrefsAssetRepository implements AssetRepository {
  static const _kKey = 'assets_user';
  List<Asset>? _cache;

  Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    // 1) intento leer de prefs
    final raw = await PrefsStore.readList(_kKey);
    if (raw.isNotEmpty) {
      _cache = raw.map(Asset.fromJson).toList();
      return;
    }
    // 2) si prefs vacío => seed desde assets bundle (primera corrida)
    final seedStr = await rootBundle.loadString('assets/dummy/assets.json');
    final seed = (json.decode(seedStr) as List).cast<Map<String, dynamic>>();
    _cache = seed.map(Asset.fromJson).toList();
    await _save();
  }

  Future<void> _save() async {
    await PrefsStore.writeList(
      _kKey,
      (_cache ?? []).map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<List<Asset>> loadAll() async {
    await _ensureLoaded();
    return _cache ?? <Asset>[];
  }

  @override
  Future<void> add(Asset a) async {
    await _ensureLoaded();
    _cache = [...?_cache, a];
    await _save();
  }

  @override
  Future<void> update(Asset a) async {
    await _ensureLoaded();
    final i = _cache!.indexWhere((x) => x.id == a.id);
    if (i != -1) _cache![i] = a;
    await _save();
  }
}
