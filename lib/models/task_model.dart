class Task {
  final String id;
  final String projectId; // ties it to a project
  final String name;
  final String status;
  final String notes;

  Task({
    required this.id,
    required this.projectId,
    required this.name,
    required this.status,
    required this.notes,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      name: map['name'] as String,
      notes: map['notes'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'notes': notes,
      'status': status,
    };
  }
}
