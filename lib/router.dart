import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/scan/scan_page.dart';
import 'views/fdu/fdu_page.dart';
import 'views/qr/qr_scan_page.dart';
import 'views/qr/qr_preview_page.dart';
import 'views/asset/create_asset_page.dart';
import 'views/intake/create_intake_page.dart';
import 'views/intake/intake_detail_page.dart'; // <- NUEVO
import 'state/asset_list_provider.dart';
import 'views/task/task_list_page.dart';
import 'views/task/task_detail_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const ScanPage()),
    GoRoute(
      path: '/fdu/:assetId',
      builder: (ctx, st) => FduPage(assetId: st.pathParameters['assetId']!),
    ),
    GoRoute(path: '/qr/scan', builder: (ctx, st) => const QrScanPage()),
    GoRoute(
      path: '/qr/preview/:assetId',
      builder: (ctx, st) =>
          _QrPreviewResolver(assetId: st.pathParameters['assetId']!),
    ),
    GoRoute(path: '/assets/new', builder: (ctx, st) => const CreateAssetPage()),
    GoRoute(
      path: '/intake/new/:assetId',
      builder: (ctx, st) =>
          CreateIntakePage(assetId: st.pathParameters['assetId']!),
    ),
    // 🔥 Ruta que faltaba: detalle del ingreso con timeline
    GoRoute(
      path: '/intake/detail/:intakeId/:assetId',
      builder: (ctx, st) => IntakeDetailPage(
        intakeId: st.pathParameters['intakeId']!,
        assetId: st.pathParameters['assetId']!,
      ),
    ),
    GoRoute(
      path: '/intake/:intakeId/tasks',
      builder: (ctx, st) =>
          TaskListPage(intakeId: st.pathParameters['intakeId']!),
    ),
    GoRoute(
      path: '/task/detail/:taskId/:intakeId',
      builder: (ctx, st) => TaskDetailPage(
        taskId: st.pathParameters['taskId']!,
        intakeId: st.pathParameters['intakeId']!,
      ),
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
