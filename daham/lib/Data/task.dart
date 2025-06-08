class Task {
  final String id;
  final String title;
  final String subject;
  final String category;
  final DateTime? dueDate;
  final Map<String, double> memberProgress;

  Task({
    required this.id,
    required this.title,
    required this.subject,
    required this.category,
    required this.dueDate,
    required this.memberProgress,
  });
}
