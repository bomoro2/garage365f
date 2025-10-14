enum TaskLogType { created, statusChanged, note }

class TaskLog {
  final String id;
  final String taskId;
  final TaskLogType type;
  final String message;
  final DateTime timestamp;
  final String? fromStatus;
  final String? toStatus;

  const TaskLog({
    required this.id,
    required this.taskId,
    required this.type,
    required this.message,
    required this.timestamp,
    this.fromStatus,
    this.toStatus,
  });

  factory TaskLog.fromJson(Map<String, dynamic> j) => TaskLog(
    id: j['id'],
    taskId: j['taskId'],
    type: TaskLogType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => TaskLogType.note,
    ),
    message: j['message'] ?? '',
    timestamp: DateTime.tryParse(j['timestamp'] ?? '') ?? DateTime.now(),
    fromStatus: j['fromStatus'],
    toStatus: j['toStatus'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': taskId,
    'type': type.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'fromStatus': fromStatus,
    'toStatus': toStatus,
  };
}
