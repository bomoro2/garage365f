class Asset {
  final String id;
  final String code; // QR/NFC visible
  final String type; // "Generador", "Torre", etc.
  final String brand;
  final String model;
  final int hourmeter;

  const Asset({
    required this.id,
    required this.code,
    required this.type,
    required this.brand,
    required this.model,
    required this.hourmeter,
  });

  factory Asset.fromJson(Map<String, dynamic> j) => Asset(
    id: j['id'],
    code: j['code'],
    type: j['type'],
    brand: j['brand'],
    model: j['model'],
    hourmeter: j['hourmeter'] ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'type': type,
    'brand': brand,
    'model': model,
    'hourmeter': hourmeter,
  };
}
