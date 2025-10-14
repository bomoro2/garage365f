enum TaskType { diagnostico, reparacion }

enum TaskStatus { todo, doing, waitingParts, done }

class Task {
  final String id;
  final String intakeId;
  final TaskType type;
  final String title;
  final String? notes;
  final TaskStatus status;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.intakeId,
    required this.type,
    required this.title,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'],
    intakeId: j['intakeId'],
    type: TaskType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => TaskType.diagnostico,
    ),
    title: j['title'] ?? '',
    notes: j['notes'],
    status: TaskStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => TaskStatus.todo,
    ),
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'intakeId': intakeId,
    'type': type.name,
    'title': title,
    'notes': notes,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  Task copyWith({TaskStatus? status, String? notes}) => Task(
    id: id,
    intakeId: intakeId,
    type: type,
    title: title,
    notes: notes ?? this.notes,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}
