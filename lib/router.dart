import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/scan/scan_page.dart';
import 'views/fdu/fdu_page.dart';

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
  ],
);
