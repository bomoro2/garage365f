import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/asset.dart';
import '../data/repositories/dummy_repository.dart';

final dummyRepoProvider = Provider<DummyRepository>((ref) => DummyRepository());

final assetListProvider = FutureProvider<List<Asset>>((ref) async {
  final repo = ref.watch(dummyRepoProvider);
  return repo.loadAssets();
});
