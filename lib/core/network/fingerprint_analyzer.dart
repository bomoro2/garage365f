import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:collection/collection.dart';

class FingerprintAnalyzer {
  /// Crea bandas de energía (simple binning) sobre una serie (vib o audio)
  /// Para vibración usamos magnitud acelerómetro; para audio, RMS frames.
  List<double> bandEnergies(List<double> series, {int bands = 8}) {
    if (series.isEmpty) return List.filled(bands, 0);
    final chunk = (series.length / bands).floor().clamp(1, series.length);
    final energies = <double>[];

    for (int b = 0; b < bands; b++) {
      final start = b * chunk;
      final end = min(series.length, start + chunk);
      if (start >= end) {
        energies.add(0);
      } else {
        final seg = series.sublist(start, end);
        final e = seg.map((x) => x * x).sum; // energía
        energies.add(e);
      }
    }
    return _normalize(energies);
  }

  /// RMS de vibración (magnitud)
  double rms(List<double> series) {
    if (series.isEmpty) return 0;
    final e = series.map((x) => x * x).sum / series.length;
    return sqrt(e);
  }

  /// Hash reproducible del fingerprint
  String hashOf({
    required List<double> vibBands,
    required List<double> audioBands,
    required double vibRms,
    required String equipmentId,
    required int sampleRate,
    required int windowMs,
  }) {
    final data = jsonEncode({
      'eq': equipmentId,
      'vb': vibBands.map((v) => v.toStringAsFixed(6)).toList(),
      'ab': audioBands.map((v) => v.toStringAsFixed(6)).toList(),
      'rms': vibRms.toStringAsFixed(6),
      'sr': sampleRate,
      'win': windowMs,
    });
    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Similaridad coseno entre dos fingerprints (fusionando bandas vib+audio)
  double cosineSimilarity(List<double> a, List<double> b) {
    final n = min(a.length, b.length);
    if (n == 0) return 0;
    double dot = 0, na = 0, nb = 0;
    for (int i = 0; i < n; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (sqrt(na) * sqrt(nb));
  }

  List<double> fuseBands(List<double> vib, List<double> audio) {
    // concat simple (podrías ponderar p.ej. 60% vib, 40% audio)
    return [...vib, ...audio];
  }

  Map<String, double> bandDeltaMap(List<double> a, List<double> b) {
    final n = min(a.length, b.length);
    final out = <String, double>{};
    for (int i = 0; i < n; i++) {
      out['band_$i'] = (a[i] - b[i]).abs();
    }
    return out;
  }

  List<double> _normalize(List<double> v) {
    final s = v.sum;
    if (s == 0) return v;
    return v.map((x) => x / s).toList();
  }
}
