class TodoItemData {
  final String title;
  final String subtitle;
  final bool checked;

  TodoItemData({
    required this.title,
    required this.subtitle,
    required this.checked,
  });
}

enum Priority { low, medium, high }

class PersonalTodoItem {
  final String id;
  final String task;
  final String dueDate;
  final bool complete;
  final Map<String, dynamic>? details;
  final String priority;

  PersonalTodoItem({
    required this.id,
    required this.task,
    required this.dueDate,
    required this.complete,
    this.details,
    required this.priority,
  });

  factory PersonalTodoItem.fromMap(Map<String, dynamic> map) {
    return PersonalTodoItem(
      id: map['id'] ?? '',
      task: map['task'] ?? '',
      dueDate: map['due_date'] ?? '',
      complete: map['complete'] ?? false,
      priority: map['priority'] ?? 'Low',
      details: map['details'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'due_date': dueDate,
      'complete': complete,
      'priority': priority,
      if (details != null) 'details': details,
    };
  }
}
