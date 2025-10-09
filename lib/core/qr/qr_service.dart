import 'dart:convert';
import 'package:crypto/crypto.dart';

class QrService {
  static const _version = '1';
  // En dummy podés dejarla fija, luego la pasamos a remote config/secure storage
  static const _secret = 'g365-dev-secret';

  static String _sig(String id, String v) {
    final bytes = utf8.encode('$id|$v|$_secret');
    final digest = sha256.convert(bytes).bytes;
    final short = digest
        .take(5)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return short.substring(0, 8).toUpperCase();
  }

  static String buildDeepLink(String assetId) {
    final sig = _sig(assetId, _version);
    return 'g365://asset?id=$assetId&v=$_version&sig=$sig';
  }

  static Uri? tryParse(String raw) {
    try {
      return Uri.parse(raw);
    } catch (_) {
      return null;
    }
  }

  static bool verify(Uri uri) {
    final id = uri.queryParameters['id'];
    final v = uri.queryParameters['v'] ?? _version;
    final sig = uri.queryParameters['sig'];
    if (id == null || sig == null) return false;
    return _sig(id, v).substring(0, 8).toUpperCase() == sig.toUpperCase();
  }

  /// Soporta 3 variantes:
  /// 1) g365://asset?id=a1&v=1&sig=XXXX
  /// 2) https://g365.app/a/<id>?...
  /// 3) solo 'a1' (dummy)
  static String? extractAssetId(String data) {
    final uri = tryParse(data);
    if (uri == null) return data.isNotEmpty ? data : null;
    if (uri.scheme == 'g365' && uri.host == 'asset') {
      final id = uri.queryParameters['id'];
      if (id == null) return null;
      // En dummy no forzamos verify para no bloquear pruebas:
      return id;
    }
    if (uri.scheme.startsWith('http') && uri.pathSegments.isNotEmpty) {
      // https://g365.app/a/<id>
      if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'a') {
        return uri.pathSegments[1];
      }
    }
    return null;
  }
}
