import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

void safeBack(BuildContext context, {String fallback = '/'}) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go(fallback);
  }
}
