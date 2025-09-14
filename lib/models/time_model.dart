class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double totalTime;
  final DateTime date;
  final String notes;
  // timer-specific fields
  final DateTime? startTime;
  final DateTime? endTime;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.date,
    required this.notes,
    this.startTime,
    this.endTime,
  });

  TimeEntry copyWith({
    String? id,
    String? projectId,
    String? taskId,
    String? notes,
    double? totalTime,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.notes,
      totalTime: totalTime ?? this.totalTime,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      notes: notes ?? this.notes,
      endTime: endTime ?? this.endTime,
    );
  }

  // convert a map into a TimeEntry
  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      taskId: map['taskId'] as String,
      totalTime: (map['totalTime'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String,
    );
  }

  // Convert a time entry into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'totalTime': totalTime,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}
