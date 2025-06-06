import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class TodoState extends ChangeNotifier {
  StreamSubscription? _userTodoSub;
  Map<String, dynamic>? _todoData;

  void listenTodoData(String uid) {
    _userTodoSub?.cancel();
    _userTodoSub = FirebaseFirestore.instance.doc(uid).snapshots().listen((
      doc,
    ) {
      _todoData = doc.data();
      notifyListeners();
    });
  }

  void cancel() {
    _userTodoSub?.cancel();
    _userTodoSub = null;
    _todoData = null;
    notifyListeners();
  }
}
