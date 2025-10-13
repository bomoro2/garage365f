import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/scan/scan_page.dart';
import 'views/fdu/fdu_page.dart';
import 'views/qr/qr_scan_page.dart';
import 'views/qr/qr_preview_page.dart';
import 'state/asset_list_provider.dart'; // para resolver assetCode en preview
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/asset/create_asset_page.dart';
import 'views/intake/create_intake_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const ScanPage()),
    GoRoute(
      path: '/fdu/:assetId',
      builder: (ctx, st) {
        final assetId = st.pathParameters['assetId']!;
        return FduPage(assetId: assetId);
      },
    ),
    GoRoute(path: '/qr/scan', builder: (ctx, st) => const QrScanPage()),
    GoRoute(path: '/assets/new', builder: (ctx, st) => const CreateAssetPage()),
    GoRoute(
      path: '/intake/new/:assetId',
      builder: (ctx, st) =>
          CreateIntakePage(assetId: st.pathParameters['assetId']!),
    ),
    GoRoute(
      path: '/qr/preview/:assetId',
      builder: (ctx, st) {
        final assetId = st.pathParameters['assetId']!;
        return _QrPreviewResolver(
          assetId: assetId,
        ); // <- directo, sin ProviderScope
      },
    ),
  ],
);

class _QrPreviewResolver extends ConsumerWidget {
  final String assetId;
  const _QrPreviewResolver({required this.assetId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetListProvider);
    return assets.when(
      data: (list) {
        final a = list.firstWhere(
          (x) => x.id == assetId,
          orElse: () => throw Exception('Asset no encontrado'),
        );
        return QrPreviewPage(assetCode: a.code, assetId: a.id);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
