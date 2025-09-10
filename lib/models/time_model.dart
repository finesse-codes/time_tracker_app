class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double totalTime;
  final DateTime date;
  final String notes;
  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.date,
    required this.notes,
  });
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
