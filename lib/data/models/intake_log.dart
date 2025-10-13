enum IntakeLogType { created, stateChanged, note }

class IntakeLog {
  final String id;
  final String intakeId;
  final IntakeLogType type;
  final String message;
  final DateTime timestamp;
  final String? fromState; // para stateChanged
  final String? toState; // para stateChanged

  const IntakeLog({
    required this.id,
    required this.intakeId,
    required this.type,
    required this.message,
    required this.timestamp,
    this.fromState,
    this.toState,
  });

  factory IntakeLog.fromJson(Map<String, dynamic> j) => IntakeLog(
    id: j['id'],
    intakeId: j['intakeId'],
    type: IntakeLogType.values.firstWhere(
      (e) => e.name.toLowerCase() == (j['type'] as String).toLowerCase(),
      orElse: () => IntakeLogType.note,
    ),
    message: j['message'] ?? '',
    timestamp: DateTime.tryParse(j['timestamp'] ?? '') ?? DateTime.now(),
    fromState: j['fromState'],
    toState: j['toState'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'intakeId': intakeId,
    'type': type.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'fromState': fromState,
    'toState': toState,
  };
}
