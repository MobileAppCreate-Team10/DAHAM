// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Provider/todo_provider.dart';
import 'package:daham/Provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AppState extends ChangeNotifier {
  AppState();

  bool? _login;
  bool? get login => _login;

  User? _user;
  User? get user => _user;

  bool? _newAccount;
  bool isReady = false;
  bool? get newAccount => _newAccount;

  Future<void> init(BuildContext context) async {
    _login = null;
    notifyListeners();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _user = user;
      _login = user != null;
      notifyListeners();

      final userState = Provider.of<UserState>(context, listen: false);
      final todoState = Provider.of<TodoState>(context, listen: false);
      if (user != null) {
        print(_login);
        userState.listenUserDoc(user.uid);
        todoState.listenTodoData(user.uid);
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        _newAccount = !userDoc.exists;
      } else {
        userState.clear();
        todoState.cancel();
        _newAccount = false;
      }
      isReady = true;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    if (user?.isAnonymous == true) await deleteAllData();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .delete();
    } catch (e) {
      print('users 문서 삭제 실패: $e');
    }
    try {
      await FirebaseFirestore.instance
          .collection('UserTodo')
          .doc(user?.uid)
          .delete();
    } catch (e) {
      print('UserTodo 문서 삭제 실패: $e');
    }
    try {
      await user?.delete();
    } catch (e) {
      print('Firebase Auth 계정 삭제 실패: $e');
    }
  }
}
