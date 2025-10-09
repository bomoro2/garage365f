import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/asset.dart';
import '../data/repositories/asset_repository.dart';

// Repo
final assetRepoProvider = Provider<AssetRepository>(
  (ref) => LocalAssetRepository(),
);

// Lista de equipos
final assetListProvider = FutureProvider<List<Asset>>((ref) async {
  final repo = ref.watch(assetRepoProvider);
  return repo.loadAll();
});

// Acción: crear equipo
final createAssetProvider = Provider<Future<void> Function(Asset)>((ref) {
  return (Asset a) async {
    final repo = ref.read(assetRepoProvider);
    await repo.add(a);
    // refrescamos la lista
    ref.invalidate(assetListProvider);
  };
});
