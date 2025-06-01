import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  StreamSubscription? _userDocSub;
  Map<String, dynamic>? _userData;
  get userData => _userData;

  void listenUserDoc(String uid) {
    _userDocSub?.cancel();
    _userDocSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
          _userData = doc.data();
          notifyListeners();
        });
  }

  void clear() {
    _userDocSub?.cancel();
    _userDocSub = null;
    _userData = null;
    notifyListeners();
  }

  Future<void> registerUser({
    required String uid,
    required String userName,
    String? description,
    int? age,
    List<String>? interest,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'userName': userName,
      'description': description ?? '',
      'age': age,
      'interest': interest ?? [],
      'followerCount': 0,
      'followingCount': 0,
      // 필요시 추가 필드
    });
  }
}
