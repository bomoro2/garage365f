enum IntakeState {
  ingresado,
  diagnostico,
  aprobacion,
  enProceso,
  esperaRepuestos,
  pruebas,
  listo,
  entregado,
  cerrado,
}

class WorkIntake {
  final String id;
  final String assetId;
  final IntakeState state;
  final String reason;
  final String priority;
  final DateTime createdAt;

  const WorkIntake({
    required this.id,
    required this.assetId,
    required this.state,
    required this.reason,
    required this.priority,
    required this.createdAt,
  });

  factory WorkIntake.fromJson(Map<String, dynamic> j) => WorkIntake(
    id: j['id'],
    assetId: j['assetId'],
    state: IntakeState.values.firstWhere(
      (e) =>
          e.name.toLowerCase() ==
          (j['state'] as String).toString().toLowerCase(),
      orElse: () => IntakeState.ingresado,
    ),
    reason: j['reason'] ?? '',
    priority: j['priority'] ?? 'MEDIA',
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetId': assetId,
    'state': state.name,
    'reason': reason,
    'priority': priority,
    'createdAt': createdAt.toIso8601String(),
  };

  WorkIntake copyWith({
    String? id,
    String? assetId,
    IntakeState? state,
    String? reason,
    String? priority,
    DateTime? createdAt,
  }) => WorkIntake(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    state: state ?? this.state,
    reason: reason ?? this.reason,
    priority: priority ?? this.priority,
    createdAt: createdAt ?? this.createdAt,
  );
}
