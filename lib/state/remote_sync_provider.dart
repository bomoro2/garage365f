import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

final dioProvider = Provider<Dio>((ref) => buildDio());
