import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Data/todo.dart';
import 'package:daham/Provider/export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoState extends ChangeNotifier {
  StreamSubscription? _userTodoSub;
  List<PersonalTodoItem>? _todoList;
  List<PersonalTodoItem>? get todoList => _todoList;

  List<PersonalTodoItem>? _selectedTodoList;
  List<PersonalTodoItem>? get selectTodoList => _selectedTodoList;

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

  List<PersonalTodoItem>? fetchselectedTodoList(DateTime select) {
    final selectedStr =
        "${select.year.toString().padLeft(4, '0')}-"
        "${select.month.toString().padLeft(2, '0')}-"
        "${select.day.toString().padLeft(2, '0')}";

    _selectedTodoList =
        _todoList!.where((todo) {
          // dueDate가 String(yyyy-MM-dd)라고 가정
          return todo.dueDate == selectedStr;
        }).toList();

    notifyListeners();
    return _selectedTodoList;
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

  Future<void> addTODO(BuildContext context, Map<String, dynamic> todo) async {
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

  Future<void> updateTodo(
    String uid,
    String todoId,
    Map<String, dynamic> updatedData,
  ) async {
    final docRef = FirebaseFirestore.instance
        .collection('UserTodo')
        .doc(uid)
        .collection('todos')
        .doc(todoId);

    await docRef.update(updatedData);
    notifyListeners();
  }

  Future<void> deleteTodoItem(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('UserTodo')
        .doc(uid)
        .collection('todos')
        .doc(id);
    await docRef.delete();
    notifyListeners();
  }

  Future<List<String>> fetchCategories() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('UserTodo').doc(uid).get();
    final data = doc.data();
    if (data != null && data['categories'] != null) {
      return List<String>.from(data['categories']);
    }
    return [];
  }

  Future<List<String>> fetchSubjects() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('UserTodo').doc(uid).get();
    final data = doc.data();
    if (data != null && data['subjects'] != null) {
      return List<String>.from(data['subjects']);
    }
    return [];
  }

  Future<void> addSubject(String subject) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('UserTodo').doc(uid).set({
      'subjects': FieldValue.arrayUnion([subject]),
    }, SetOptions(merge: true));
  }

  Future<void> addCategory(String category) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('UserTodo').doc(uid).set({
      'categories': FieldValue.arrayUnion([category]),
    }, SetOptions(merge: true));
  }

  Future<void> removeSubject(String subject) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('UserTodo').doc(uid).update({
      'subjects': FieldValue.arrayRemove([subject]),
    });
    await fetchSubjects(); // 필요시 갱신
    notifyListeners();
  }

  /// 이번주(월~일) 각 요일별 해야 할 일 개수 반환
  Map<int, int> fetchThisWeekTodoCountByWeekday() {
    // 결과: {1: 월요일 개수, 2: 화요일 개수, ..., 7: 일요일 개수}
    if (_todoList == null) return {for (var i = 1; i <= 7; i++) i: 0};

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    // 요일별 개수 초기화
    final Map<int, int> countMap = {for (var i = 1; i <= 7; i++) i: 0};

    for (final todo in _todoList!) {
      final due = DateTime.tryParse(todo.dueDate);
      if (due == null) continue;
      if (!due.isBefore(monday) && !due.isAfter(sunday)) {
        countMap[due.weekday] = countMap[due.weekday]! + 1;
      }
    }
    return countMap;
  }

  /// 이번주(월~일) 각 요일별 PersonalTodoItem 리스트 반환
  Map<int, List<PersonalTodoItem>> fetchThisWeekTodosByWeekday() {
    // 결과: {1: [월요일 할일들], 2: [화요일 할일들], ..., 7: [일요일 할일들]}
    if (_todoList == null) {
      return {for (var i = 1; i <= 7; i++) i: <PersonalTodoItem>[]};
    }

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    // 요일별 리스트 초기화
    final Map<int, List<PersonalTodoItem>> map = {
      for (var i = 1; i <= 7; i++) i: [],
    };

    for (final todo in _todoList!) {
      final due = DateTime.tryParse(todo.dueDate);
      if (due == null) continue;
      if (!due.isBefore(monday) && !due.isAfter(sunday)) {
        map[due.weekday]!.add(todo);
      }
    }
    return map;
  }
}
