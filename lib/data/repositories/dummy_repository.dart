import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/asset.dart';
import '../models/work_intake.dart';

class DummyRepository {
  Future<List<Asset>> loadAssets() async {
    final s = await rootBundle.loadString('assets/dummy/assets.json');
    final list = (json.decode(s) as List).cast<Map<String, dynamic>>();
    return list.map(Asset.fromJson).toList();
  }

  Future<List<WorkIntake>> loadWorkIntakes() async {
    final s = await rootBundle.loadString('assets/dummy/work_intakes.json');
    final list = (json.decode(s) as List).cast<Map<String, dynamic>>();
    return list.map(WorkIntake.fromJson).toList();
  }
}
