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

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subject': subject,
    'category': category,
    'dueDate': dueDate?.millisecondsSinceEpoch,
    'memberProgress': memberProgress,
  };

  // Map에서 Task 객체로 변환
  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    subject: map['subject'],
    category: map['category'],
    dueDate:
        map['dueDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
            : null,
    memberProgress: Map<String, double>.from(map['memberProgress'] ?? {}),
  );
}
