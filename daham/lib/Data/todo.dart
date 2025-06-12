import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';

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

class TodoDetailItem extends StatelessWidget {
  final PersonalTodoItem todo;

  const TodoDetailItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('마감일: ${todo.dueDate}'),
          Text('우선순위: ${todo.priority}'),
          Text('완료여부: ${todo.complete ? "완료" : "미완료"}'),
          if (todo.details != null)
            ...todo.details!.entries.map((e) => Text('${e.key}: ${e.value}')),
        ],
      ),
    );
  }
}
