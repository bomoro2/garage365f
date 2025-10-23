import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/network/env.dart';


void main() {    
  // LOG: confirmar base url en consola
  // ignore: avoid_print
  print('[ENV] API_BASE_URL = ${AppEnv.baseUrl}');
  runApp(const ProviderScope(child: GarageApp()));
}
