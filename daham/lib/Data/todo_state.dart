import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'todo.dart'; // PersonalTodoItem 모델 불러오기

class TodoState with ChangeNotifier {
  List<PersonalTodoItem> todoList = [];

  /// 🔹 할 일 추가 (로컬 저장)
  void addTodo(String task) {
    final todoId = const Uuid().v4();
    final now = DateTime.now();

    final newTodo = PersonalTodoItem(
      id: todoId,
      task: task,
      dueDate: now.toIso8601String(),
      complete: false,
      priority: 'medium',
      details: null,
    );

    todoList.add(newTodo);
    notifyListeners();
  }

  /// 🔹 체크박스 토글
  void changeCompleteTodo(String todoId) {
    final index = todoList.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    final old = todoList[index];
    todoList[index] = PersonalTodoItem(
      id: old.id,
      task: old.task,
      dueDate: old.dueDate,
      complete: !old.complete,
      priority: old.priority,
      details: old.details,
    );

    notifyListeners();
  }

  /// 🔹 전체 초기화도 가능
  void clearTodos() {
    todoList.clear();
    notifyListeners();
  }
}
