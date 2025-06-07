import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Data/todo.dart';
import 'package:daham/Provider/export.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoState extends ChangeNotifier {
  StreamSubscription? _userTodoSub;
  List<PersonalTodoItem>? _todoList;

  List<PersonalTodoItem>? get todoList => _todoList;

  void listenTodoData(String uid) {
    _userTodoSub?.cancel();
    _userTodoSub = FirebaseFirestore.instance
        .collection('UserTodo')
        .doc(uid)
        .collection('todos')
        .orderBy('created_at', descending: true)
        .limit(100)
        .snapshots()
        .listen((querySnapshots) {
          _todoList =
              querySnapshots.docs
                  .map((doc) => PersonalTodoItem.fromMap(doc.data()))
                  .toList();

          notifyListeners();
        });
  }

  void cancel() {
    _userTodoSub?.cancel();
    _userTodoSub = null;
    _todoList = null;
    notifyListeners();
  }

  Future<void> changeCompleteTodo(String uid, String todoId) async {
    final docRef = FirebaseFirestore.instance
        .collection('UserTodo')
        .doc(uid)
        .collection('todos')
        .doc(todoId);
    final snapshot = await docRef.get();
    final currentComplete = snapshot.data()?['complete'] ?? false;
    await docRef.update({'complete': !currentComplete});
    notifyListeners();
  }

  Future<void> addTodoinUser(
    BuildContext context,
    Map<String, dynamic> todo,
  ) async {
    final uid = Provider.of<AppState>(context, listen: false).user?.uid;
    if (uid != null) {
      final insertData = {
        ...todo,
        'created_at': FieldValue.serverTimestamp(),
        'complete': false,
      };
      final docRef = await FirebaseFirestore.instance
          .collection('UserTodo')
          .doc(uid)
          .collection('todos')
          .add(insertData);
      await docRef.update({'id': docRef.id});
    }
    notifyListeners();
  }
}
